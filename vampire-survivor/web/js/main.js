/* ============================================================
   main.js — point d'entrée : précharge les assets puis active le jeu.
   ============================================================ */
(function () {
  "use strict";

  const canvas = document.getElementById("canvas");
  const startBtn = document.getElementById("startBtn");
  const retryBtn = document.getElementById("retryBtn");

  window.Game.init(canvas);

  startBtn.disabled = true;

  window.Assets.load(function (done, total) {
    startBtn.textContent = "Chargement… " + Math.round((done / total) * 100) + "%";
  }).then(function () {
    window.Game.prepareMasks();      // génère les silhouettes de flash
    startBtn.disabled = false;
    startBtn.textContent = "JOUER";
  });

  startBtn.addEventListener("click", function () {
    if (startBtn.disabled) return;
    window.Assets.play("click", 0.5);
    window.Game.start();
  });

  retryBtn.addEventListener("click", function () {
    window.Assets.play("click", 0.5);
    window.Game.start();
  });
})();
