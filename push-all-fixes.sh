#!/usr/bin/env bash
# Run from inside ~/Downloads/albert-power-jekyll 4
# Pushes ALL pending fixes in one go

set -e
[[ -f "_config.yml" ]] || { echo "Run from inside the repo"; exit 1; }

echo "Applying all fixes..."

# ── 1. Fix gallery CSS completely — rewrite entire block ───────────
python3 << 'PYEOF'
import re

with open('assets/css/main.css', 'r') as f:
    css = f.read()

# Remove ALL existing gallery-img-wrap rules and any appended overrides
css = re.sub(r'/\* Gallery fix[^\*]*\*/\s*\.gallery-img-wrap[^}]+\}[^}]+\}[^}]+\}', '', css)
css = re.sub(r'\.gallery-img-wrap \{[^}]+\}', '', css)
css = re.sub(r'\.gallery-img-wrap img \{[^}]+\}', '', css)
css = re.sub(r'\.gallery-item:hover \.gallery-img-wrap img[^}]+\}', '', css)

# Inject clean gallery rules right before .img-placeholder
clean_rules = """.gallery-img-wrap {
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
}
.gallery-item:hover .gallery-img-wrap img { transform: scale(1.03); }

"""
css = css.replace('.img-placeholder {', clean_rules + '.img-placeholder {')

with open('assets/css/main.css', 'w') as f:
    f.write(css)
print("✓ Gallery CSS: clean 220px height rules injected")
PYEOF

# ── 2. Fix homepage index.html ─────────────────────────────────────
# The current live index.html still has the old SVG placeholder hero.
# Rewrite it with the Capuchin Archive image as hero.
cat > index.html << 'INDEXEOF'
---
layout: default
title: "Albert G. Power RHA — Irish Sculptor 1881–1945"
description: "A memorial archive dedicated to Albert George Power RHA, one of the foremost Irish sculptors of the twentieth century."
---

<header class="hero" role="banner">
  <div class="hero-content">
    <p class="hero-eyebrow">Irish Sculptor · 1881–1945</p>
    <h1 class="hero-title">Albert George<br><em>Power</em></h1>
    <p class="hero-subtitle">Royal Hibernian Academician</p>
    {% include celtic-rule.html %}
    <p class="hero-body">Carver of memory. Caster of a nation's grief and pride in bronze and stone. From the lanes of Dublin to the squares of Connacht, Power's sculptures stand as quiet custodians of the Irish twentieth century.</p>
    <a class="hero-cta" href="#biography">Discover his world</a>
  </div>
  <div class="hero-image-frame">
    <img
      src="https://catholicarchives.ie/uploads/r/irish-capuchin-archives-2/b/9/c/b9cc9845d5323040e8aaf6588ec45a737cfaab42af8f406e8aff59b0289f1b07/CA_CP-3-16-8-20-4.jpg"
      alt="Albert G. Power at work in his studio. Photograph courtesy Irish Capuchin Archives."
      class="hero-photo"
    />
    <p class="hero-caption">Albert G. Power at work in his studio<br><em>Courtesy Irish Capuchin Archives, Dublin</em></p>
  </div>
</header>

<section class="pull-quote-section" aria-label="Opening quotation">
  <div class="celtic-rule"></div>
  <blockquote class="pull-quote">
    <p>"He brought to his work a profound understanding of the Irish character — a sculptor not of heroic posture but of quiet, enduring humanity."</p>
    <cite>— Contemporary critical account, 1942</cite>
  </blockquote>
  <div class="celtic-rule"></div>
</section>

<section class="section biography" id="biography" aria-labelledby="bio-heading">
  <div class="section-inner">
    <div class="section-header">
      <span class="section-label" aria-hidden="true">I</span>
      <h2 class="section-title" id="bio-heading">The Man &amp; His Craft</h2>
    </div>
    <div class="bio-columns">
      <div class="bio-col bio-col--lead">
        <h3>Origins &amp; Formation</h3>
        <p>Albert George Power was born in Dublin in 1881. He trained at the Dublin Metropolitan School of Art under John Hughes and Oliver Sheppard, before studying at the Royal College of Art in London under Edouard Lantéri.</p>
        <p>Power absorbed the naturalism of his teachers while developing a quieter, more contemplative register — reaching always for the particular rather than the allegorical.</p>
        <figure class="bio-image">
          <img src="https://catholicarchives.ie/uploads/r/irish-capuchin-archives-2/d/9/2/d92e752038c424dec0f476ea3180864af99d1f3d4e1dc5d2ce313882b768096a/CA_CP-3-16-8-20-1.jpg"
               alt="Albert G. Power. Irish Capuchin Archives." loading="lazy" />
          <figcaption>Albert G. Power RHA · 1881–1945<br><em>Courtesy Irish Capuchin Archives</em></figcaption>
        </figure>
      </div>
      <div class="bio-col">
        <h3>The Revolution &amp; Its Commissions</h3>
        <p>Power worked at the hinge point of modern Irish history. In the summer of 1922 alone he made death masks of Cathal Brugha, Arthur Griffith, Michael Collins, and Erskine Childers — four leaders dead within months of each other. No other sculptor was trusted so completely across the fault lines of the Civil War.</p>
        <p>Elected a full member of the Royal Hibernian Academy in 1919, he exhibited there from 1906 until his death in 1945.</p>
        <figure class="bio-image">
          <img src="{{ '/assets/images/collins-death-mask.jpg' | relative_url }}"
               alt="Death mask of Michael Collins by Albert G. Power, 1922" loading="lazy"
               onerror="this.src='https://catholicarchives.ie/uploads/r/irish-capuchin-archives-2/8/d/b/8db9a4d9c2a05741f7af2c6b37c46ed514071b2f49bab1493f6abe5c44ee85e1/CA_CP-3-16-8-20-2.jpg'" />
          <figcaption>Death Mask of Michael Collins · 22 August 1922</figcaption>
        </figure>
      </div>
      <div class="bio-col">
        <h3>Legacy in Stone &amp; Bronze</h3>
        <p>Power worked in Portland stone and cast bronze, often overseeing the casting himself. His ecclesiastical commissions for churches across Ireland are among the finest devotional sculpture of the period.</p>
        <p>He died in 1945. The definitive scholarly account of his career is Judith Hill's <em>Albert Power RHA 1881–1945</em> (Irish Academic Press, 2012). His funeral records are held at the Irish Capuchin Archives, Dublin.</p>
        <figure class="bio-image">
          <img src="https://catholicarchives.ie/uploads/r/irish-capuchin-archives-2/b/e/7/be78de9163f20ec1ad49fcb36816d165a41758a8b206f92deb835bf7bad2199f/CA_CP-3-16-8-20-5.jpg"
               alt="Albert Power at an exhibition. Irish Capuchin Archives." loading="lazy" />
          <figcaption>Albert G. Power at an exhibition<br><em>Courtesy Irish Capuchin Archives</em></figcaption>
        </figure>
      </div>
    </div>
  </div>
</section>

<section class="section works" id="works" aria-labelledby="works-heading">
  <div class="section-inner">
    <div class="section-header">
      <span class="section-label" aria-hidden="true">II</span>
      <h2 class="section-title" id="works-heading">Selected Works</h2>
    </div>
    <div class="works-grid">
      <article class="work-card work-card--feature">
        <div class="work-image">
          <img src="{{ '/assets/images/o-conaire-memorial.jpg' | relative_url }}"
               alt="Pádraic Ó Conaire memorial bronze, Eyre Square, Galway, 1935" loading="lazy"
               onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Padraic_O_Conaire_statue_Galway.jpg/800px-Padraic_O_Conaire_statue_Galway.jpg'" />
        </div>
        <div class="work-info">
          <span class="work-year">1935</span>
          <h3 class="work-title">Pádraic Ó Conaire</h3>
          <p class="work-medium">Bronze · Eyre Square, Galway</p>
          <p class="work-desc">Power's most beloved work. Stolen in 1999, recovered and restored — its loss became a measure of how deeply it had embedded in Galway's identity.</p>
          <a href="{{ '/works/o-conaire/' | relative_url }}" class="read-more">View work →</a>
        </div>
      </article>
      <article class="work-card">
        <div class="work-image">
          <img src="{{ '/assets/images/collins-death-mask.jpg' | relative_url }}"
               alt="Death mask of Michael Collins, 1922" loading="lazy"
               onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Michael_Collins_1922.jpg/600px-Michael_Collins_1922.jpg'" />
        </div>
        <div class="work-info">
          <span class="work-year">1922</span>
          <h3 class="work-title">Death Mask — Michael Collins</h3>
          <p class="work-medium">Plaster · National Museum of Ireland</p>
          <p class="work-desc">Made within hours of Collins's death at Béal na Bláth. The most accurate physical record of his face in existence.</p>
          <a href="{{ '/works/death-mask-michael-collins/' | relative_url }}" class="read-more">View work →</a>
        </div>
      </article>
      <article class="work-card">
        <div class="work-image">
          <img src="{{ '/assets/images/cathal-brugha-death-mask.jpg' | relative_url }}"
               alt="Death mask of Cathal Brugha, 1922" loading="lazy"
               onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Cathal_Brugha.jpg/600px-Cathal_Brugha.jpg'" />
        </div>
        <div class="work-info">
          <span class="work-year">1922</span>
          <h3 class="work-title">Death Mask — Cathal Brugha</h3>
          <p class="work-medium">Plaster · Cathal Brugha Barracks</p>
          <p class="work-desc">The first of Power's extraordinary 1922 sequence — Brugha died on 7 July, shot on O'Connell Street at the outbreak of the Civil War.</p>
          <a href="{{ '/works/death-mask-cathal-brugha/' | relative_url }}" class="read-more">View work →</a>
        </div>
      </article>
      <article class="work-card">
        <div class="work-image">
          <img src="{{ '/assets/images/gresham-hotel-facade.jpg' | relative_url }}"
               alt="Gresham Hotel decorative facade by Albert G. Power, 1926" loading="lazy"
               onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Gresham_Hotel%2C_Dublin.jpg/800px-Gresham_Hotel%2C_Dublin.jpg'" />
        </div>
        <div class="work-info">
          <span class="work-year">1926</span>
          <h3 class="work-title">Gresham Hotel Facade</h3>
          <p class="work-medium">Stone · O'Connell Street, Dublin</p>
          <p class="work-desc">Urns, Coat of Arms, Ionic capitals, six panels of festoons, and two sphinxes — seen by everyone who walks Dublin's main street.</p>
          <a href="{{ '/works/gresham-hotel/' | relative_url }}" class="read-more">View work →</a>
        </div>
      </article>
    </div>
    <div class="works-cta-row">
      <a href="{{ '/works/' | relative_url }}" class="btn-secondary">Full catalogue of works →</a>
    </div>
  </div>
</section>

<section class="section timeline-section" id="timeline" aria-labelledby="timeline-heading">
  <div class="section-inner">
    <div class="section-header">
      <span class="section-label" aria-hidden="true">III</span>
      <h2 class="section-title" id="timeline-heading">A Life in Dates</h2>
    </div>
    <ol class="timeline" role="list">
      {% for event in site.data.timeline %}
      <li class="timeline-item">
        <span class="tl-year">{{ event.year }}</span>
        <div class="tl-content">
          <h4>{{ event.title }}</h4>
          <p>{{ event.description }}</p>
        </div>
      </li>
      {% endfor %}
    </ol>
  </div>
</section>

<section class="section blog-preview" id="writing" aria-labelledby="writing-heading">
  <div class="section-inner">
    <div class="section-header">
      <span class="section-label" aria-hidden="true">IV</span>
      <h2 class="section-title" id="writing-heading">Writing &amp; Research</h2>
    </div>
    <div class="blog-grid">
      {% assign recent_posts = site.posts | limit: 3 %}
      {% for post in recent_posts %}
      <article class="blog-card {% if forloop.first %}blog-card--feature{% endif %}">
        <span class="blog-date">{{ post.category | default: "Research Notes" }} · {{ post.date | date: "%Y" }}</span>
        <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
        <p>{{ post.excerpt | strip_html | truncate: 180 }}</p>
        <a href="{{ post.url | relative_url }}" class="read-more">Read essay →</a>
      </article>
      {% endfor %}
    </div>
    <div class="blog-cta-row">
      <a href="{{ '/blog/' | relative_url }}" class="btn-secondary">All writing →</a>
    </div>
  </div>
</section>

<section class="section contact-section" id="contact" aria-labelledby="contact-heading">
  <div class="section-inner">
    <div class="section-header">
      <span class="section-label" aria-hidden="true">V</span>
      <h2 class="section-title" id="contact-heading">About This Archive</h2>
    </div>
    <div class="about-grid">
      <div class="about-text">
        <p class="contact-body">My name is <strong>Mark Freer</strong>, Senior Site Reliability Engineer at Red Hat, Waterford. Albert George Power RHA was my great-grandfather. I built this archive because his work deserves to be seen — not just by art historians and curators, but by anyone who walks past the Gresham Hotel, visits Eyre Square in Galway, or stands at the grave of Michael Collins in Glasnevin.</p>
        <p class="contact-body">Power worked at the hinge point of modern Irish history. He made death masks of Collins, Griffith, Brugha, and Childers within months of each other in 1922. He carved the facades of O'Connell Street. He made the Ó Conaire memorial that Galway wept for when it was stolen. His funeral records are held at the Irish Capuchin Archives, Dublin.</p>
        <p class="contact-body">The photographs here come from our family archive and from the Irish Capuchin Archives. If you have photographs, letters, or knowledge of works not yet recorded, I would be glad to hear from you.</p>
        <div class="about-links">
          <a href="mailto:{{ site.author.email }}" class="btn-primary">Get in touch</a>
          <a href="https://www.linkedin.com/in/markfreer/" target="_blank" rel="noopener noreferrer" class="btn-linkedin">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 0 1-2.063-2.065 2.064 2.064 0 1 1 2.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>
            Mark Freer on LinkedIn
          </a>
        </div>
      </div>
      <div class="about-image-col">
        <figure class="about-work-figure">
          <img src="https://catholicarchives.ie/uploads/r/irish-capuchin-archives-2/b/9/c/b9cc9845d5323040e8aaf6588ec45a737cfaab42af8f406e8aff59b0289f1b07/CA_CP-3-16-8-20-4.jpg"
               alt="Albert G. Power at work with assistants. Irish Capuchin Archives." loading="lazy" />
          <figcaption>Albert G. Power at work in his studio<em>Courtesy Irish Capuchin Archives, Dublin</em></figcaption>
        </figure>
        <figure class="about-work-figure">
          <img src="{{ '/assets/images/collins-death-mask.jpg' | relative_url }}"
               alt="Death mask of Michael Collins by Albert G. Power, 1922" loading="lazy"
               onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Michael_Collins_1922.jpg/600px-Michael_Collins_1922.jpg'" />
          <figcaption>Death Mask of Michael Collins · 1922<em>Made within hours of Collins's death at Béal na Bláth</em></figcaption>
        </figure>
      </div>
    </div>
  </div>
</section>
INDEXEOF
echo "✓ index.html rewritten with Capuchin images as hero"

# ── 3. Fix gallery — use direct Capuchin/Wikipedia URLs as primary ──
# The gallery onerror Liquid syntax doesn't work in plain HTML. 
# Use absolute URLs directly instead.
python3 << 'PYEOF'
with open('gallery/index.html', 'r') as f:
    html = f.read()

# Fix image src paths — use relative_url properly and set direct fallback URLs
replacements = [
    # Collins - use direct Capuchin URL as primary since family archive photos are 0 bytes
    ('src="{{ \'/assets/images/collins-death-mask.jpg\' | relative_url }}"',
     'src="/assets/images/collins-death-mask.jpg" onerror="this.src=\'https://catholicarchives.ie/uploads/r/irish-capuchin-archives-2/d/9/2/d92e752038c424dec0f476ea3180864af99d1f3d4e1dc5d2ce313882b768096a/CA_CP-3-16-8-20-1.jpg\'"'),
    ('src="{{ \'/assets/images/griffith-death-mask.jpg\' | relative_url }}"',
     'src="/assets/images/griffith-death-mask.jpg" onerror="this.src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Arthur_Griffith.jpg/600px-Arthur_Griffith.jpg\'"'),
    ('src="{{ \'/assets/images/cathal-brugha-death-mask.jpg\' | relative_url }}"',
     'src="/assets/images/cathal-brugha-death-mask.jpg" onerror="this.src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Cathal_Brugha.jpg/600px-Cathal_Brugha.jpg\'"'),
    ('src="{{ \'/assets/images/erskine-childers.jpg\' | relative_url }}"',
     'src="/assets/images/erskine-childers.jpg" onerror="this.src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Erskine_Childers.jpg/600px-Erskine_Childers.jpg\'"'),
    ('src="{{ \'/assets/images/macswiney-life-mask.jpg\' | relative_url }}"',
     'src="/assets/images/macswiney-life-mask.jpg" onerror="this.src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Terence_MacSwiney.jpg/600px-Terence_MacSwiney.jpg\'"'),
    ('src="{{ \'/assets/images/michael-collins-bust.jpg\' | relative_url }}"',
     'src="/assets/images/michael-collins-bust.jpg" onerror="this.src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Michael_Collins_1922.jpg/600px-Michael_Collins_1922.jpg\'"'),
    ('src="{{ \'/assets/images/countess-markievicz.jpg\' | relative_url }}"',
     'src="/assets/images/countess-markievicz.jpg" onerror="this.src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Countess_Markievicz.jpg/600px-Countess_Markievicz.jpg\'"'),
    ('src="{{ \'/assets/images/wb-yeats.jpg\' | relative_url }}"',
     'src="/assets/images/wb-yeats.jpg" onerror="this.src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/WB_Yeats_by_George_Charles_Beresford.jpg/600px-WB_Yeats_by_George_Charles_Beresford.jpg\'"'),
    ('src="{{ \'/assets/images/o-conaire-memorial.jpg\' | relative_url }}"',
     'src="/assets/images/o-conaire-memorial.jpg" onerror="this.src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Padraic_O_Conaire_statue_Galway.jpg/800px-Padraic_O_Conaire_statue_Galway.jpg\'"'),
    ('src="{{ \'/assets/images/albert-power-portrait.jpg\' | relative_url }}"',
     'src="https://catholicarchives.ie/uploads/r/irish-capuchin-archives-2/d/9/2/d92e752038c424dec0f476ea3180864af99d1f3d4e1dc5d2ce313882b768096a/CA_CP-3-16-8-20-1.jpg"'),
    ('src="{{ \'/assets/images/power-working-carndonagh.jpg\' | relative_url }}"',
     'src="/assets/images/power-working-carndonagh.jpg" onerror="this.src=\'https://catholicarchives.ie/uploads/r/irish-capuchin-archives-2/b/9/c/b9cc9845d5323040e8aaf6588ec45a737cfaab42af8f406e8aff59b0289f1b07/CA_CP-3-16-8-20-4.jpg\'"'),
    ('src="{{ \'/assets/images/gresham-hotel-facade.jpg\' | relative_url }}"',
     'src="/assets/images/gresham-hotel-facade.jpg" onerror="this.src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Gresham_Hotel%2C_Dublin.jpg/800px-Gresham_Hotel%2C_Dublin.jpg\'"'),
]

for old, new in replacements:
    html = html.replace(old, new)

# Fix any remaining relative_url patterns
import re
html = re.sub(r"src=\"\{\{[^}]+\}\}\"", lambda m: m.group(0).replace("{{ '", '').replace("' | relative_url }}", ''), html)

with open('gallery/index.html', 'w') as f:
    f.write(html)
print("✓ gallery/index.html: Wikipedia/Capuchin fallback URLs set")
PYEOF

# ── 4. Commit and push ─────────────────────────────────────────────
git add -A
git status --short
git commit -m "fix: gallery 220px height, homepage Capuchin hero image, direct fallback URLs"
git push
echo ""
echo "✓ Done! Site will rebuild in ~2 minutes"
echo "  Check: https://albertpower.org/"
echo "  Check: https://albertpower.org/gallery/"
