// ── Albert G. Power RHA — main.js ──

// ── 1. Mobile nav toggle ───────────────────────────────────────────
(function () {
  const toggle = document.querySelector('.nav-toggle');
  const links  = document.querySelector('.nav-links');
  if (!toggle || !links) return;
  toggle.addEventListener('click', function () {
    const expanded = this.getAttribute('aria-expanded') === 'true';
    this.setAttribute('aria-expanded', String(!expanded));
    links.classList.toggle('is-open', !expanded);
  });
  links.querySelectorAll('a').forEach(function (a) {
    a.addEventListener('click', function () {
      toggle.setAttribute('aria-expanded', 'false');
      links.classList.remove('is-open');
    });
  });
  document.addEventListener('click', function (e) {
    if (!toggle.contains(e.target) && !links.contains(e.target)) {
      toggle.setAttribute('aria-expanded', 'false');
      links.classList.remove('is-open');
    }
  });
})();

// ── 2. Scroll-reveal ──────────────────────────────────────────────
(function () {
  if (!('IntersectionObserver' in window)) return;
  var targets = document.querySelectorAll(
    '.timeline-item, .blog-card, .blog-index-card, .work-card, .work-index-card, .bio-col'
  );
  targets.forEach(function (el) { el.classList.add('js-reveal'); });
  var io = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        io.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });
  targets.forEach(function (el) { io.observe(el); });
})();

// ── 3. Dark / Light Theme Toggle ──────────────────────────────────
(function () {
  var STORAGE_KEY = 'agp-theme';
  var root = document.documentElement;

  function applyTheme(theme) {
    root.setAttribute('data-theme', theme);
    localStorage.setItem(STORAGE_KEY, theme);
    var btn = document.getElementById('theme-toggle');
    if (btn) {
      btn.setAttribute('aria-label', theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode');
      btn.textContent = theme === 'dark' ? '☀' : '☾';
    }
  }

  // On load — respect saved preference or system preference
  var saved = localStorage.getItem(STORAGE_KEY);
  if (saved) {
    applyTheme(saved);
  } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    applyTheme('dark');
  } else {
    applyTheme('light');
  }

  document.addEventListener('DOMContentLoaded', function () {
    var btn = document.getElementById('theme-toggle');
    if (!btn) return;
    var current = root.getAttribute('data-theme') || 'light';
    btn.textContent = current === 'dark' ? '☀' : '☾';
    btn.addEventListener('click', function () {
      var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      applyTheme(next);
    });
  });
})();

// ── 4. Language Switcher (EN / GA / FI) ───────────────────────────
// Translations injected at build time from _data/i18n.yml via _layouts/default.html
// The global AGP_I18N object is set in a <script> tag in the <head>.
(function () {
  var STORAGE_KEY = 'agp-lang';

  function applyLang(lang) {
    var translations = window.AGP_I18N;
    if (!translations || !translations[lang]) return;
    var t = translations[lang];

    localStorage.setItem(STORAGE_KEY, lang);

    // Set lang attribute on <html> for accessibility + CSS hooks
    document.documentElement.setAttribute('lang',
      lang === 'ga' ? 'ga' : lang === 'fi' ? 'fi' : 'en');

    // Update all elements with data-i18n attribute
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var key = el.getAttribute('data-i18n');
      if (t[key] !== undefined) {
        // Use innerHTML for elements that may contain HTML entities
        // but textContent is safer — our strings are plain text
        el.textContent = t[key];
      }
    });

    // Update <html lang> and <title> on inner pages
    var titleEl = document.querySelector('title');
    if (titleEl) {
      var baseTitle = titleEl.getAttribute('data-title-base') || titleEl.textContent;
      if (!titleEl.getAttribute('data-title-base')) {
        titleEl.setAttribute('data-title-base', baseTitle);
      }
      // Append language suffix for non-English
      if (lang === 'ga') {
        titleEl.textContent = baseTitle.replace(/ — Albert G\. Power RHA$/, '') + ' — Albert G. Power RHA | Gaeilge';
      } else if (lang === 'fi') {
        titleEl.textContent = baseTitle.replace(/ — Albert G\. Power RHA$/, '') + ' — Albert G. Power RHA | Suomi';
      } else {
        titleEl.textContent = baseTitle;
      }
    }

    // Update active button state
    document.querySelectorAll('.lang-btn').forEach(function (btn) {
      btn.classList.toggle('lang-btn--active', btn.dataset.lang === lang);
      btn.setAttribute('aria-pressed', String(btn.dataset.lang === lang));
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    var saved = localStorage.getItem(STORAGE_KEY) || 'en';
    applyLang(saved);

    document.querySelectorAll('.lang-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        applyLang(this.dataset.lang);
      });
    });
  });
})();
