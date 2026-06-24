/* ══════════════════════════════════════════════
   ALBERT G. POWER RHA — loading-screen.js
   Homepage-only loading screen lifecycle.
   Shows immediately (no FOUC), hides once the
   page has fully loaded, with a minimum display
   time so it doesn't flash on fast connections.
   ══════════════════════════════════════════════ */
(function () {
  'use strict';

  var screen = document.getElementById('agp-loading-screen');
  if (!screen) return;

  var MIN_DISPLAY_MS = 500;
  var shownAt = Date.now();
  document.body.classList.add('agp-loading-active');

  function hideScreen() {
    var elapsed = Date.now() - shownAt;
    var wait = Math.max(0, MIN_DISPLAY_MS - elapsed);
    setTimeout(function () {
      screen.classList.add('agp-loading-screen--hidden');
      document.body.classList.remove('agp-loading-active');
      // Remove from the DOM after the fade-out transition finishes
      setTimeout(function () {
        if (screen.parentNode) screen.parentNode.removeChild(screen);
      }, 700);
    }, wait);
  }

  if (document.readyState === 'complete') {
    hideScreen();
  } else {
    window.addEventListener('load', hideScreen);
  }

  // Safety net: never leave the screen up indefinitely if something
  // (a slow image, a stalled font) never fires the load event.
  setTimeout(hideScreen, 4000);
})();
