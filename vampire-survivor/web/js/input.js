/* ============================================================
   input.js — état clavier + vecteur de déplacement.
   Exposé via window.Input.
   ============================================================ */
(function () {
  "use strict";

  const keys = {};
  const Input = {
    keys: keys,
    isDown: function (code) { return !!keys[code]; },
  };

  const BLOCK_SCROLL = ["ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight", "Space"];

  window.addEventListener("keydown", function (e) {
    keys[e.code] = true;
    if (BLOCK_SCROLL.indexOf(e.code) !== -1) e.preventDefault();

    // Raccourcis globaux gérés par le jeu (s'il est prêt)
    if (window.Game) {
      if (e.code === "KeyP" || e.code === "Escape") window.Game.togglePause();
      if (e.code === "KeyM") window.Game.toggleMute();
    }
  });

  window.addEventListener("keyup", function (e) { keys[e.code] = false; });
  window.addEventListener("blur", function () { for (const k in keys) keys[k] = false; });

  /* Direction normalisée (-1..1) d'après WASD ou les flèches. */
  Input.moveVector = function () {
    let x = 0, y = 0;
    if (keys["KeyW"] || keys["ArrowUp"])    y -= 1;
    if (keys["KeyS"] || keys["ArrowDown"])  y += 1;
    if (keys["KeyA"] || keys["ArrowLeft"])  x -= 1;
    if (keys["KeyD"] || keys["ArrowRight"]) x += 1;
    if (x && y) { const inv = 0.70710678; x *= inv; y *= inv; } // diagonale = même vitesse
    return { x: x, y: y };
  };

  window.Input = Input;
})();
