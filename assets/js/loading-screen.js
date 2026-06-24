/* ══════════════════════════════════════════════
   ALBERT G. POWER RHA — loading-screen.js
   Homepage-only loading screen lifecycle.
   Shows immediately (no FOUC), counts 0→100%
   over a fixed 7 seconds, then fades out and
   reveals the page.
   ══════════════════════════════════════════════ */
(function () {
  'use strict';

  var screen = document.getElementById('agp-loading-screen');
  if (!screen) return;

  var percentEl = document.getElementById('agp-loading-percent-value');
  var DISPLAY_MS = 7000;
  var startTime = Date.now();
  document.body.classList.add('agp-loading-active');

  function tick() {
    var elapsed = Date.now() - startTime;
    var pct = Math.min(100, Math.round((elapsed / DISPLAY_MS) * 100));
    if (percentEl) percentEl.textContent = pct;
    if (elapsed < DISPLAY_MS) {
      requestAnimationFrame(tick);
    } else {
      hideScreen();
    }
  }

  function hideScreen() {
    screen.classList.add('agp-loading-screen--hidden');
    document.body.classList.remove('agp-loading-active');
    // Remove from the DOM after the fade-out transition finishes
    setTimeout(function () {
      if (screen.parentNode) screen.parentNode.removeChild(screen);
    }, 1800);
  }

  requestAnimationFrame(tick);
})();
