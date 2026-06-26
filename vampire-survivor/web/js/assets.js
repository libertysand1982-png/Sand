/* ============================================================
   assets.js — chargement des images et des sons.
   Tout est exposé via window.Assets.
   Les fichiers proviennent du dépôt "Sand" (assets Kenney, CC0).
   ============================================================ */
(function () {
  "use strict";

  // Sprites de personnages (64x64, vue de dessus, fond transparent)
  const IMAGES = {
    hero:    "assets/characters/hero.png",
    gobelin: "assets/characters/gobelin.png",
    bandit:  "assets/characters/bandit.png",
    garde:   "assets/characters/garde.png",
    // Barres d'UI Kenney (3 tranches : gauche 9px / milieu 18px / droite 9px)
    barBackL: "assets/ui/barBack_horizontalLeft.png",
    barBackM: "assets/ui/barBack_horizontalMid.png",
    barBackR: "assets/ui/barBack_horizontalRight.png",
    barRedL:  "assets/ui/barRed_horizontalLeft.png",
    barRedM:  "assets/ui/barRed_horizontalMid.png",
    barRedR:  "assets/ui/barRed_horizontalRight.png",
  };

  // Effets sonores (.ogg)
  const SOUNDS = {
    slice:  "assets/audio/knifeSlice.ogg",   // tir de l'arme
    slice2: "assets/audio/knifeSlice2.ogg",  // variante de tir
    coins:  "assets/audio/handleCoins.ogg",  // ramassage de gemme
    hit:    "assets/audio/metalClick.ogg",   // projectile qui touche
    step:   "assets/audio/footstep00.ogg",   // pas du héros
    click:  "assets/audio/click1.ogg",       // clics de menu
    hurt:   "assets/audio/drawKnife1.ogg",   // héros blessé
  };

  const Assets = { img: {}, snd: {}, mask: {}, ready: false, muted: false };

  /* Précharge tout. Renvoie une promesse, et appelle onProgress(fait,total). */
  Assets.load = function (onProgress) {
    const imgKeys = Object.keys(IMAGES);
    const sndKeys = Object.keys(SOUNDS);
    const total = imgKeys.length + sndKeys.length;
    let done = 0;

    return new Promise(function (resolve) {
      const tick = function () {
        done++;
        if (onProgress) onProgress(done, total);
        if (done >= total) { Assets.ready = true; resolve(Assets); }
      };

      imgKeys.forEach(function (k) {
        const im = new Image();
        im.onload = tick;
        im.onerror = tick;           // on continue même si un fichier manque
        im.src = IMAGES[k];
        Assets.img[k] = im;
      });

      sndKeys.forEach(function (k) {
        const au = new Audio();
        au.preload = "auto";
        let settled = false;
        const ok = function () { if (!settled) { settled = true; tick(); } };
        au.addEventListener("canplaythrough", ok, { once: true });
        au.addEventListener("error", ok, { once: true });
        // Filet de sécurité si l'évènement ne se déclenche pas (file://)
        setTimeout(ok, 2500);
        au.src = SOUNDS[k];
        Assets.snd[k] = au;
      });
    });
  };

  /* Crée une silhouette blanche d'un sprite (pour l'effet de flash quand touché).
     On dessine seulement le résultat ensuite : aucune lecture de pixels => pas de
     souci de "canvas taint" même en file://. */
  function makeWhiteMask(img) {
    const w = img.width || 64, h = img.height || 64;
    const c = document.createElement("canvas");
    c.width = w; c.height = h;
    const x = c.getContext("2d");
    x.drawImage(img, 0, 0);
    x.globalCompositeOperation = "source-in";
    x.fillStyle = "#ffffff";
    x.fillRect(0, 0, w, h);
    return c;
  }

  Assets.buildMasks = function (keys) {
    keys.forEach(function (k) {
      const im = Assets.img[k];
      if (im && im.naturalWidth > 0) Assets.mask[k] = makeWhiteMask(im);
    });
  };

  /* Joue un son. On clone pour autoriser la superposition de plusieurs instances. */
  Assets.play = function (name, volume) {
    if (Assets.muted) return;
    const base = Assets.snd[name];
    if (!base) return;
    try {
      const a = base.cloneNode(true);
      a.volume = (volume == null) ? 1 : Math.max(0, Math.min(1, volume));
      const p = a.play();
      if (p && p.catch) p.catch(function () {});
    } catch (e) { /* ignore */ }
  };

  window.Assets = Assets;
})();
