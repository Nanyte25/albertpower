#!/usr/bin/env bash
# Run this from inside ~/Downloads/albert-power-jekyll 4
# It writes all new files directly — no zip required

set -e
REPO="$(pwd)"
echo "Applying to: $REPO"
echo ""

# Verify we're in the right place
[[ -f "_config.yml" ]] || { echo "ERROR: Run this from inside the albert-power-jekyll 4 folder"; exit 1; }

# ── 1. _data/wikipedia_images.yml ──────────────────────────────────
mkdir -p _data
cat > _data/wikipedia_images.yml << 'EOF'
o_conaire_statue:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Padraic_O_Conaire_statue_Galway.jpg/800px-Padraic_O_Conaire_statue_Galway.jpg"
  license: "CC BY-SA 3.0"
michael_collins_portrait:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Michael_Collins_1922.jpg/600px-Michael_Collins_1922.jpg"
  license: "Public domain"
arthur_griffith:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Arthur_Griffith.jpg/600px-Arthur_Griffith.jpg"
  license: "Public domain"
cathal_brugha:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Cathal_Brugha.jpg/600px-Cathal_Brugha.jpg"
  license: "Public domain"
countess_markievicz:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Countess_Markievicz.jpg/600px-Countess_Markievicz.jpg"
  license: "Public domain"
wb_yeats:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/WB_Yeats_by_George_Charles_Beresford.jpg/600px-WB_Yeats_by_George_Charles_Beresford.jpg"
  license: "Public domain"
erskine_childers:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Erskine_Childers.jpg/600px-Erskine_Childers.jpg"
  license: "Public domain"
terence_macswiney:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Terence_MacSwiney.jpg/600px-Terence_MacSwiney.jpg"
  license: "Public domain"
grace_gifford:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Grace_Gifford.jpg/600px-Grace_Gifford.jpg"
  license: "Public domain"
gresham_hotel:
  url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Gresham_Hotel%2C_Dublin.jpg/800px-Gresham_Hotel%2C_Dublin.jpg"
  license: "CC BY-SA 3.0"
EOF
echo "✓ _data/wikipedia_images.yml"

# ── 2. _includes/nav.html ──────────────────────────────────────────
cat > _includes/nav.html << 'EOF'
<nav class="site-nav" role="navigation" aria-label="Main navigation">
  <div class="nav-inner">
    <a class="nav-logo" href="{{ '/' | relative_url }}">
      Albert G. Power <span>RHA</span>
    </a>
    <ul class="nav-links" id="nav-links">
      <li><a href="{{ '/#biography' | relative_url }}">Biography</a></li>
      <li><a href="{{ '/works/' | relative_url }}" {% if page.url contains '/works/' %}aria-current="page"{% endif %}>Works</a></li>
      <li><a href="{{ '/gallery/' | relative_url }}" {% if page.url contains '/gallery/' %}aria-current="page"{% endif %}>Gallery</a></li>
      <li><a href="{{ '/family/' | relative_url }}" {% if page.url contains '/family/' %}aria-current="page"{% endif %}>Family</a></li>
      <li><a href="{{ '/publications/' | relative_url }}" {% if page.url contains '/publications/' %}aria-current="page"{% endif %}>Publications</a></li>
      <li><a href="{{ '/blog/' | relative_url }}" {% if page.url contains '/blog/' %}aria-current="page"{% endif %}>Writing</a></li>
      <li><a href="{{ '/#contact' | relative_url }}">Contact</a></li>
    </ul>
    <button class="nav-toggle" aria-controls="nav-links" aria-expanded="false" aria-label="Toggle menu">
      <span></span><span></span><span></span>
    </button>
  </div>
</nav>
EOF
echo "✓ _includes/nav.html"

# ── 3. publications/index.html ─────────────────────────────────────
mkdir -p publications
cat > publications/index.html << 'EOF'
---
layout: default
title: "Publications"
description: "Books, catalogues, and scholarly publications about Albert G. Power RHA."
permalink: /publications/
---
<header class="page-header">
  <div class="page-header-inner">
    <p class="hero-eyebrow">Archive</p>
    <h1 class="page-title">Publications</h1>
    <p class="page-subtitle">Books, catalogues, and scholarly writing about Albert G. Power RHA</p>
  </div>
</header>
<main class="publications-main">
  <div class="section-inner">
    <section class="pub-section">
      <h2 class="pub-section-title">Books</h2>
      <article class="pub-card pub-card--feature">
        <div class="pub-cover"><div class="pub-cover-placeholder"><span>AGP</span></div></div>
        <div class="pub-info">
          <h3 class="pub-title">Albert Power RHA 1881–1945</h3>
          <p class="pub-author">Judith Hill</p>
          <p class="pub-meta">Irish Academic Press · 2012 · ISBN 978-0-7165-3152-4</p>
          <p class="pub-desc">The definitive scholarly monograph on Power's life and work. Drawing on family archives, museum collections, and original research, this is the most comprehensive account of Power's career yet published. Hill traces his training, his extraordinary sequence of revolutionary death masks, his ecclesiastical commissions, and his public monuments. Contains a full catalogue of known works and extensive illustration.</p>
          <div class="pub-links">
            <a href="https://www.iap.ie" target="_blank" rel="noopener noreferrer" class="btn-secondary">Irish Academic Press →</a>
            <a href="https://www.worldcat.org/isbn/9780716531524" target="_blank" rel="noopener noreferrer" class="pub-link-secondary">Find in a library →</a>
          </div>
        </div>
      </article>
    </section>
    <div class="celtic-rule"></div>
    <section class="pub-section">
      <h2 class="pub-section-title">Archives &amp; Catalogues</h2>
      <article class="pub-card">
        <div class="pub-cover pub-cover--sm"><div class="pub-cover-placeholder pub-cover-placeholder--sm"><span>RHA</span></div></div>
        <div class="pub-info">
          <h3 class="pub-title">Royal Hibernian Academy Annual Exhibition Catalogues</h3>
          <p class="pub-author">Royal Hibernian Academy, Dublin</p>
          <p class="pub-meta">Annual · 1906–1945</p>
          <p class="pub-desc">Power exhibited at the RHA from 1906 until his death. The annual catalogues — held in the RHA archive and the National Library of Ireland — provide a year-by-year record of his exhibited works.</p>
          <div class="pub-links"><a href="https://www.rhagallery.ie" target="_blank" rel="noopener noreferrer" class="btn-secondary">RHA →</a></div>
        </div>
      </article>
      <article class="pub-card">
        <div class="pub-cover pub-cover--sm"><div class="pub-cover-placeholder pub-cover-placeholder--sm"><span>DIB</span></div></div>
        <div class="pub-info">
          <h3 class="pub-title">Dictionary of Irish Biography</h3>
          <p class="pub-author">Royal Irish Academy</p>
          <p class="pub-meta">Cambridge University Press / Royal Irish Academy</p>
          <p class="pub-desc">The Dictionary of Irish Biography contains a scholarly entry on Power providing biography and bibliography. Available through libraries and institutional subscriptions.</p>
          <div class="pub-links"><a href="https://www.dib.ie" target="_blank" rel="noopener noreferrer" class="btn-secondary">dib.ie →</a></div>
        </div>
      </article>
    </section>
    <div class="celtic-rule"></div>
    <section class="pub-section pub-section--contribute">
      <h2 class="pub-section-title">Know of Other Publications?</h2>
      <p class="pub-contribute-text">If you are aware of catalogues, theses, or articles dealing with Power's work not listed here, we would be glad to hear from you.</p>
      <a href="{{ '/#contact' | relative_url }}" class="btn-primary">Get in touch</a>
    </section>
  </div>
</main>
EOF
echo "✓ publications/index.html"

# ── 4. family/ pages ───────────────────────────────────────────────
mkdir -p family

cat > family/index.html << 'EOF'
---
layout: default
title: "The Power Family"
description: "Three generations of Irish sculptors — Albert G. Power RHA, James Power, May Power, and Oliver Power."
permalink: /family/
---
<header class="page-header">
  <div class="page-header-inner">
    <p class="hero-eyebrow">Heritage</p>
    <h1 class="page-title">The Power Family</h1>
    <p class="page-subtitle">Three generations of Irish sculptors</p>
  </div>
</header>
<main class="family-main">
  <div class="section-inner">
    <section class="family-intro">
      <p class="family-intro-text">Albert George Power did not work alone. He founded a sculptural dynasty that extended across three generations and shaped Irish public art from the 1880s to the late twentieth century. His son James became one of Ireland's most prolific monumental sculptors. His daughter May was a sculptor in her own right. His grandson Oliver continued the family craft. This archive honours all of them.</p>
    </section>
    <div class="celtic-rule"></div>
    <div class="family-grid">
      <article class="family-card family-card--feature">
        <div class="family-card-image">
          <img src="{{ '/assets/images/albert-power-portrait.jpg' | relative_url }}" alt="Albert G. Power RHA" loading="lazy" onerror="this.parentElement.classList.add('img-missing')" />
        </div>
        <div class="family-card-body">
          <span class="family-card-dates">1881–1945</span>
          <h2 class="family-card-name">Albert George Power <span>RHA</span></h2>
          <p class="family-card-role">Sculptor · Royal Hibernian Academician</p>
          <p>The founder. Albert Power trained at the Dublin Metropolitan School of Art and the Royal College of Art, London. His death masks of Collins, Griffith, Brugha, and Childers, the Pádraic Ó Conaire memorial in Galway, and his decorative work on the Gresham Hotel are among the defining sculptural works of the Irish revolutionary period.</p>
          <a href="{{ '/' | relative_url }}" class="read-more">Full archive →</a>
        </div>
      </article>
      <article class="family-card">
        <div class="family-card-image"><div class="family-img-placeholder">JP</div></div>
        <div class="family-card-body">
          <span class="family-card-dates">1920–2013</span>
          <h2 class="family-card-name">James Power</h2>
          <p class="family-card-role">Sculptor · Son of Albert G. Power</p>
          <p>Albert's son became one of Ireland's most prolific monumental sculptors — busts at Kilmainham Gaol, the Matt Talbot memorial, and decades of public and ecclesiastical commissions.</p>
          <a href="{{ '/family/james-power/' | relative_url }}" class="read-more">Read more →</a>
        </div>
      </article>
      <article class="family-card">
        <div class="family-card-image"><div class="family-img-placeholder">MP</div></div>
        <div class="family-card-body">
          <span class="family-card-dates">c.1918–</span>
          <h2 class="family-card-name">May Power</h2>
          <p class="family-card-role">Sculptor &amp; Artist · Daughter of Albert G. Power</p>
          <p>May Power, daughter of Albert, was a sculptor and artist who trained in the family tradition and exhibited through the mid-twentieth century.</p>
          <a href="{{ '/family/may-power/' | relative_url }}" class="read-more">Read more →</a>
        </div>
      </article>
      <article class="family-card">
        <div class="family-card-image">
          <img src="{{ '/assets/images/Oliver Power.JPG' | relative_url }}" alt="Oliver Power" loading="lazy" onerror="this.parentElement.classList.add('img-missing')" />
        </div>
        <div class="family-card-body">
          <span class="family-card-dates">1944–</span>
          <h2 class="family-card-name">Oliver Power</h2>
          <p class="family-card-role">Sculptor &amp; Stonemason · Grandson of Albert G. Power</p>
          <p>Oliver Power carried the family craft into the third generation. A stonemason and sculptor, he is Mark Freer's grandfather — the direct link between Albert Power and this archive.</p>
          <a href="{{ '/family/oliver-power/' | relative_url }}" class="read-more">Read more →</a>
        </div>
      </article>
    </div>
    <div class="celtic-rule"></div>
    <section class="family-legacy">
      <p style="font-family:var(--ff-quote);font-style:italic;color:var(--text-muted);line-height:1.8;max-width:720px;">The Power family's contribution to Irish sculpture spans nearly a century. Across three generations, they carved the death masks of revolutionaries, the facades of Dublin's great buildings, the memorials in her cemeteries, and the devotional statuary of her churches.</p>
      <p style="margin-top:1rem;font-size:0.9rem;color:var(--text-muted);">This site was created by <strong>Mark Freer</strong>, great-grandson of Albert G. Power, great-nephew of James and May, grandson of Oliver. <a href="{{ '/#contact' | relative_url }}" style="color:var(--moss);">Get in touch →</a></p>
    </section>
  </div>
</main>
EOF
echo "✓ family/index.html"

cat > family/james-power.html << 'EOF'
---
layout: default
title: "James Power — Sculptor"
description: "James Power (1920–2013), Irish sculptor, son of Albert G. Power RHA."
permalink: /family/james-power/
---
<header class="page-header">
  <div class="page-header-inner">
    <p class="hero-eyebrow">The Power Family · Son of Albert G. Power</p>
    <h1 class="page-title">James Power</h1>
    <p class="page-subtitle">Sculptor · 1920–2013</p>
  </div>
</header>
<main class="family-profile-main">
  <div class="section-inner">
    <div class="family-profile-grid">
      <aside class="family-profile-sidebar">
        <div class="family-profile-image">
          <img src="{{ '/assets/images/James Power.JPG' | relative_url }}" alt="James Power" loading="lazy" onerror="this.parentElement.classList.add('img-missing')" />
        </div>
        <dl class="family-profile-meta">
          <div><dt>Born</dt><dd>1920, Dublin</dd></div>
          <div><dt>Died</dt><dd>2013, Dublin</dd></div>
          <div><dt>Father</dt><dd><a href="{{ '/' | relative_url }}">Albert G. Power RHA</a></dd></div>
          <div><dt>Son</dt><dd><a href="{{ '/family/oliver-power/' | relative_url }}">Oliver Power</a></dd></div>
          <div><dt>Wikipedia</dt><dd><a href="https://en.wikipedia.org/wiki/James_Power_(sculptor)" target="_blank" rel="noopener noreferrer">James Power →</a></dd></div>
        </dl>
        <div class="family-profile-images-extra">
          <figure>
            <img src="{{ '/assets/images/Peader Kearney Bust James Power  Kilmainham Goal 1962.JPG' | relative_url }}" alt="Peadar Kearney bust by James Power, Kilmainham Gaol, 1962" loading="lazy" onerror="this.parentElement.style.display='none'" />
            <figcaption>Peadar Kearney · Kilmainham Gaol · 1962</figcaption>
          </figure>
          <figure>
            <img src="{{ '/assets/images/Edward Ned Daly James Power Kilmainham Goal 1954.JPG' | relative_url }}" alt="Edward Ned Daly by James Power, 1954" loading="lazy" onerror="this.parentElement.style.display='none'" />
            <figcaption>Edward 'Ned' Daly · Kilmainham Gaol · 1954</figcaption>
          </figure>
          <figure>
            <img src="{{ '/assets/images/Matt Tolbot James Power Dublin City.jpg' | relative_url }}" alt="Matt Talbot by James Power" loading="lazy" onerror="this.parentElement.style.display='none'" />
            <figcaption>Matt Talbot · Dublin City</figcaption>
          </figure>
        </div>
      </aside>
      <article class="family-profile-body">
        <h2>Life &amp; Career</h2>
        <p>James Power was born in Dublin in 1920, the son of Albert George Power RHA. He trained under his father and went on to become one of Ireland's most prolific monumental sculptors, producing public, civic, and ecclesiastical work across six decades.</p>
        <h2>Kilmainham Gaol Commissions</h2>
        <p>James Power's work for Kilmainham Gaol is among his most historically significant. His bust of <strong>Edward 'Ned' Daly</strong> (1954) — the youngest commandant executed after 1916 — and his bust of <strong>Peadar Kearney</strong> (1962), author of the Irish national anthem, are two of the most visited works in the gaol's collection.</p>
        <h2>Matt Talbot Memorial</h2>
        <p>James Power's memorial to <strong>Matt Talbot</strong> — the Dublin labourer whose austere piety made him a figure of popular veneration — is one of his best-known public works, displaying the same naturalistic directness he inherited from his father.</p>
        <h2>Legacy</h2>
        <p>James Power died in Dublin in 2013, having worked as a sculptor for over sixty years. His works are distributed across Dublin and throughout Ireland — in public squares, church interiors, and civic buildings.</p>
        <p>His Wikipedia page: <a href="https://en.wikipedia.org/wiki/James_Power_(sculptor)" target="_blank" rel="noopener noreferrer">en.wikipedia.org/wiki/James_Power_(sculptor)</a></p>
        <div class="family-profile-gallery">
          <h2>Further Works</h2>
          <div class="family-works-grid">
            <figure>
              <img src="{{ '/assets/images/Fr. Eugene Growney.  Gealic Scholar. Meath James Power.JPG' | relative_url }}" alt="Fr. Eugene Growney" loading="lazy" onerror="this.parentElement.style.display='none'" />
              <figcaption>Fr. Eugene Growney · Meath</figcaption>
            </figure>
            <figure>
              <img src="{{ '/assets/images/Erskine Childers James Power.JPG' | relative_url }}" alt="Erskine Childers by James Power" loading="lazy" onerror="this.parentElement.style.display='none'" />
              <figcaption>Erskine Childers</figcaption>
            </figure>
            <figure>
              <img src="{{ '/assets/images/Sean Mac Diarmada Monument 1940.png' | relative_url }}" alt="Seán Mac Diarmada monument" loading="lazy" onerror="this.parentElement.style.display='none'" />
              <figcaption>Seán Mac Diarmada · 1940</figcaption>
            </figure>
          </div>
        </div>
      </article>
    </div>
    <div class="family-nav-row">
      <a href="{{ '/family/' | relative_url }}" class="btn-secondary">← The Power Family</a>
      <a href="{{ '/family/may-power/' | relative_url }}" class="btn-secondary">May Power →</a>
    </div>
  </div>
</main>
EOF
echo "✓ family/james-power.html"

cat > family/may-power.html << 'EOF'
---
layout: default
title: "May Power — Sculptor & Artist"
description: "May Power, sculptor and artist, daughter of Albert G. Power RHA."
permalink: /family/may-power/
---
<header class="page-header">
  <div class="page-header-inner">
    <p class="hero-eyebrow">The Power Family · Daughter of Albert G. Power</p>
    <h1 class="page-title">May Power</h1>
    <p class="page-subtitle">Sculptor &amp; Artist</p>
  </div>
</header>
<main class="family-profile-main">
  <div class="section-inner">
    <div class="family-profile-grid">
      <aside class="family-profile-sidebar">
        <div class="family-profile-image family-profile-image--placeholder"><span>MP</span></div>
        <dl class="family-profile-meta">
          <div><dt>Father</dt><dd><a href="{{ '/' | relative_url }}">Albert G. Power RHA</a></dd></div>
          <div><dt>Brother</dt><dd><a href="{{ '/family/james-power/' | relative_url }}">James Power</a></dd></div>
          <div><dt>Wikipedia</dt><dd><a href="https://en.wikipedia.org/wiki/May_Power" target="_blank" rel="noopener noreferrer">May Power →</a></dd></div>
        </dl>
        <div class="family-profile-images-extra">
          <figure>
            <img src="{{ '/assets/images/Our Lady Queen of Peace.JPG' | relative_url }}" alt="Our Lady Queen of Peace" loading="lazy" onerror="this.parentElement.style.display='none'" />
            <figcaption>Our Lady Queen of Peace · Power Family Archive</figcaption>
          </figure>
        </div>
      </aside>
      <article class="family-profile-body">
        <h2>A Sculptor in Her Own Right</h2>
        <p>May Power was a sculptor and artist, daughter of Albert George Power RHA and sister of James Power. She grew up in a home shaped entirely by the practice of sculpture and trained as an artist in the family tradition.</p>
        <h2>Context: Women Sculptors in Mid-Century Ireland</h2>
        <p>Mid-twentieth century Ireland offered few institutional pathways for women artists. That May Power persisted as a practising sculptor and artist in this environment, and that her work was recognised sufficiently to merit a dedicated Wikipedia entry, speaks to her determination and her talent. She deserves to be remembered as an artist of her own generation, not merely as a member of a distinguished family.</p>
        <h2>Further Research</h2>
        <p>May Power's life and work are not yet fully documented. This page will be expanded as further information comes to light. If you have knowledge of her works, please <a href="{{ '/#contact' | relative_url }}">get in touch</a>.</p>
        <p>Her Wikipedia page: <a href="https://en.wikipedia.org/wiki/May_Power" target="_blank" rel="noopener noreferrer">en.wikipedia.org/wiki/May_Power</a></p>
      </article>
    </div>
    <div class="family-nav-row">
      <a href="{{ '/family/james-power/' | relative_url }}" class="btn-secondary">← James Power</a>
      <a href="{{ '/family/oliver-power/' | relative_url }}" class="btn-secondary">Oliver Power →</a>
    </div>
  </div>
</main>
EOF
echo "✓ family/may-power.html"

cat > family/oliver-power.html << 'EOF'
---
layout: default
title: "Oliver Power — Sculptor & Stonemason"
description: "Oliver Power, sculptor and stonemason, son of James Power and grandson of Albert G. Power RHA. Mark Freer's grandfather."
permalink: /family/oliver-power/
---
<header class="page-header">
  <div class="page-header-inner">
    <p class="hero-eyebrow">The Power Family · Grandson of Albert G. Power</p>
    <h1 class="page-title">Oliver Power</h1>
    <p class="page-subtitle">Sculptor &amp; Stonemason · Mark Freer's grandfather</p>
  </div>
</header>
<main class="family-profile-main">
  <div class="section-inner">
    <div class="family-profile-grid">
      <aside class="family-profile-sidebar">
        <div class="family-profile-image">
          <img src="{{ '/assets/images/Oliver Power.JPG' | relative_url }}" alt="Oliver Power" loading="lazy" onerror="this.parentElement.classList.add('img-missing')" />
        </div>
        <dl class="family-profile-meta">
          <div><dt>Father</dt><dd><a href="{{ '/family/james-power/' | relative_url }}">James Power</a></dd></div>
          <div><dt>Grandfather</dt><dd><a href="{{ '/' | relative_url }}">Albert G. Power RHA</a></dd></div>
          <div><dt>Grandson</dt><dd>Mark Freer (creator of this archive)</dd></div>
          <div><dt>Specialty</dt><dd>Stone carving &amp; lettering</dd></div>
        </dl>
        <div class="family-profile-images-extra">
          <figure>
            <img src="{{ '/assets/images/Oliver Power (2).JPG' | relative_url }}" alt="Oliver Power" loading="lazy" onerror="this.parentElement.style.display='none'" />
            <figcaption>Oliver Power · Power Family Archive</figcaption>
          </figure>
          <figure>
            <img src="{{ '/assets/images/66. Oliver Power\'s House.JPG' | relative_url }}" alt="Oliver Power's house" loading="lazy" onerror="this.parentElement.style.display='none'" />
            <figcaption>Oliver Power's House &amp; Studio</figcaption>
          </figure>
        </div>
      </aside>
      <article class="family-profile-body">
        <h2>The Third Generation</h2>
        <p>Oliver Power was the son of James Power and grandson of Albert George Power RHA — and Mark Freer's grandfather, the direct link between the great Albert Power and this archive. He worked as a stonemason and sculptor, maintaining the family tradition of working directly in stone.</p>
        <h2>The Robert Emmet Bridge Lettering</h2>
        <p>One of Oliver Power's most significant contributions is the carved lettering on the <strong>Robert Emmet Bridge</strong>, Harold's Cross, Dublin (1938). Carved directly into stone — permanent and unforgiving, with no possibility of correction — the lettering has endured for nearly a century without deterioration, a testament to his mastery of the craft.</p>
        <h2>The Family Studio</h2>
        <p>The Power family operated a stone yard and studio in Dublin across three generations, documented in the family archive from as early as 1912. Oliver grew up in and around this studio, learning directly from his father James as James had learned from Albert.</p>
        <h2>A Personal Note</h2>
        <p>This archive was created by <strong>Mark Freer</strong>, Oliver Power's grandson. Oliver is Mark's direct connection to the Power sculptural dynasty — the grandfather through whom the family's craft, its stories, and its archive passed to the next generation.</p>
        <div class="family-profile-gallery">
          <h2>Robert Emmet Bridge — Carved Lettering</h2>
          <div class="family-works-grid">
            <figure>
              <img src="{{ '/assets/images/138. Robert Emmet Plaque 1938.jpg' | relative_url }}" alt="Robert Emmet Plaque 1938" loading="lazy" onerror="this.parentElement.style.display='none'" />
              <figcaption>Robert Emmet Plaque · 1938</figcaption>
            </figure>
            <figure>
              <img src="{{ '/assets/images/139. Robert Emmet Plaque on Robert Emmet Bridge 1938.jpg' | relative_url }}" alt="Robert Emmet Bridge 1938" loading="lazy" onerror="this.parentElement.style.display='none'" />
              <figcaption>Robert Emmet Bridge · 1938</figcaption>
            </figure>
            <figure>
              <img src="{{ '/assets/images/140. Robert Emmet Carved letters by Oliver Power 1938.jpg' | relative_url }}" alt="Carved lettering by Oliver Power" loading="lazy" onerror="this.parentElement.style.display='none'" />
              <figcaption>Carved lettering by Oliver Power · 1938</figcaption>
            </figure>
          </div>
        </div>
      </article>
    </div>
    <div class="family-nav-row">
      <a href="{{ '/family/may-power/' | relative_url }}" class="btn-secondary">← May Power</a>
      <a href="{{ '/family/' | relative_url }}" class="btn-secondary">The Power Family →</a>
    </div>
  </div>
</main>
EOF
echo "✓ family/oliver-power.html"

# ── 5. Append new CSS ──────────────────────────────────────────────
cat >> assets/css/main.css << 'CSSEOF'

/* ── FAMILY PAGES ── */
.family-main,.family-profile-main{padding:3rem 1.5rem 6rem}
.family-intro{margin-bottom:2.5rem}
.family-intro-text{font-family:var(--ff-quote);font-style:italic;font-size:1.05rem;color:var(--text-muted);line-height:1.8;max-width:760px}
.family-grid{display:grid;grid-template-columns:1fr 1fr;gap:2.5rem;margin-bottom:3rem}
.family-card{border:1px solid rgba(139,115,85,.2);overflow:hidden}
.family-card--feature{grid-column:1/-1;display:grid;grid-template-columns:300px 1fr}
.family-card-image{width:100%;aspect-ratio:3/4;overflow:hidden;background:var(--shadow)}
.family-card--feature .family-card-image{aspect-ratio:auto;min-height:300px}
.family-card-image img{width:100%;height:100%;object-fit:cover;display:block}
.family-img-placeholder{width:100%;height:100%;min-height:200px;display:flex;align-items:center;justify-content:center;font-family:var(--ff-display);font-size:2rem;color:var(--bronze);opacity:.4;letter-spacing:.1em;background:var(--shadow)}
.family-card-body{padding:1.75rem}
.family-card-dates{font-family:var(--ff-display);font-size:.75rem;letter-spacing:.2em;color:var(--bronze);display:block;margin-bottom:.3rem}
.family-card-name{font-family:var(--ff-display);font-size:1.5rem;font-weight:600;color:var(--ink);margin-bottom:.25rem;line-height:1.2}
.family-card-name span{font-weight:300;color:var(--bronze);font-size:1rem;margin-left:.25em}
.family-card-role{font-family:var(--ff-display);font-size:.82rem;letter-spacing:.08em;color:var(--text-muted);margin-bottom:.9rem}
.family-card p{font-size:.9rem;line-height:1.7;color:var(--text-muted);margin-bottom:.75rem}
.family-profile-grid{display:grid;grid-template-columns:280px 1fr;gap:4rem;align-items:start}
.family-profile-image{width:100%;aspect-ratio:3/4;overflow:hidden;background:var(--shadow);margin-bottom:1.5rem;border:1px solid rgba(139,115,85,.2)}
.family-profile-image img{width:100%;height:100%;object-fit:cover;display:block}
.family-profile-image--placeholder{display:flex;align-items:center;justify-content:center;font-family:var(--ff-display);font-size:3rem;color:var(--bronze);opacity:.35;letter-spacing:.1em}
.family-profile-meta{margin-bottom:1.5rem;font-size:.82rem}
.family-profile-meta>div{display:grid;grid-template-columns:80px 1fr;gap:.4rem;padding:.4rem 0;border-bottom:1px solid rgba(139,115,85,.12);line-height:1.4}
.family-profile-meta dt{font-family:var(--ff-display);letter-spacing:.08em;color:var(--bronze);text-transform:uppercase;font-size:.68rem}
.family-profile-meta a{color:var(--moss);text-decoration:none}
.family-profile-images-extra{display:flex;flex-direction:column;gap:1rem}
.family-profile-images-extra figure img{width:100%;height:160px;object-fit:cover;display:block;border:1px solid rgba(139,115,85,.15)}
.family-profile-images-extra figcaption{font-family:var(--ff-display);font-size:.72rem;color:var(--text-muted);margin-top:.3rem;line-height:1.4}
.family-profile-body h2{font-family:var(--ff-display);font-size:1.4rem;font-weight:600;color:var(--ink);margin:2.5rem 0 .75rem}
.family-profile-body h2:first-child{margin-top:0}
.family-profile-body p{line-height:1.85;margin-bottom:1.2rem;color:var(--text-primary)}
.family-profile-body a{color:var(--moss)}
.family-profile-body strong{color:var(--ink)}
.family-works-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:1rem;margin-top:1rem}
.family-works-grid figure img{width:100%;height:180px;object-fit:cover;display:block;border:1px solid rgba(139,115,85,.2)}
.family-works-grid figcaption{font-family:var(--ff-display);font-size:.72rem;color:var(--text-muted);margin-top:.3rem;line-height:1.4}
.family-nav-row{display:flex;justify-content:space-between;align-items:center;margin-top:3rem;padding-top:2rem;border-top:1px solid rgba(139,115,85,.2);flex-wrap:wrap;gap:1rem}
.family-legacy{max-width:760px}
.pub-section{margin-bottom:3.5rem}
.pub-section-title{font-family:var(--ff-display);font-size:clamp(1.4rem,2.5vw,2rem);font-weight:400;color:var(--ink);margin-bottom:2rem;padding-bottom:.75rem;border-bottom:1px solid rgba(139,115,85,.3)}
.pub-card{display:grid;grid-template-columns:160px 1fr;gap:2.5rem;margin-bottom:2.5rem;padding-bottom:2.5rem;border-bottom:1px solid rgba(139,115,85,.15);align-items:start}
.pub-card--feature{grid-template-columns:200px 1fr}
.pub-cover-placeholder{width:100%;aspect-ratio:2/3;background:var(--shadow);display:flex;align-items:center;justify-content:center;font-family:var(--ff-display);font-size:1.5rem;color:var(--bronze);opacity:.6;border:1px solid rgba(139,115,85,.2)}
.pub-title{font-family:var(--ff-display);font-size:1.25rem;font-weight:600;color:var(--ink);margin-bottom:.3rem;line-height:1.3}
.pub-author{font-family:var(--ff-display);font-size:.9rem;color:var(--bronze);margin-bottom:.2rem}
.pub-meta{font-family:var(--ff-display);font-size:.78rem;color:var(--text-muted);margin-bottom:1rem}
.pub-desc{font-size:.92rem;color:var(--text-primary);line-height:1.78;margin-bottom:.75rem}
.pub-links{display:flex;gap:1.5rem;align-items:center;flex-wrap:wrap;margin-top:1rem}
.pub-link-secondary{font-family:var(--ff-display);font-size:.8rem;color:var(--text-muted);text-decoration:none;border-bottom:1px solid rgba(139,115,85,.3);padding-bottom:1px}
.pub-section--contribute{background:rgba(139,115,85,.05);padding:2rem;border:1px solid rgba(139,115,85,.2)}
.pub-contribute-text{font-family:var(--ff-quote);font-style:italic;color:var(--text-muted);font-size:.95rem;line-height:1.75;margin-bottom:1.5rem;max-width:600px}
.publications-main{padding:3rem 1.5rem 6rem}
@media(max-width:900px){.family-grid{grid-template-columns:1fr}.family-card--feature{grid-template-columns:1fr}.family-card--feature .family-card-image{aspect-ratio:16/9}.family-profile-grid{grid-template-columns:1fr}.family-works-grid{grid-template-columns:1fr 1fr}.pub-card{grid-template-columns:1fr}}
CSSEOF
echo "✓ CSS appended"

echo ""
echo "All files written. Running git..."
git add -A
git status --short
git commit -m "feat: family pages (James, May, Oliver), publications, Wikipedia fallbacks, nav update"
git push
echo ""
echo "✓ Done — check https://albertpower.org/family/ once Actions completes"
