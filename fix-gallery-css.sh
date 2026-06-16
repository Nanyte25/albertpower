#!/usr/bin/env bash
# Run from inside ~/Downloads/albert-power-jekyll 4
# Fixes gallery image sizing and family relationships

set -e
[[ -f "_config.yml" ]] || { echo "Run from inside the repo folder"; exit 1; }

# ── Fix gallery image height ────────────────────────────────────────
python3 << 'PYEOF'
import re

with open('assets/css/main.css', 'r') as f:
    css = f.read()

# Replace the aspect-ratio 3/4 with fixed height 220px
old = """.gallery-img-wrap {
  width: 100%;
  aspect-ratio: 3/4;
  background: var(--shadow);
  overflow: hidden;
  position: relative;
  margin-bottom: 0.6rem;
}

.gallery-img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform 0.4s ease;
}"""

new = """.gallery-img-wrap {
  width: 100%;
  height: 220px;
  background: var(--shadow);
  overflow: hidden;
  position: relative;
  margin-bottom: 0.6rem;
}

.gallery-img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center top;
  display: block;
  transition: transform 0.4s ease;
}"""

if old in css:
    css = css.replace(old, new)
    print("✓ Gallery aspect-ratio fixed → fixed height 220px")
else:
    # Already patched or different version — append override
    css += "\n/* Gallery fix — consistent height */\n.gallery-img-wrap { height: 220px !important; aspect-ratio: unset !important; }\n.gallery-img-wrap img { object-position: center top; }\n"
    print("✓ Gallery fix appended as override")

with open('assets/css/main.css', 'w') as f:
    f.write(css)
PYEOF

# ── Fix About section — correct title ──────────────────────────────
python3 << 'PYEOF'
with open('index.html', 'r') as f:
    html = f.read()

# Fix title description
html = html.replace(
    'I am a Senior Site Reliability Engineer at Red Hat, based in Waterford, Ireland,\n          and a postgraduate student in Artificial Intelligence at SETU.',
    'I am a Senior Site Reliability Engineer at Red Hat, based in Waterford, Ireland, and a postgraduate student in Artificial Intelligence at SETU Waterford.'
)

# Fix family relationships in about section
html = html.replace(
    'Power worked at the hinge point of modern Irish history. He made death masks of Collins,\n          Griffith, Brugha, and Childers — four of the principal figures of the independence struggle —\n          within months of each other in 1922.',
    'My great-grandfather worked at the hinge point of modern Irish history. He made death masks of Collins, Griffith, Brugha, and Childers — four principal figures of the independence struggle — within months of each other in 1922.'
)

with open('index.html', 'w') as f:
    f.write(html)
print("✓ index.html about section updated")
PYEOF

git add assets/css/main.css index.html
git commit -m "fix: gallery image height, correct about section copy"
git push
echo ""
echo "✓ Done — gallery images will display at consistent 220px height"
echo "  Check: https://albertpower.org/gallery/"
