/* ============================================================
   game.js — moteur du jeu : boucle, spawn, collisions, niveaux, rendu.
   Exposé via window.Game.
   ============================================================ */
(function () {
  "use strict";

  const E = window.Entities;
  const TAU = E.TAU;
  const WORLD = 4000;            // taille de l'arène (carrée)
  const MAX_ENEMIES = 280;

  function clamp(v, a, b) { return v < a ? a : (v > b ? b : v); }
  function rand(a, b) { return a + Math.random() * (b - a); }

  /* Améliorations proposées à chaque montée de niveau. */
  const UPGRADES = [
    { icon: "🗡️", name: "Lame jumelle", desc: "+1 projectile par tir",
      apply: function (p) { p.projCount++; } },
    { icon: "⚡", name: "Frappe rapide", desc: "-15% de temps de recharge",
      apply: function (p) { p.fireInterval = Math.max(0.16, p.fireInterval * 0.85); } },
    { icon: "💥", name: "Affûtage", desc: "+30% de dégâts",
      apply: function (p) { p.projDamage = Math.round(p.projDamage * 1.3); } },
    { icon: "🥾", name: "Bottes ailées", desc: "+12% de vitesse",
      apply: function (p) { p.speed *= 1.12; } },
    { icon: "❤️", name: "Vitalité", desc: "+25 PV max (et soigne)",
      apply: function (p) { p.maxhp += 25; p.hp = Math.min(p.maxhp, p.hp + 25); } },
    { icon: "🧲", name: "Aimant", desc: "+30% de portée de ramassage",
      apply: function (p) { p.pickupRange *= 1.3; } },
    { icon: "🎯", name: "Perforation", desc: "Les tirs traversent +1 ennemi",
      apply: function (p) { p.pierce++; } },
    { icon: "🌀", name: "Projectile lourd", desc: "+25% vitesse & taille du tir",
      apply: function (p) { p.projSpeed *= 1.25; p.projSize *= 1.25; } },
  ];

  const Game = {
    state: "menu",   // menu | playing | levelup | paused | gameover
    canvas: null, ctx: null,
    cam: { x: 0, y: 0 },
    time: 0,         // horloge d'animation (toujours qui tourne)
    last: 0,
  };

  /* ---------- Initialisation ---------- */
  Game.init = function (canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.dom = {
      hud: document.getElementById("hud"),
      menu: document.getElementById("menu"),
      levelup: document.getElementById("levelup"),
      gameover: document.getElementById("gameover"),
      pause: document.getElementById("pause"),
      cards: document.getElementById("cards"),
      xpfill: document.getElementById("xpfill"),
      xptext: document.getElementById("xptext"),
      timer: document.getElementById("timer"),
      kills: document.getElementById("kills"),
      goStats: document.getElementById("goStats"),
      muteflag: document.getElementById("muteflag"),
    };
    this.resize();
    window.addEventListener("resize", this.resize.bind(this));

    this.loop = this.loop.bind(this);
    this.last = performance.now();
    requestAnimationFrame(this.loop);
  };

  Game.resize = function () {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
    this.ctx.imageSmoothingEnabled = false;
  };

  Game.prepareMasks = function () {
    window.Assets.buildMasks(["hero", "gobelin", "bandit", "garde"]);
  };

  /* ---------- Démarrage / reset d'une partie ---------- */
  Game.start = function () {
    this.player = new E.Player(WORLD / 2, WORLD / 2);
    this.enemies = [];
    this.projectiles = [];
    this.gems = [];
    this.texts = [];
    this.elapsed = 0;
    this.kills = 0;
    this.spawnTimer = 0;
    this.levelQueue = 0;
    this.state = "playing";

    this.dom.menu.classList.add("hidden");
    this.dom.gameover.classList.add("hidden");
    this.dom.levelup.classList.add("hidden");
    this.dom.pause.classList.add("hidden");
    this.dom.hud.classList.remove("hidden");
    this.updateHud();
  };

  /* ---------- Boucle principale ---------- */
  Game.loop = function (ts) {
    let dt = (ts - this.last) / 1000;
    this.last = ts;
    if (!(dt > 0)) dt = 0;
    if (dt > 0.05) dt = 0.05;        // évite les sauts (onglet en arrière-plan)
    this.time += dt;

    if (this.state === "playing") this.update(dt);
    this.render();

    requestAnimationFrame(this.loop);
  };

  /* ---------- Mise à jour ---------- */
  Game.update = function (dt) {
    const p = this.player;
    this.elapsed += dt;

    // --- Déplacement du joueur ---
    const mv = window.Input.moveVector();
    p.moving = (mv.x !== 0 || mv.y !== 0);
    p.x = clamp(p.x + mv.x * p.speed * dt, 24, WORLD - 24);
    p.y = clamp(p.y + mv.y * p.speed * dt, 24, WORLD - 24);
    if (mv.x < 0) p.facing = -1; else if (mv.x > 0) p.facing = 1;
    if (p.invuln > 0) p.invuln -= dt;

    // pas (son) + petit balancement vertical
    if (p.moving) {
      p.bob += dt * 10;
      p.stepTimer -= dt;
      if (p.stepTimer <= 0) { window.Assets.play("step", 0.12); p.stepTimer = 0.33; }
    } else { p.bob = 0; }

    // --- Arme automatique ---
    p.fireCooldown -= dt;
    if (p.fireCooldown <= 0 && this.enemies.length > 0) {
      this.fireWeapon();
      p.fireCooldown = p.fireInterval;
    }

    this.updateSpawns(dt);
    this.updateEnemies(dt);
    this.updateProjectiles(dt);
    this.updateGems(dt);
    this.updateTexts(dt);

    // --- Montée(s) de niveau en attente ---
    if (this.levelQueue > 0 && this.state === "playing") this.openLevelUp();

    // --- Mort ---
    if (p.hp <= 0) this.gameOver();

    this.updateHud();
  };

  /* ---------- Tir de l'arme : vise l'ennemi le plus proche ---------- */
  Game.fireWeapon = function () {
    const p = this.player;
    let best = null, bestD = Infinity;
    for (let i = 0; i < this.enemies.length; i++) {
      const e = this.enemies[i];
      const d = (e.x - p.x) * (e.x - p.x) + (e.y - p.y) * (e.y - p.y);
      if (d < bestD) { bestD = d; best = e; }
    }
    if (!best) return;

    const baseAngle = Math.atan2(best.y - p.y, best.x - p.x);
    const n = p.projCount;
    const spread = 0.22;                       // écart angulaire entre projectiles
    const start = baseAngle - spread * (n - 1) / 2;
    for (let i = 0; i < n; i++) {
      const a = start + spread * i;
      this.projectiles.push(new E.Projectile(
        p.x, p.y, Math.cos(a), Math.sin(a),
        p.projSpeed, p.projDamage, p.pierce, p.projSize
      ));
    }
    window.Assets.play(Math.random() < 0.5 ? "slice" : "slice2", 0.22);
  };

  /* ---------- Apparition des ennemis ---------- */
  Game.updateSpawns = function (dt) {
    this.spawnTimer -= dt;
    if (this.spawnTimer > 0) return;

    const min = this.elapsed / 60;
    const interval = Math.max(0.2, 1.15 - min * 0.16);   // de plus en plus rapide
    this.spawnTimer = interval;

    const batch = 1 + Math.floor(this.elapsed / 45);
    for (let i = 0; i < batch && this.enemies.length < MAX_ENEMIES; i++) {
      this.spawnOne();
    }
  };

  Game.spawnOne = function () {
    // type pondéré selon le temps écoulé
    const t = this.elapsed;
    let type;
    const r = Math.random();
    if (t < 30)       type = "gobelin";
    else if (t < 75)  type = r < 0.7 ? "gobelin" : "bandit";
    else if (t < 150) type = r < 0.45 ? "gobelin" : (r < 0.85 ? "bandit" : "garde");
    else              type = r < 0.3 ? "gobelin" : (r < 0.7 ? "bandit" : "garde");

    const hpScale = 1 + (this.elapsed / 60) * 0.22;

    // position juste hors de l'écran, autour du joueur
    const p = this.player;
    const radius = Math.max(this.canvas.width, this.canvas.height) / 2 + 70;
    const a = Math.random() * TAU;
    const x = clamp(p.x + Math.cos(a) * radius, 20, WORLD - 20);
    const y = clamp(p.y + Math.sin(a) * radius, 20, WORLD - 20);
    this.enemies.push(new E.Enemy(type, x, y, hpScale));
  };

  /* ---------- Ennemis : poursuite + dégâts au contact ---------- */
  Game.updateEnemies = function (dt) {
    const p = this.player;
    for (let i = 0; i < this.enemies.length; i++) {
      const e = this.enemies[i];
      const dx = p.x - e.x, dy = p.y - e.y;
      const d = Math.hypot(dx, dy) || 1;
      e.x += (dx / d) * e.speed * dt;
      e.y += (dy / d) * e.speed * dt;
      e.facing = dx < 0 ? -1 : 1;
      if (e.hitFlash > 0) e.hitFlash -= dt;

      // contact avec le joueur
      if (d < e.radius + p.radius && p.invuln <= 0) {
        p.hp -= e.dmg;
        p.invuln = 0.6;
        window.Assets.play("hurt", 0.4);
        this.texts.push(new E.FloatText(p.x, p.y - 28, "-" + e.dmg, "#ff6b6b"));
      }
    }
  };

  /* ---------- Projectiles ---------- */
  Game.updateProjectiles = function (dt) {
    for (let i = 0; i < this.projectiles.length; i++) {
      const pr = this.projectiles[i];
      pr.x += pr.vx * dt;
      pr.y += pr.vy * dt;
      pr.life -= dt;
      if (pr.life <= 0 || pr.x < -50 || pr.y < -50 || pr.x > WORLD + 50 || pr.y > WORLD + 50) {
        pr.dead = true; continue;
      }
      // collisions avec les ennemis
      for (let j = 0; j < this.enemies.length; j++) {
        const e = this.enemies[j];
        if (e.dead || pr.hitSet.has(e)) continue;
        const rr = e.radius + pr.size;
        if ((e.x - pr.x) * (e.x - pr.x) + (e.y - pr.y) * (e.y - pr.y) <= rr * rr) {
          pr.hitSet.add(e);
          e.hp -= pr.dmg;
          e.hitFlash = 0.12;
          this.texts.push(new E.FloatText(e.x, e.y - e.size * 0.4, String(pr.dmg), "#ffe9a8"));
          window.Assets.play("hit", 0.12);
          if (e.hp <= 0) this.killEnemy(e);
          pr.hitsLeft--;
          if (pr.hitsLeft <= 0) { pr.dead = true; break; }
        }
      }
    }
    this.projectiles = this.projectiles.filter(function (pr) { return !pr.dead; });
  };

  Game.killEnemy = function (e) {
    if (e.dead) return;
    e.dead = true;
    this.kills++;
    this.gems.push(new E.Gem(e.x, e.y, e.xp));
  };

  /* ---------- Gemmes d'expérience ---------- */
  Game.updateGems = function (dt) {
    const p = this.player;
    let gained = 0, collected = 0;
    for (let i = 0; i < this.gems.length; i++) {
      const g = this.gems[i];
      g.bob += dt * 4;
      const dx = p.x - g.x, dy = p.y - g.y;
      const d = Math.hypot(dx, dy) || 1;
      if (d < p.pickupRange) {
        // aimantation : accélère vers le joueur
        const pull = clamp(360 + (p.pickupRange - d) * 6, 360, 1100);
        g.x += (dx / d) * pull * dt;
        g.y += (dy / d) * pull * dt;
      }
      if (d < 18) { g.dead = true; gained += g.value; collected++; }
    }
    if (collected > 0) {
      this.gems = this.gems.filter(function (g) { return !g.dead; });
      window.Assets.play("coins", 0.3);
      this.addXp(gained);
    }
    // retire les ennemis morts une fois par frame
    this.enemies = this.enemies.filter(function (e) { return !e.dead; });
  };

  Game.addXp = function (amount) {
    const p = this.player;
    p.xp += amount;
    while (p.xp >= p.xpToNext) {
      p.xp -= p.xpToNext;
      p.level++;
      p.xpToNext = Math.round(p.xpToNext * 1.32 + 3);
      this.levelQueue++;
    }
  };

  /* ---------- Textes flottants (dégâts) ---------- */
  Game.updateTexts = function (dt) {
    for (let i = 0; i < this.texts.length; i++) {
      const ft = this.texts[i];
      ft.y += ft.vy * dt;
      ft.life -= dt;
    }
    this.texts = this.texts.filter(function (ft) { return ft.life > 0; });
  };

  /* ---------- Montée de niveau : choix d'amélioration ---------- */
  Game.openLevelUp = function () {
    this.state = "levelup";
    this.levelQueue--;

    // 3 améliorations distinctes au hasard
    const pool = UPGRADES.slice();
    for (let i = pool.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const tmp = pool[i]; pool[i] = pool[j]; pool[j] = tmp;
    }
    const choices = pool.slice(0, 3);

    const cards = this.dom.cards;
    cards.innerHTML = "";
    const self = this;
    choices.forEach(function (up) {
      const div = document.createElement("div");
      div.className = "card";
      div.innerHTML =
        '<div class="icon">' + up.icon + '</div>' +
        '<div class="name">' + up.name + '</div>' +
        '<div class="desc">' + up.desc + '</div>';
      div.addEventListener("click", function () {
        up.apply(self.player);
        window.Assets.play("click", 0.5);
        self.closeLevelUp();
      });
      cards.appendChild(div);
    });

    this.dom.levelup.classList.remove("hidden");
  };

  Game.closeLevelUp = function () {
    this.dom.levelup.classList.add("hidden");
    // s'il reste des niveaux en file, on rouvre, sinon on reprend
    if (this.levelQueue > 0) this.openLevelUp();
    else this.state = "playing";
  };

  /* ---------- Fin de partie ---------- */
  Game.gameOver = function () {
    this.state = "gameover";
    const m = Math.floor(this.elapsed / 60), s = Math.floor(this.elapsed % 60);
    const time = (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
    this.dom.goStats.innerHTML =
      "Temps survécu : <b>" + time + "</b><br>" +
      "Niveau atteint : <b>" + this.player.level + "</b><br>" +
      "Monstres vaincus : <b>" + this.kills + "</b>";
    this.dom.gameover.classList.remove("hidden");
    this.dom.hud.classList.add("hidden");
  };

  /* ---------- Pause / son ---------- */
  Game.togglePause = function () {
    if (this.state === "playing") {
      this.state = "paused";
      this.dom.pause.classList.remove("hidden");
    } else if (this.state === "paused") {
      this.state = "playing";
      this.dom.pause.classList.add("hidden");
      this.last = performance.now();
    }
  };

  Game.toggleMute = function () {
    window.Assets.muted = !window.Assets.muted;
    this.dom.muteflag.classList.toggle("hidden", !window.Assets.muted);
  };

  /* ============================================================
     RENDU
     ============================================================ */
  Game.render = function () {
    const ctx = this.ctx, cv = this.canvas;
    const vw = cv.width, vh = cv.height;

    // caméra centrée sur le joueur (ou centre de l'arène au menu)
    let camx, camy;
    if (this.player) {
      camx = clamp(this.player.x - vw / 2, 0, Math.max(0, WORLD - vw));
      camy = clamp(this.player.y - vh / 2, 0, Math.max(0, WORLD - vh));
    } else {
      camx = (WORLD - vw) / 2; camy = (WORLD - vh) / 2;
    }
    this.cam.x = camx; this.cam.y = camy;

    this.drawGround(ctx, camx, camy, vw, vh);

    if (!this.player) return;   // menu : juste le décor

    // gemmes
    for (let i = 0; i < this.gems.length; i++) this.drawGem(ctx, this.gems[i], camx, camy);

    // ennemis triés par y (léger effet de profondeur)
    const sorted = this.enemies.slice().sort(function (a, b) { return a.y - b.y; });
    for (let i = 0; i < sorted.length; i++) this.drawEnemy(ctx, sorted[i], camx, camy);

    // projectiles
    for (let i = 0; i < this.projectiles.length; i++) this.drawProjectile(ctx, this.projectiles[i], camx, camy);

    // joueur
    this.drawPlayer(ctx, camx, camy);

    // textes flottants
    ctx.textAlign = "center";
    ctx.font = "bold 15px Trebuchet MS, sans-serif";
    for (let i = 0; i < this.texts.length; i++) {
      const ft = this.texts[i];
      ctx.globalAlpha = clamp(ft.life / 0.4, 0, 1);
      ctx.fillStyle = "#000";
      ctx.fillText(ft.text, ft.x - camx + 1, ft.y - camy + 1);
      ctx.fillStyle = ft.color;
      ctx.fillText(ft.text, ft.x - camx, ft.y - camy);
    }
    ctx.globalAlpha = 1;

    this.drawVignette(ctx, vw, vh);
    this.drawPlayerHealthBar(ctx);
  };

  /* Sol en damier + touffes déterministes. */
  Game.drawGround = function (ctx, camx, camy, vw, vh) {
    const T = 64;
    const x0 = Math.floor(camx / T), y0 = Math.floor(camy / T);
    const x1 = Math.ceil((camx + vw) / T), y1 = Math.ceil((camy + vh) / T);
    for (let ty = y0; ty < y1; ty++) {
      for (let tx = x0; tx < x1; tx++) {
        const even = (tx + ty) & 1;
        ctx.fillStyle = even ? "#1a2e1f" : "#16271b";
        ctx.fillRect(tx * T - camx, ty * T - camy, T, T);
        // touffe d'herbe pseudo-aléatoire stable
        const h = (tx * 73856093 ^ ty * 19349663) >>> 0;
        if ((h & 7) === 0) {
          ctx.fillStyle = "#213a27";
          const ox = (h % 40) + 12, oy = ((h >> 6) % 40) + 12;
          ctx.fillRect(tx * T - camx + ox, ty * T - camy + oy, 4, 4);
        }
      }
    }
  };

  Game.drawShadow = function (ctx, sx, sy, w) {
    ctx.fillStyle = "rgba(0,0,0,0.28)";
    ctx.beginPath();
    ctx.ellipse(sx, sy, w * 0.32, w * 0.14, 0, 0, TAU);
    ctx.fill();
  };

  Game.drawSprite = function (ctx, key, sx, sy, size, facing, flash) {
    const img = window.Assets.img[key];
    const half = size / 2;
    ctx.save();
    ctx.translate(sx, sy);
    if (facing < 0) ctx.scale(-1, 1);
    if (img) ctx.drawImage(img, -half, -half, size, size);
    if (flash > 0) {
      const mask = window.Assets.mask[key];
      if (mask) {
        ctx.globalAlpha = clamp(flash / 0.12, 0, 1) * 0.85;
        ctx.drawImage(mask, -half, -half, size, size);
        ctx.globalAlpha = 1;
      }
    }
    ctx.restore();
  };

  Game.drawEnemy = function (ctx, e, camx, camy) {
    const sx = e.x - camx, sy = e.y - camy;
    this.drawShadow(ctx, sx, sy + e.size * 0.42, e.size);
    this.drawSprite(ctx, e.def.sprite, sx, sy, e.size, e.facing, e.hitFlash);
    if (e.showBar && e.hp < e.maxhp) {
      this.draw3Bar(ctx, sx - 22, sy - e.size * 0.62, 44, 7, e.hp / e.maxhp);
    }
  };

  Game.drawPlayer = function (ctx, camx, camy) {
    const p = this.player;
    const sx = p.x - camx, sy = p.y - camy - Math.abs(Math.sin(p.bob)) * 3;
    this.drawShadow(ctx, p.x - camx, p.y - camy + p.size * 0.42, p.size);
    // clignotement pendant l'invulnérabilité
    if (p.invuln > 0 && (Math.floor(this.time * 20) & 1)) ctx.globalAlpha = 0.45;
    this.drawSprite(ctx, "hero", sx, sy, p.size, p.facing, 0);
    ctx.globalAlpha = 1;
  };

  Game.drawProjectile = function (ctx, pr, camx, camy) {
    const sx = pr.x - camx, sy = pr.y - camy;
    ctx.save();
    ctx.translate(sx, sy);
    // halo
    ctx.fillStyle = "rgba(120,230,255,0.22)";
    ctx.beginPath(); ctx.arc(0, 0, pr.size + 5, 0, TAU); ctx.fill();
    // éclat orienté
    ctx.rotate(pr.angle);
    ctx.fillStyle = "#dff8ff";
    ctx.fillRect(-pr.size, -2.5, pr.size * 2, 5);
    ctx.fillStyle = "#8fe6ff";
    ctx.fillRect(pr.size - 3, -1.5, 5, 3);
    ctx.restore();
  };

  Game.drawGem = function (ctx, g, camx, camy) {
    const sx = g.x - camx, sy = g.y - camy + Math.sin(g.bob) * 2;
    ctx.save();
    ctx.translate(sx, sy);
    ctx.fillStyle = "rgba(90,200,255,0.25)";
    ctx.beginPath(); ctx.arc(0, 0, 9, 0, TAU); ctx.fill();
    ctx.rotate(Math.PI / 4);
    ctx.fillStyle = "#54c8ff";
    ctx.fillRect(-4, -4, 8, 8);
    ctx.fillStyle = "#bff0ff";
    ctx.fillRect(-4, -4, 4, 4);
    ctx.restore();
  };

  /* Barre en 3 tranches avec les sprites Kenney (fond + remplissage rouge). */
  Game.draw3Bar = function (ctx, x, y, w, h, pct) {
    this.sliceBar(ctx, "barBack", x, y, w, h, 1);
    const fw = clamp(pct, 0, 1) * w;
    if (fw > 1) {
      ctx.save();
      ctx.beginPath(); ctx.rect(x, y, fw, h); ctx.clip();
      this.sliceBar(ctx, "barRed", x, y, w, h, 1);
      ctx.restore();
    }
  };

  Game.sliceBar = function (ctx, prefix, x, y, w, h) {
    const L = window.Assets.img[prefix + "L"];
    const M = window.Assets.img[prefix + "M"];
    const R = window.Assets.img[prefix + "R"];
    const cap = h * (9 / 18);     // les capuchons font 9px de large pour 18px de haut
    if (!L || !M || !R) {         // repli si l'image manque
      ctx.fillStyle = prefix === "barRed" ? "#d9434f" : "#000";
      ctx.fillRect(x, y, w, h); return;
    }
    ctx.drawImage(L, x, y, cap, h);
    ctx.drawImage(M, x + cap, y, w - 2 * cap, h);
    ctx.drawImage(R, x + w - cap, y, cap, h);
  };

  /* Barre de vie du joueur, en bas à gauche (sprites Kenney). */
  Game.drawPlayerHealthBar = function (ctx) {
    const p = this.player;
    const w = 240, h = 22, x = 18, y = this.canvas.height - h - 18;
    this.draw3Bar(ctx, x, y, w, h, p.hpPct);
    ctx.textAlign = "left";
    ctx.font = "bold 14px Trebuchet MS, sans-serif";
    ctx.fillStyle = "#fff";
    ctx.fillText("PV  " + Math.max(0, Math.ceil(p.hp)) + " / " + p.maxhp, x + 10, y + h - 6);
  };

  Game.drawVignette = function (ctx, vw, vh) {
    if (!this._vig || this._vigW !== vw || this._vigH !== vh) {
      const g = ctx.createRadialGradient(vw / 2, vh / 2, Math.min(vw, vh) * 0.35,
                                         vw / 2, vh / 2, Math.max(vw, vh) * 0.72);
      g.addColorStop(0, "rgba(0,0,0,0)");
      g.addColorStop(1, "rgba(0,0,0,0.45)");
      this._vig = g; this._vigW = vw; this._vigH = vh;
    }
    ctx.fillStyle = this._vig;
    ctx.fillRect(0, 0, vw, vh);
  };

  /* ---------- HUD (DOM) ---------- */
  Game.updateHud = function () {
    const p = this.player;
    this.dom.xpfill.style.width = (clamp(p.xpPct, 0, 1) * 100) + "%";
    this.dom.xptext.textContent = "Niv. " + p.level;
    const m = Math.floor(this.elapsed / 60), s = Math.floor(this.elapsed % 60);
    this.dom.timer.textContent = (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
    this.dom.kills.textContent = "☠ " + this.kills;
  };

  window.Game = Game;
})();
