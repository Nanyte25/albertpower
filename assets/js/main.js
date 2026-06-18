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
(function () {
  var STORAGE_KEY = 'agp-lang';

  var translations = {
    en: {
      nav_biography: 'Biography',
      nav_works: 'Works',
      nav_gallery: 'Gallery',
      nav_map: 'Map',
      nav_family: 'Family',
      nav_connections: 'Connections',
      nav_publications: 'Publications',
      nav_writing: 'Writing',
      nav_contact: 'Contact',
      hero_eyebrow: 'Irish Sculptor · 1881–1945',
      hero_subtitle: 'Royal Hibernian Academician',
      footer_rights: '© 2026 Mark Freer. All rights reserved.',
    },
    ga: {
      nav_biography: 'Beathaisnéis',
      nav_works: 'Saothair',
      nav_gallery: 'Gailearaí',
      nav_map: 'Léarscáil',
      nav_family: 'Teaghlach',
      nav_connections: 'Naisc',
      nav_publications: 'Foilseacháin',
      nav_writing: 'Scríbhneoireacht',
      nav_contact: 'Teagmháil',
      hero_eyebrow: 'Dealbhóir Éireannach · 1881–1945',
      hero_subtitle: 'Acadóir Ríoga Hibernach',
      footer_rights: '© 2026 Mark Freer. Gach ceart ar cosaint.',
    },
    fi: {
      nav_biography: 'Elämäkerta',
      nav_works: 'Teokset',
      nav_gallery: 'Galleria',
      nav_map: 'Kartta',
      nav_family: 'Perhe',
      nav_connections: 'Yhteydet',
      nav_publications: 'Julkaisut',
      nav_writing: 'Kirjoitukset',
      nav_contact: 'Yhteystiedot',
      hero_eyebrow: 'Irlantilainen kuvanveistäjä · 1881–1945',
      hero_subtitle: 'Kuninkaallinen Hibernian Akatemian jäsen',
      footer_rights: '© 2026 Mark Freer. Kaikki oikeudet pidätetään.',
    }
  };

  function applyLang(lang) {
    if (!translations[lang]) return;
    localStorage.setItem(STORAGE_KEY, lang);
    document.documentElement.setAttribute('lang', lang === 'ga' ? 'ga' : lang === 'fi' ? 'fi' : 'en');
    var t = translations[lang];

    // Nav links
    var navMap = {
      'Biography': t.nav_biography,
      'Beathaisnéis': t.nav_biography,
      'Elämäkerta': t.nav_biography,
      'Works': t.nav_works,
      'Saothair': t.nav_works,
      'Teokset': t.nav_works,
      'Gallery': t.nav_gallery,
      'Gailearaí': t.nav_gallery,
      'Galleria': t.nav_gallery,
      'Map': t.nav_map,
      'Léarscáil': t.nav_map,
      'Kartta': t.nav_map,
      'Family': t.nav_family,
      'Teaghlach': t.nav_family,
      'Perhe': t.nav_family,
      'Connections': t.nav_connections,
      'Naisc': t.nav_connections,
      'Yhteydet': t.nav_connections,
      'Publications': t.nav_publications,
      'Foilseacháin': t.nav_publications,
      'Julkaisut': t.nav_publications,
      'Writing': t.nav_writing,
      'Scríbhneoireacht': t.nav_writing,
      'Kirjoitukset': t.nav_writing,
      'Contact': t.nav_contact,
      'Teagmháil': t.nav_contact,
      'Yhteystiedot': t.nav_contact,
    };

    document.querySelectorAll('.nav-links > li > a').forEach(function(a) {
      var txt = a.textContent.trim();
      if (navMap[txt]) a.textContent = navMap[txt];
    });

    // Hero eyebrow
    var eyebrow = document.querySelector('.hero-eyebrow');
    if (eyebrow) eyebrow.textContent = t.hero_eyebrow;

    // Hero subtitle
    var subtitle = document.querySelector('.hero-subtitle');
    if (subtitle) subtitle.textContent = t.hero_subtitle;

    // Footer
    var footer = document.querySelector('.footer-copy');
    if (footer) footer.textContent = t.footer_rights;

    // Update language button states
    document.querySelectorAll('.lang-btn').forEach(function(btn) {
      btn.classList.toggle('lang-btn--active', btn.dataset.lang === lang);
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    var saved = localStorage.getItem(STORAGE_KEY) || 'en';
    applyLang(saved);

    document.querySelectorAll('.lang-btn').forEach(function(btn) {
      btn.addEventListener('click', function() {
        applyLang(this.dataset.lang);
      });
    });
  });
})();
