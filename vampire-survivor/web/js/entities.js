/* ============================================================
   entities.js — structures de données du jeu (sans logique de boucle).
   Exposé via window.Entities.
   ============================================================ */
(function () {
  "use strict";

  const TAU = Math.PI * 2;

  /* Carte des ennemis. hp/dégâts de base, mis à l'échelle avec le temps. */
  const ENEMY_TYPES = {
    gobelin: { sprite: "gobelin", hp: 26,  speed: 76, dmg: 8,  xp: 1, radius: 15, size: 42, showBar: false },
    bandit:  { sprite: "bandit",  hp: 62,  speed: 58, dmg: 12, xp: 3, radius: 16, size: 44, showBar: false },
    garde:   { sprite: "garde",   hp: 155, speed: 45, dmg: 20, xp: 6, radius: 18, size: 50, showBar: true  },
  };

  class Player {
    constructor(x, y) {
      this.x = x; this.y = y;
      this.radius = 15; this.size = 46;
      this.speed = 205;
      this.maxhp = 100; this.hp = 100;
      this.level = 1; this.xp = 0; this.xpToNext = 5;
      this.facing = 1;            // 1 = regarde à droite, -1 = à gauche
      this.invuln = 0;            // secondes d'invulnérabilité après un coup
      this.pickupRange = 80;
      this.moving = false; this.stepTimer = 0; this.bob = 0;

      // Arme (frappe automatique)
      this.fireCooldown = 0;
      this.fireInterval = 0.85;   // secondes entre deux tirs
      this.projDamage = 24;
      this.projSpeed = 430;
      this.projCount = 1;         // nombre de projectiles par tir
      this.pierce = 0;            // ennemis traversés en plus
      this.projSize = 11;
    }
    get xpPct() { return this.xp / this.xpToNext; }
    get hpPct() { return this.hp / this.maxhp; }
  }

  class Enemy {
    constructor(typeKey, x, y, hpScale) {
      const t = ENEMY_TYPES[typeKey];
      this.type = typeKey; this.def = t;
      this.x = x; this.y = y;
      this.maxhp = Math.round(t.hp * hpScale);
      this.hp = this.maxhp;
      this.speed = t.speed;
      this.dmg = t.dmg;
      this.xp = t.xp;
      this.radius = t.radius;
      this.size = t.size;
      this.facing = 1;
      this.hitFlash = 0;          // timer de flash blanc quand touché
      this.showBar = t.showBar;
      this.dead = false;
    }
  }

  class Projectile {
    constructor(x, y, dx, dy, speed, dmg, pierce, size) {
      this.x = x; this.y = y;
      this.vx = dx * speed; this.vy = dy * speed;
      this.dmg = dmg;
      this.hitsLeft = pierce + 1;  // nombre d'ennemis qu'il peut toucher
      this.size = size;
      this.life = 2.2;
      this.angle = Math.atan2(dy, dx);
      this.hitSet = new Set();     // évite de toucher deux fois le même ennemi
      this.dead = false;
    }
  }

  class Gem {
    constructor(x, y, value) {
      this.x = x; this.y = y; this.value = value;
      this.bob = Math.random() * TAU;
      this.dead = false;
    }
  }

  class FloatText {
    constructor(x, y, text, color) {
      this.x = x; this.y = y;
      this.text = text;
      this.color = color || "#fff";
      this.life = 0.7;
      this.vy = -36;
    }
  }

  window.Entities = {
    Player: Player, Enemy: Enemy, Projectile: Projectile,
    Gem: Gem, FloatText: FloatText,
    ENEMY_TYPES: ENEMY_TYPES, TAU: TAU,
  };
})();
