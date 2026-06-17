#!/usr/bin/env bash
set -e
[[ -f "_config.yml" ]] || { echo "Run from inside the repo"; exit 1; }

mkdir -p map _data

cat > _data/sculpture_map.yml << 'EOF'
- name: "National Museum of Ireland — Collins Barracks"
  lat: 53.3489404
  lng: -6.2863653
  works: ["Death Mask of Michael Collins (1922)", "Death Mask of Arthur Griffith (1922)", "Portrait Bust of Countess Markievicz (1932)"]
  address: "Benburb St, Stoneybatter, Dublin, D07 XKV4"
  maps_url: "https://www.google.com/maps/place/?q=place_id:ChIJS7Q-vDEMZ0gRSvVL0e06s1k"
- name: "Cathal Brugha Barracks"
  lat: 53.3268475
  lng: -6.2706372
  works: ["Death Mask of Cathal Brugha (1922)"]
  address: "Military Road, Rathmines, Dublin, D06 RX00"
  maps_url: "https://www.google.com/maps/place/?q=place_id:ChIJJ5fiTRwMZ0gRnLaDUShe9ME"
- name: "Eyre Square, Galway"
  lat: 53.274693
  lng: -9.0486546
  works: ["Pádraic Ó Conaire memorial (1935)"]
  address: "Eyre Square, Galway"
  maps_url: "https://www.google.com/maps/place/?q=place_id:ChIJV8npfO-WW0gR_ruRSnRRtMk"
- name: "Gresham Hotel, O'Connell Street"
  lat: 53.3515365
  lng: -6.2606459
  works: ["Decorative facade — urns, Coat of Arms, sphinxes, festoons (1926)"]
  address: "23 O'Connell Street Upper, Dublin, D01 C3W7"
  maps_url: "https://www.google.com/maps/place/?q=place_id:ChIJHQz3kIYOZ0gR_u9dPKm4aAE"
- name: "Government Buildings, Merrion Street"
  lat: 53.3393365
  lng: -6.2539268
  works: ["Figure of Science (1911)"]
  address: "Merrion St Upper, Dublin 2, D02 R583"
  maps_url: "https://www.google.com/maps/place/?q=place_id:ChIJbRmx55kOZ0gRBtjQrOd_HXM"
- name: "Glasnevin Cemetery"
  lat: 53.3697293
  lng: -6.2773294
  works: ["Albert Power Monument", "Downes Monument (1925)", "Archbishop Walsh Tomb (1929)", "Cait O'Kelly Memorial (1936)", "McKernan Memorial (1937, 1940)"]
  address: "Finglas Rd, Glasnevin, Dublin, D11 XA32"
  maps_url: "https://www.google.com/maps/place/?q=place_id:ChIJTf7MoOGZXUgRwg549JX1Nu0"
- name: "Leinster House (Dáil Éireann)"
  lat: 53.3405901
  lng: -6.2539816
  works: ["Portrait of Thomas Davis (1945) — Power's final work"]
  address: "Kildare St, Dublin 2, D02 TK75"
  maps_url: "https://www.google.com/maps/place/?q=place_id:ChIJk8HRHJoOZ0gRkE88yCQIObM"
- name: "National Gallery of Ireland"
  lat: 53.3408887
  lng: -6.2522962
  works: ["Portrait Bust of Michael Collins (1936)"]
  address: "Merrion Square W, Dublin 2, D02 K303"
  maps_url: "https://www.google.com/maps/place/?q=place_id:ChIJb1ecSpcOZ0gRMQ3w0Qyz_Vg"
- name: "Trinity College Library"
  lat: 53.3439553
  lng: -6.2566368
  works: ["Marble replica of Roubiliac's bust of Jonathan Swift (1909–10, after the 1745 original held here)"]
  address: "College Green, Dublin 2, D02 VR66"
  maps_url: "https://www.google.com/maps/place/?q=place_id:ChIJVdIER5sOZ0gRbNBq2VcIW9Q"
EOF
echo "✓ _data/sculpture_map.yml"

cat > map/index.html << 'EOF'
---
layout: default
title: "Sculpture Map"
description: "Interactive map of Albert G. Power's works across Ireland."
permalink: /map/
---
<header class="page-header">
  <div class="page-header-inner">
    <p class="hero-eyebrow">Archive</p>
    <h1 class="page-title">Sculpture Map</h1>
    <p class="page-subtitle">Where his works can be found today</p>
  </div>
</header>
<main class="map-main">
  <div class="section-inner">
    <p class="map-intro">Albert G. Power's works are held across museums, public squares, cemeteries, and government buildings throughout Ireland. Click a pin for details, or open in Google Maps to plan a visit. This is a working document — more locations will be added as research continues.</p>
    <div id="sculpture-map" class="sculpture-map-embed" role="img" aria-label="Map of Albert G. Power sculpture locations"></div>
    <div class="map-location-list">
      <h2 class="map-list-title">All Locations</h2>
      {% for loc in site.data.sculpture_map %}
      <article class="map-location-card">
        <h3>{{ loc.name }}</h3>
        <p class="map-location-address">{{ loc.address }}</p>
        <ul class="map-works-list">
          {% for work in loc.works %}<li>{{ work }}</li>{% endfor %}
        </ul>
        <a href="{{ loc.maps_url }}" target="_blank" rel="noopener noreferrer" class="map-directions-link">Open in Google Maps →</a>
      </article>
      {% endfor %}
    </div>
  </div>
</main>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var locations = {{ site.data.sculpture_map | jsonify }};
  var map = L.map('sculpture-map', { scrollWheelZoom: false }).setView([53.35, -6.7], 7);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 18
  }).addTo(map);
  var bronzeIcon = L.divIcon({ className: 'custom-map-pin', html: '<div class="pin-dot"></div>', iconSize: [18, 18], iconAnchor: [9, 9] });
  var bounds = [];
  locations.forEach(function (loc) {
    var worksHtml = loc.works.map(function (w) { return '<li>' + w + '</li>'; }).join('');
    var popupHtml = '<div class="map-popup"><strong>' + loc.name + '</strong><ul>' + worksHtml + '</ul><a href="' + loc.maps_url + '" target="_blank" rel="noopener noreferrer">Open in Google Maps →</a></div>';
    var marker = L.marker([loc.lat, loc.lng], { icon: bronzeIcon }).addTo(map);
    marker.bindPopup(popupHtml);
    bounds.push([loc.lat, loc.lng]);
  });
  if (bounds.length > 0) { map.fitBounds(bounds, { padding: [40, 40] }); }
});
</script>
EOF
echo "✓ map/index.html"

cat >> assets/css/main.css << 'EOF'

/* ── SCULPTURE MAP ── */
.map-main { padding: 3rem 1.5rem 6rem; }
.map-intro { font-family: var(--ff-quote); font-style: italic; color: var(--text-muted); font-size: 0.98rem; line-height: 1.8; max-width: 760px; margin-bottom: 2.5rem; }
.sculpture-map-embed { width: 100%; height: 480px; border: 1px solid rgba(139,115,85,0.3); margin-bottom: 3rem; background: var(--shadow); }
.custom-map-pin .pin-dot { width: 16px; height: 16px; background: var(--bronze); border: 2px solid var(--vellum); border-radius: 50%; box-shadow: 0 1px 4px rgba(0,0,0,0.4); }
.map-popup { font-family: var(--ff-display); font-size: 0.85rem; line-height: 1.5; min-width: 200px; }
.map-popup strong { display: block; margin-bottom: 0.4rem; color: var(--ink); font-size: 0.95rem; }
.map-popup ul { margin: 0.4rem 0; padding-left: 1.1rem; }
.map-popup li { margin-bottom: 0.2rem; }
.map-popup a { color: var(--moss); text-decoration: none; font-size: 0.8rem; }
.map-list-title { font-family: var(--ff-display); font-size: 1.6rem; font-weight: 400; color: var(--ink); margin-bottom: 1.5rem; padding-bottom: 0.75rem; border-bottom: 1px solid rgba(139,115,85,0.3); }
.map-location-card { padding: 1.5rem 0; border-bottom: 1px solid rgba(139,115,85,0.15); }
.map-location-card h3 { font-family: var(--ff-display); font-size: 1.15rem; font-weight: 600; color: var(--ink); margin-bottom: 0.25rem; }
.map-location-address { font-size: 0.82rem; color: var(--text-muted); margin-bottom: 0.75rem; }
.map-works-list { list-style: none; margin-bottom: 0.75rem; }
.map-works-list li { font-size: 0.9rem; color: var(--text-primary); padding: 0.2rem 0 0.2rem 1rem; border-left: 2px solid var(--bronze); margin-bottom: 0.3rem; }
.map-directions-link { font-family: var(--ff-display); font-size: 0.8rem; letter-spacing: 0.06em; color: var(--moss); text-decoration: none; border-bottom: 1px solid rgba(74,103,65,0.3); }
@media (max-width: 700px) { .sculpture-map-embed { height: 360px; } }
EOF
echo "✓ Map CSS appended"

sed -i '' 's|<li><a href="{{ '"'"'/gallery/'"'"' | relative_url }}" {% if page.url contains '"'"'/gallery/'"'"' %}aria-current="page"{% endif %}>Gallery</a></li>|<li><a href="{{ '"'"'/gallery/'"'"' \| relative_url }}" {% if page.url contains '"'"'/gallery/'"'"' %}aria-current="page"{% endif %}>Gallery</a></li>\n      <li><a href="{{ '"'"'/map/'"'"' \| relative_url }}" {% if page.url contains '"'"'/map/'"'"' %}aria-current="page"{% endif %}>Map</a></li>|' _includes/nav.html

grep -c "map/" _includes/nav.html && echo "✓ Nav updated" || echo "⚠ Nav update may have failed, check manually"

git add -A
git status --short
git commit -m "feat: interactive sculpture map with 9 confirmed locations"
git push
echo ""
echo "✓ Done — check https://albertpower.org/map/ once build completes"
