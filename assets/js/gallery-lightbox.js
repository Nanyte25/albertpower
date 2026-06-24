/* ══════════════════════════════════════════════
   ALBERT G. POWER RHA — gallery-lightbox.js
   Slider/lightbox for the Gallery page.
   Vanilla JS, no dependencies. Reuses the site's
   existing palette and the bronze-diamond motif
   already used in .celtic-rule.
   ══════════════════════════════════════════════ */
(function () {
  'use strict';

  var items = [];      // { src, caption, alt }
  var currentIndex = 0;
  var lightboxEl, imgEl, loadingEl, captionEl, counterEl;
  var touchStartX = null;

  function buildItemList() {
    var figs = document.querySelectorAll('.gallery-item');
    figs.forEach(function (fig, i) {
      var img = fig.querySelector('.gallery-img-wrap img');
      var captionNode = fig.querySelector('figcaption');
      if (!img) return;
      items.push({
        src: img.getAttribute('src'),
        alt: img.getAttribute('alt') || '',
        captionHTML: captionNode ? captionNode.innerHTML : ''
      });
      // Open lightbox on click, but only if the image actually loaded.
      // Existing onerror handlers hide failed images (display:none) and
      // show a placeholder instead — skip those rather than opening an
      // empty lightbox.
      fig.addEventListener('click', function () {
        if (img.style.display === 'none') return;
        if (img.complete && img.naturalWidth === 0) return;
        openLightbox(i);
      });
      fig.style.cursor = 'zoom-in';
    });
  }

  function buildLightboxDOM() {
    lightboxEl = document.createElement('div');
    lightboxEl.className = 'agp-lightbox';
    lightboxEl.setAttribute('role', 'dialog');
    lightboxEl.setAttribute('aria-modal', 'true');
    lightboxEl.setAttribute('aria-label', 'Image viewer');
    lightboxEl.innerHTML =
      '<button class="agp-lightbox-close" aria-label="Close">&times;</button>' +
      '<button class="agp-lightbox-prev" aria-label="Previous image">&#8249;</button>' +
      '<button class="agp-lightbox-next" aria-label="Next image">&#8250;</button>' +
      '<div class="agp-lightbox-stage">' +
        '<div class="agp-lightbox-loading">' +
          '<div class="agp-bronze-diamond"></div>' +
        '</div>' +
        '<img class="agp-lightbox-img" alt="">' +
        '<div class="agp-lightbox-caption"></div>' +
        '<div class="agp-lightbox-counter"></div>' +
      '</div>';
    document.body.appendChild(lightboxEl);

    imgEl = lightboxEl.querySelector('.agp-lightbox-img');
    loadingEl = lightboxEl.querySelector('.agp-lightbox-loading');
    captionEl = lightboxEl.querySelector('.agp-lightbox-caption');
    counterEl = lightboxEl.querySelector('.agp-lightbox-counter');

    lightboxEl.querySelector('.agp-lightbox-close').addEventListener('click', closeLightbox);
    lightboxEl.querySelector('.agp-lightbox-prev').addEventListener('click', function () { showRelative(-1); });
    lightboxEl.querySelector('.agp-lightbox-next').addEventListener('click', function () { showRelative(1); });

    // Click outside the image (on the stage/backdrop) closes it
    lightboxEl.addEventListener('click', function (e) {
      if (e.target === lightboxEl || e.target.classList.contains('agp-lightbox-stage')) {
        closeLightbox();
      }
    });

    // Swipe support
    lightboxEl.addEventListener('touchstart', function (e) {
      touchStartX = e.changedTouches[0].clientX;
    }, { passive: true });
    lightboxEl.addEventListener('touchend', function (e) {
      if (touchStartX === null) return;
      var dx = e.changedTouches[0].clientX - touchStartX;
      if (Math.abs(dx) > 50) showRelative(dx > 0 ? -1 : 1);
      touchStartX = null;
    }, { passive: true });
  }

  function openLightbox(index) {
    currentIndex = index;
    lightboxEl.classList.add('agp-lightbox--open');
    document.body.style.overflow = 'hidden';
    renderCurrent();
  }

  function closeLightbox() {
    lightboxEl.classList.remove('agp-lightbox--open');
    document.body.style.overflow = '';
  }

  function showRelative(delta) {
    currentIndex = (currentIndex + delta + items.length) % items.length;
    renderCurrent();
  }

  function renderCurrent() {
    var item = items[currentIndex];
    loadingEl.classList.add('agp-lightbox-loading--active');
    imgEl.classList.remove('agp-lightbox-img--loaded');
    captionEl.innerHTML = item.captionHTML;
    counterEl.textContent = (currentIndex + 1) + ' / ' + items.length;

    var preload = new Image();
    preload.onload = function () {
      imgEl.src = item.src;
      imgEl.alt = item.alt;
      loadingEl.classList.remove('agp-lightbox-loading--active');
      imgEl.classList.add('agp-lightbox-img--loaded');
    };
    preload.onerror = function () {
      loadingEl.classList.remove('agp-lightbox-loading--active');
      captionEl.innerHTML = '<em>This image could not be loaded.</em>';
    };
    preload.src = item.src;

    // Preload neighbours so prev/next feels instant
    [1, -1].forEach(function (d) {
      var n = items[(currentIndex + d + items.length) % items.length];
      var pre = new Image();
      pre.src = n.src;
    });
  }

  function init() {
    items = [];
    if (!document.querySelector('.gallery-item')) return; // nothing to wire up yet
    buildItemList();
    if (items.length === 0) return;
    if (!lightboxEl) buildLightboxDOM();
  }

  // Expose for pages that inject gallery content dynamically (e.g. after a
  // password-gate decrypts and inserts the gallery HTML) so they can call
  // window.AGPGalleryLightbox.init() once the content actually exists.
  window.AGPGalleryLightbox = { init: init };

  document.addEventListener('keydown', function (e) {
    if (!lightboxEl || !lightboxEl.classList.contains('agp-lightbox--open')) return;
    if (e.key === 'Escape') closeLightbox();
    if (e.key === 'ArrowLeft') showRelative(-1);
    if (e.key === 'ArrowRight') showRelative(1);
  });

  document.addEventListener('DOMContentLoaded', init);
})();
