# Albert G. Power RHA — Memorial Archive

A family and scholarly archive dedicated to the life and work of **Albert George Power RHA (1881–1945)**, one of the foremost Irish sculptors of the twentieth century.

Built with [Jekyll](https://jekyllrb.com/) and hosted on [GitHub Pages](https://pages.github.com/).

---

## Quick Start (Local Development)

### Prerequisites
- Ruby 3.x — [install via rbenv](https://github.com/rbenv/rbenv) or `brew install ruby`
- Bundler — `gem install bundler`

### Run locally

```bash
git clone https://github.com/Nanyte25/albert-power-rha.git
cd albert-power-rha
bundle install
bundle exec jekyll serve --livereload
```

Open `http://localhost:4000` in your browser.

---

## Deploying to GitHub Pages

1. **Create a repo** called `albert-power-rha` on your GitHub account (`Nanyte25`)
2. Push this folder to the `main` branch
3. Go to **Settings → Pages** → set source to `main` branch, `/ (root)`
4. GitHub will build and deploy automatically

Your site will be live at: `https://nanyte25.github.io/albert-power-rha`

> **Note:** Update `baseurl` in `_config.yml` to match your repo name if it differs.

---

## Project Structure

```
albert-power-rha/
├── _config.yml          # Site configuration
├── _data/
│   └── timeline.yml     # Timeline events (edit to add/remove)
├── _includes/
│   ├── nav.html          # Navigation bar
│   ├── footer.html       # Footer
│   └── celtic-rule.html  # Decorative divider
├── _layouts/
│   ├── default.html      # Base layout (all pages)
│   ├── post.html         # Blog post layout
│   └── work.html         # Individual work/sculpture layout
├── _posts/               # Blog essays in Markdown ← ADD POSTS HERE
│   ├── 2025-06-01-o-conaire-memorial.md
│   ├── 2025-05-15-michael-collins-bust.md
│   └── 2025-04-20-oliver-sheppard-influence.md
├── _works/               # Sculpture catalogue entries ← ADD WORKS HERE
│   └── o-conaire.md
├── assets/
│   ├── css/main.css      # All styles
│   ├── js/main.js        # Nav toggle + scroll reveal
│   └── images/           # ← ADD PHOTOS HERE
├── blog/
│   └── index.html        # Blog listing page
├── works/
│   └── index.html        # Works catalogue page
├── index.html            # Homepage
└── Gemfile
```

---

## Adding Content

### New blog post

Create a file in `_posts/` following the naming convention `YYYY-MM-DD-title.md`:

```markdown
---
layout: post
title: "Your Essay Title"
subtitle: "Optional subtitle"
date: 2025-07-01
category: "Research Essay"
tags: ["Public Sculpture", "Dublin"]
read_time: 6
excerpt: "A one-paragraph summary that appears in listings."
---

Your essay content here, written in standard Markdown.

## Section heading

More prose...

> A pull quote styled in IM Fell English italic.
```

### New work/sculpture entry

Create a file in `_works/` (e.g. `_works/michael-collins.md`):

```markdown
---
title: "Michael Collins"
year: "c. 1922"
medium: "Bronze"
location: "Hugh Lane Gallery, Dublin"
collection: "Hugh Lane Gallery"
dimensions: "Portrait bust"
image: "/assets/images/michael-collins-bust.jpg"
image_alt: "Bronze portrait bust of Michael Collins"
image_caption: "Michael Collins, c.1922. Bronze. Hugh Lane Gallery, Dublin."
order: 2
---

Description of the work in Markdown...
```

### Adding photographs

Place image files in `assets/images/` and reference them in work entries or posts:

```markdown
![Alt text]({{ '/assets/images/your-photo.jpg' | relative_url }})
```

**Recommended formats:** JPEG for photographs, WebP for web-optimised versions.
**Hero image:** To replace the SVG placeholder, edit `index.html` and replace the `<svg>` block with an `<img>` tag pointing to your chosen image.

---

## Customisation

| File | What to change |
|------|----------------|
| `_config.yml` | Site title, URL, author email |
| `_data/timeline.yml` | Timeline events |
| `assets/css/main.css` | Colours, fonts, layout (all design tokens in `:root`) |
| `_includes/footer.html` | Footer text |
| `index.html` | Homepage content, biography text |

### Colour palette

All colours are defined as CSS custom properties in `main.css`:

```css
:root {
  --ink:    #1C1A17;  /* near-black */
  --vellum: #F7F2E8;  /* aged paper/limestone */
  --bronze: #8B7355;  /* warm bronze */
  --moss:   #4A6741;  /* Irish moss green */
  --stone:  #C9B99A;  /* pale stone */
}
```

---

## Plugins Used

All plugins are on the [GitHub Pages safe list](https://pages.github.com/versions/):

- `jekyll-feed` — RSS/Atom feed at `/feed.xml`
- `jekyll-seo-tag` — meta tags for SEO and social sharing
- `jekyll-sitemap` — auto-generates `/sitemap.xml`

---

## Contributing

This is a family archive. If you hold photographs, correspondence, documentation, or knowledge of undocumented works by Albert G. Power, please get in touch via the contact form on the site.

---

*Maintained by the Power family. Built with Jekyll.*
# albertpower
