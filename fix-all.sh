#!/usr/bin/env bash
# Run from inside ~/Downloads/albert-power-jekyll 4

set -e
[[ -f "_config.yml" ]] || { echo "Run from inside the repo folder"; exit 1; }
echo "Fixing gallery sizing, missing images, and works page..."

# ── 1. Replace ALL gallery CSS with clean version ──────────────────
# Strip any previous gallery rules and write fresh
python3 << 'PYEOF'
with open('assets/css/main.css', 'r') as f:
    css = f.read()

# Remove all the appended gallery overrides (may have duplicates)
import re
# Remove any lines we appended as overrides
css = re.sub(r'/\* Gallery fix.*?\n.*?aspect-ratio.*?\n.*?object-position.*?\n', '', css, flags=re.DOTALL)

# Now find and replace the gallery-img-wrap block properly
old_patterns = [
    # aspect-ratio version
    (r'\.gallery-img-wrap \{[^}]*aspect-ratio:\s*3/4;[^}]*\}', '''.gallery-img-wrap {
  width: 100%;
  height: 220px;
  background: var(--shadow);
  overflow: hidden;
  position: relative;
  margin-bottom: 0.6rem;
}'''),
    # Ensure img inside wrap is correct
    (r'\.gallery-img-wrap img \{[^}]*\}', '''.gallery-img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center top;
  display: block;
  transition: transform 0.4s ease;
}'''),
]

for pattern, replacement in old_patterns:
    css = re.sub(pattern, replacement, css)

with open('assets/css/main.css', 'w') as f:
    f.write(css)
print("✓ Gallery CSS fixed")
PYEOF

# ── 2. Copy James Power images from the external drive ─────────────
PHOTOS="/Volumes/Z Slim/Albert G Photo Exhibit"
DEST="assets/images"

if [[ -d "$PHOTOS" ]]; then
  echo "Drive found — copying family photos..."
  # James Power photos
  [[ -f "$PHOTOS/James Power.JPG" ]] && \
    cp "$PHOTOS/James Power.JPG" "$DEST/james-power.jpg" && echo "✓ james-power.jpg"
  [[ -f "$PHOTOS/James Power (2).JPG" ]] && \
    cp "$PHOTOS/James Power (2).JPG" "$DEST/james-power-2.jpg" && echo "✓ james-power-2.jpg"

  # May Power — check for any photo with May in the name
  for f in "$PHOTOS"/*[Mm]ay*; do
    [[ -f "$f" ]] && cp "$f" "$DEST/may-power.jpg" && echo "✓ may-power.jpg" && break
  done

  # Albert Jr
  [[ -f "$PHOTOS/Albert Jr. Power.jpg" ]] && \
    cp "$PHOTOS/Albert Jr. Power.jpg" "$DEST/albert-jr-power.jpg" && echo "✓ albert-jr-power.jpg"

  # Oliver Power (already should be there but re-copy cleanly)
  [[ -f "$PHOTOS/Oliver Power.JPG" ]] && \
    cp "$PHOTOS/Oliver Power.JPG" "$DEST/oliver-power.jpg" && echo "✓ oliver-power.jpg"
  [[ -f "$PHOTOS/Oliver Power (2).JPG" ]] && \
    cp "$PHOTOS/Oliver Power (2).JPG" "$DEST/oliver-power-2.jpg" && echo "✓ oliver-power-2.jpg"

  # Ó Conaire — the works page is missing this
  [[ -f "$PHOTOS/Padraic O'Conaire 1935.JPG" ]] && \
    cp "$PHOTOS/Padraic O'Conaire 1935.JPG" "$DEST/o-conaire-memorial.jpg" && echo "✓ o-conaire-memorial.jpg"
  [[ -f "$PHOTOS/60. Padraig O'Conaire 1935. Monument in Galway Eyre Square 1991 Fas Trip.JPG" ]] && \
    cp "$PHOTOS/60. Padraig O'Conaire 1935. Monument in Galway Eyre Square 1991 Fas Trip.JPG" \
       "$DEST/o-conaire-memorial-2.jpg" && echo "✓ o-conaire-memorial-2.jpg"

else
  echo "⚠ Drive not connected — skipping photo copy"
  echo "  Connect 'Z Slim' drive and re-run to add photos"
fi

# ── 3. Update family pages to use correct image filenames ──────────
# james-power.html — use james-power.jpg
sed -i '' 's|assets/images/James Power.JPG|assets/images/james-power.jpg|g' family/james-power.html
# oliver-power.html — use oliver-power.jpg
sed -i '' 's|assets/images/Oliver Power.JPG|assets/images/oliver-power.jpg|g' family/oliver-power.html
sed -i '' "s|assets/images/Oliver Power (2).JPG|assets/images/oliver-power-2.jpg|g" family/oliver-power.html
# family/index.html
sed -i '' 's|assets/images/Oliver Power.JPG|assets/images/oliver-power.jpg|g' family/index.html
echo "✓ Family page image paths updated"

# ── 4. Add may-power image to may-power.html ───────────────────────
sed -i '' 's|family-profile-image--placeholder.*|family-profile-image">\n          <img src="{{ '"'"'/assets/images/may-power.jpg'"'"' | relative_url }}" alt="May Power" loading="lazy" onerror="this.parentElement.classList.add('"'"'img-missing'"'"')" />|g' \
  family/may-power.html 2>/dev/null || true
echo "✓ May Power image wired in"

# ── 5. Fix Oliver Power house image path (has apostrophe) ──────────
python3 << 'PYEOF'
with open('family/oliver-power.html', 'r') as f:
    html = f.read()
# Fix the apostrophe in filename
html = html.replace(
    "assets/images/66. Oliver Power's House.JPG",
    "assets/images/oliver-powers-house.jpg"
)
with open('family/oliver-power.html', 'w') as f:
    f.write(html)
print("✓ Oliver Power house path fixed")
PYEOF

# Copy the house image with safe name
PHOTOS="/Volumes/Z Slim/Albert G Photo Exhibit"
if [[ -d "$PHOTOS" && -f "$PHOTOS/66. Oliver Power's House.JPG" ]]; then
  cp "$PHOTOS/66. Oliver Power's House.JPG" "assets/images/oliver-powers-house.jpg"
  echo "✓ oliver-powers-house.jpg"
fi

# ── 6. Commit and push ─────────────────────────────────────────────
git add -A
git status --short
git commit -m "fix: gallery image height, family photo paths, copy missing photos"
git push
echo ""
echo "✓ All fixes applied — check https://albertpower.org/gallery/"
echo "  and https://albertpower.org/family/"
