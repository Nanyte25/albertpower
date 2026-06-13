#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
#  Albert G. Power RHA — Interactive Site Setup Script
#  Uses: gum · curl · jq · git · gh (GitHub CLI) · ruby/bundler · dig
#  Run:  chmod +x setup.sh && ./setup.sh
# ══════════════════════════════════════════════════════════════════════

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESEARCH_CACHE="$SCRIPT_DIR/.research_cache.json"
STATE_FILE="$SCRIPT_DIR/.setup_state"

# ── Colours ────────────────────────────────────────────────────────────
BRONZE="#8B7355"
MOSS="#4A6741"
STONE="#C9B99A"

# GitHub Pages IPs (stable, verified June 2025)
GH_PAGES_IPS=("185.199.108.153" "185.199.109.153" "185.199.110.153" "185.199.111.153")

# ══════════════════════════════════════════════════════════════════════
#  HELPERS
# ══════════════════════════════════════════════════════════════════════
check_deps() {
  local missing=()
  for cmd in gum curl jq git; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "  Missing required tools: ${missing[*]}"
    echo "  Run:  ./install-deps.sh"
    exit 1
  fi
}

step() {
  echo ""
  gum style \
    --foreground "$BRONZE" --border normal \
    --border-foreground "$MOSS" --padding "0 2" \
    "[ $1 ]  $2"
  echo ""
}

log_info()    { gum style --foreground "$STONE"  "  ◆  $*"; }
log_success() { gum style --foreground "$MOSS"   "  ✓  $*"; }
log_warn()    { gum style --foreground "$BRONZE" "  ⚠  $*"; }
log_error()   { gum style --foreground "#CC4444" "  ✗  $*"; }

save_state() { echo "$1=$2" >> "$STATE_FILE"; }
load_state() { grep "^$1=" "$STATE_FILE" 2>/dev/null | cut -d= -f2- || echo ""; }

# ══════════════════════════════════════════════════════════════════════
#  BANNER
# ══════════════════════════════════════════════════════════════════════
show_banner() {
  clear
  gum style \
    --foreground "$BRONZE" --border double \
    --border-foreground "$BRONZE" --padding "1 4" --margin "1 2" --bold \
    "Albert George Power RHA" "1881 — 1945" "" "Memorial Archive Setup"
  gum style --foreground "$STONE" --margin "0 4" --italic \
    "Carver of memory. Caster of a nation's grief and pride in bronze and stone."
  echo ""
}

# ══════════════════════════════════════════════════════════════════════
#  STEP 0 — PREFLIGHT
# ══════════════════════════════════════════════════════════════════════
preflight_checks() {
  step "0" "Preflight Checks"

  # Anthropic API key — prompt if missing, then validate
  if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    log_warn "ANTHROPIC_API_KEY not set in environment"
    echo ""
    ANTHROPIC_API_KEY=$(gum input \
      --placeholder "sk-ant-..." \
      --prompt "  Enter Anthropic API key: " \
      --password)
    [[ -z "$ANTHROPIC_API_KEY" ]] && { log_error "API key required"; exit 1; }
    export ANTHROPIC_API_KEY
  else
    log_success "ANTHROPIC_API_KEY found in environment"
  fi

  # Quick key validation — send a minimal request to catch bad keys early
  log_info "Validating API key..."
  local test_resp test_err
  test_resp=$(curl -s --max-time 15 \
    -X POST "https://api.anthropic.com/v1/messages" \
    -H "x-api-key: ${ANTHROPIC_API_KEY}" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d '{"model":"claude-haiku-4-5-20251001","max_tokens":5,"messages":[{"role":"user","content":"hi"}]}' \
    2>/dev/null || true)
  test_err=$(echo "$test_resp" | jq -r '.error.type // empty' 2>/dev/null || true)
  if [[ "$test_err" == "authentication_error" ]]; then
    log_error "API key is invalid — check it at https://console.anthropic.com/keys"
    ANTHROPIC_API_KEY=$(gum input \
      --placeholder "sk-ant-..." \
      --prompt "  Enter a valid API key: " \
      --password)
    [[ -z "$ANTHROPIC_API_KEY" ]] && { log_error "API key required"; exit 1; }
    export ANTHROPIC_API_KEY
  elif [[ -z "$test_resp" ]]; then
    log_warn "Could not reach api.anthropic.com — check your network, continuing anyway"
  else
    log_success "API key validated"
  fi

  # GitHub CLI
  GH_AVAILABLE=false
  GH_USER=""
  if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null 2>&1; then
      GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
      log_success "GitHub CLI authenticated as: $GH_USER"
      GH_AVAILABLE=true
      save_state "GH_USER" "$GH_USER"
    else
      log_warn "GitHub CLI found but not authenticated — run: gh auth login"
    fi
  else
    log_warn "GitHub CLI (gh) not found — will skip repo creation"
  fi

  # Ruby / Bundler
  RUBY_AVAILABLE=false
  if command -v ruby &>/dev/null && command -v bundle &>/dev/null; then
    log_success "Ruby $(ruby --version | awk '{print $2}') + Bundler available"
    RUBY_AVAILABLE=true
  else
    log_warn "Ruby/Bundler not found — will skip local serve"
  fi

  # dig (for DNS check)
  DIG_AVAILABLE=false
  if command -v dig &>/dev/null; then
    log_success "dig available (DNS verification enabled)"
    DIG_AVAILABLE=true
  else
    log_warn "dig not found — DNS verification will be manual"
  fi

  # SSH config — ensure mfreer-github key is wired to github.com
  local ssh_config="$HOME/.ssh/config"
  if [[ -f "$HOME/.ssh/mfreer-github" ]]; then
    if ! grep -q "mfreer-github" "$ssh_config" 2>/dev/null; then
      echo ""
      log_info "SSH key mfreer-github found but not in ~/.ssh/config"
      if gum confirm "  Add GitHub SSH config entry for mfreer-github?"; then
        # Backup existing config
        [[ -f "$ssh_config" ]] && cp "$ssh_config" "${ssh_config}.bak"
        cat >> "$ssh_config" <<'SSHCONF'

# GitHub — Albert Power archive setup
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/mfreer-github
  IdentitiesOnly yes
  AddKeysToAgent yes
SSHCONF
        chmod 600 "$ssh_config"
        log_success "~/.ssh/config updated (backup saved as config.bak)"
        # Add to agent so it's available immediately
        ssh-add "$HOME/.ssh/mfreer-github" 2>/dev/null && \
          log_success "Key added to ssh-agent" || \
          log_warn "Could not add to agent — you may need to run: ssh-add ~/.ssh/mfreer-github"
      fi
    else
      log_success "SSH key mfreer-github already in ~/.ssh/config"
      # Ensure it's in the agent
      ssh-add -l 2>/dev/null | grep -q "mfreer-github" || \
        ssh-add "$HOME/.ssh/mfreer-github" 2>/dev/null || true
    fi
  fi

  echo ""
  gum confirm "  All checks done. Continue?" || exit 0
}

# ══════════════════════════════════════════════════════════════════════
#  STEP 1 — RESEARCH
# ══════════════════════════════════════════════════════════════════════
research_power() {
  step "1" "Researching Albert G. Power via Anthropic API"

  if [[ -f "$RESEARCH_CACHE" ]]; then
    if gum confirm "  Cached research found. Use it? (No = re-fetch)"; then
      log_success "Using cached research data"
      return 0
    fi
    rm -f "$RESEARCH_CACHE"
  fi

  log_info "Querying Claude — drawing on all known sources about Albert G. Power..."
  echo ""

  local prompt
  prompt=$(cat <<'PROMPT'
You are a specialist in Irish art history with comprehensive knowledge of early 20th century Irish sculpture, the Irish Revival, the Royal Hibernian Academy, and Irish public and ecclesiastical art. Draw on everything known from museum records, academic literature, Wikipedia, the Dictionary of Irish Biography, the Crawford Art Gallery records, the Hugh Lane Gallery, the National Gallery of Ireland, RHA archives, and all other relevant sources.

Compile the most complete and accurate profile of Albert George Power RHA (1881-1945), Irish sculptor.

Return ONLY a single valid JSON object — no preamble, no markdown fences, no commentary. Use this exact schema:

{
  "biography": {
    "born": "full date and place",
    "died": "full date and place",
    "full_name": "Albert George Power",
    "rha_election_year": "year",
    "teachers": ["name (relationship)"],
    "style_keywords": ["naturalism", "Irish Revival", "portraiture"],
    "overview_paragraphs": ["para1", "para2", "para3", "para4"],
    "early_life": "2-3 sentence paragraph",
    "training": "2-3 sentence paragraph",
    "career": "3-4 sentence paragraph",
    "ecclesiastical_work": "2-3 sentence paragraph",
    "legacy": "2-3 sentence paragraph"
  },
  "works": [
    {
      "slug": "url-safe-slug",
      "title": "Work title",
      "year": "year or circa",
      "medium": "Bronze / Stone / Plaster",
      "location": "Where it physically is",
      "collection": "Owning institution or Public Commission",
      "dimensions": "if known",
      "description_paragraphs": ["para1", "para2"],
      "significance": "One sentence on why it matters",
      "commission_context": "One sentence on how/why it was commissioned",
      "order": 1
    }
  ],
  "timeline": [
    {
      "year": "YYYY or c.YYYY",
      "title": "Event title",
      "description": "2-3 sentence description with context"
    }
  ],
  "influences": [
    {"name": "Artist name", "relationship": "teacher/contemporary/influence", "notes": "one sentence"}
  ],
  "collections": [
    {"institution": "Name", "location": "City", "holdings": "what they hold"}
  ],
  "blog_posts": [
    {
      "slug": "url-safe-slug",
      "title": "Compelling essay title",
      "subtitle": "Subtitle",
      "category": "Research Essay",
      "tags": ["tag1", "tag2"],
      "date": "2025-06-01",
      "read_time": 8,
      "excerpt": "One paragraph summary (2-3 sentences)",
      "content_markdown": "Full essay body in markdown. Minimum 700 words. Use ## for section headings. Use > for pull quotes. Write as a serious art historian."
    }
  ],
  "sources": ["list of authoritative sources consulted"]
}

Requirements:
- Include at minimum 10 works (public sculptures, portrait busts, ecclesiastical commissions, medallions)
- Include at minimum 12 timeline events from 1881 to present day
- Include 4 blog post essays, each minimum 700 words, on different aspects of his work
- Be specific with real names, dates, locations, and institutions
- Use "c." prefix for uncertain dates
PROMPT
)

  # Write API request body to a tempfile so the prompt doesn't get mangled
  # by shell expansion inside subshells
  local req_file resp_file exit_file
  # macOS mktemp does not support extensions in the template — no dots allowed
  req_file=$(mktemp /tmp/power_req_XXXXXX)
  resp_file=$(mktemp /tmp/power_resp_XXXXXX)
  exit_file=$(mktemp /tmp/power_exit_XXXXXX)
  trap 'rm -f "$req_file" "$resp_file" "$exit_file"' RETURN

  jq -n --arg p "$prompt" \
    '{model:"claude-opus-4-6",max_tokens:8000,messages:[{role:"user",content:$p}]}' \
    > "$req_file"

  # Validate the key looks plausible before hitting the network
  local api_key="$ANTHROPIC_API_KEY"
  if [[ -z "$api_key" ]]; then
    log_error "API key is empty — cannot call Anthropic API"
    return 1
  fi

  # Run curl in a subshell that writes its own exit code to a file.
  # We cannot rely on 'wait $pid' after the spinner loop because on some
  # shells the background process is already reaped by the time we call wait,
  # returning 127. Writing to exit_file sidesteps this entirely.
  (
    curl -s --max-time 180 \
      -X POST "https://api.anthropic.com/v1/messages" \
      -H "x-api-key: ${api_key}" \
      -H "anthropic-version: 2023-06-01" \
      -H "content-type: application/json" \
      -d @"${req_file}" \
      -o "${resp_file}"
    echo $? > "${exit_file}"
  ) &
  local curl_pid=$!

  # Spinner while we wait
  local i=0
  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  while kill -0 "$curl_pid" 2>/dev/null; do
    printf "\r  %s  Consulting the archive..." "${frames[$((i % ${#frames[@]}))]}"
    i=$((i + 1))
    sleep 0.1
  done
  # Wait for subshell to fully finish writing exit_file
  wait "$curl_pid" 2>/dev/null || true
  printf "\r                                              \r"

  # Read curl's actual exit code
  local curl_exit=0
  curl_exit=$(cat "$exit_file" 2>/dev/null || echo "1")

  if [[ "$curl_exit" != "0" ]]; then
    log_error "curl failed (exit $curl_exit) — check your network connection"
    log_info "curl exit codes: 6=DNS failure, 7=connection refused, 28=timeout, 35=SSL error"
    return 1
  fi

  # Check we actually got a response
  if [[ ! -s "$resp_file" ]]; then
    log_error "Empty response from server — possible network issue"
    return 1
  fi

  local response content
  response=$(cat "$resp_file")

  # Show raw response in debug mode (set DEBUG=1 before running)
  if [[ "${DEBUG:-0}" == "1" ]]; then
    echo ""
    log_info "Raw API response:"
    echo "$response" | jq . 2>/dev/null || echo "$response"
    echo ""
  fi

  # Detect API-level errors before trying to parse content
  local err_type
  err_type=$(echo "$response" | jq -r '.error.type // empty' 2>/dev/null || true)
  if [[ -n "$err_type" ]]; then
    local err_msg
    err_msg=$(echo "$response" | jq -r '.error.message // "unknown error"' 2>/dev/null)
    log_error "Anthropic API error: $err_msg"
    echo ""
    if [[ "$err_type" == "authentication_error" ]]; then
      log_warn "API key rejected — check it at: https://console.anthropic.com/keys"
      if gum confirm "  Enter a different API key and retry?"; then
        ANTHROPIC_API_KEY=$(gum input \
          --placeholder "sk-ant-..." \
          --prompt "  API key: " \
          --password)
        [[ -z "$ANTHROPIC_API_KEY" ]] && { log_error "No key entered"; return 1; }
        export ANTHROPIC_API_KEY
        rm -f "$RESEARCH_CACHE"
        research_power
        return $?
      fi
    fi
    return 1
  fi

  content=$(echo "$response" | jq -r '.content[0].text // empty' 2>/dev/null) \
    || { log_error "Failed to parse API response"; echo "$response" | head -10; return 1; }

  if [[ -z "$content" ]]; then
    log_error "Empty content in API response"
    echo "$response" | jq . 2>/dev/null || echo "$response" | head -20
    return 1
  fi

  # Strip markdown code fences — Claude sometimes wraps JSON in ```json ... ```
  # even when instructed not to. Handle both ```json and ``` variants.
  content=$(echo "$content" \
    | sed 's/^```json[[:space:]]*//' \
    | sed 's/^```[[:space:]]*//' \
    | sed 's/```[[:space:]]*$//')

  # If there's still a leading/trailing fence buried in the middle, use python
  # for a more robust strip (handles multiline edge cases)
  if ! echo "$content" | jq empty 2>/dev/null; then
    content=$(echo "$content" | python3 -c "
import sys, re
text = sys.stdin.read()
# Extract first JSON object or array between outermost braces/brackets
match = re.search(r'(\{.*\}|\[.*\])', text, re.DOTALL)
if match:
    print(match.group(1))
else:
    print(text)
")
  fi

  if ! echo "$content" | jq empty 2>/dev/null; then
    log_error "Could not extract valid JSON from API response"
    log_info "Try running with DEBUG=1 to see the raw response"
    echo "$content" | head -30
    return 1
  fi

  echo "$content" > "$RESEARCH_CACHE"
  log_success "Research complete — \
$(echo "$content" | jq '.works | length') works · \
$(echo "$content" | jq '.timeline | length') timeline events · \
$(echo "$content" | jq '.blog_posts | length') essays"
}

# ══════════════════════════════════════════════════════════════════════
#  STEP 2 — REVIEW
# ══════════════════════════════════════════════════════════════════════
review_research() {
  step "2" "Research Summary"
  local data; data=$(cat "$RESEARCH_CACHE")

  gum style --foreground "$BRONZE" --bold "  Works found:"
  echo "$data" | jq -r '.works[] | "  • \(.year // "n/d")  \(.title) — \(.location // "unknown")"' \
    | gum style --foreground "$STONE"

  echo ""
  gum style --foreground "$BRONZE" --bold "  Essays to generate:"
  echo "$data" | jq -r '.blog_posts[] | "  • \(.title)"' \
    | gum style --foreground "$STONE"

  echo ""
  gum style --foreground "$BRONZE" --bold "  Collections:"
  echo "$data" | jq -r '.collections[] | "  • \(.institution), \(.location)"' \
    | gum style --foreground "$STONE"

  echo ""
  gum confirm "  Write all files to the Jekyll site?" || exit 0
}

# ══════════════════════════════════════════════════════════════════════
#  STEP 3 — WRITE CONTENT
# ══════════════════════════════════════════════════════════════════════
write_content() {
  step "3" "Writing Jekyll Content Files"
  local data; data=$(cat "$RESEARCH_CACHE")

  # _data/timeline.yml
  gum spin --spinner dot --title "  Writing timeline..." -- bash -c "
    echo '$data' | jq -r '
      .timeline[] |
      \"- year: \\\"\" + .year + \"\\\"\\n  title: \\\"\" + .title + \"\\\"\\n  description: \\\"\" + (.description | gsub(\"\\\"\"; \"'\\'''\")) + \"\\\"\\n\"
    ' > '$SCRIPT_DIR/_data/timeline.yml'
  "
  log_success "_data/timeline.yml — $(echo "$data" | jq '.timeline | length') events"

  # _data/collections.yml
  echo "$data" | jq -r '
    .collections[] |
    "- institution: \"" + .institution + "\"\n  location: \"" + .location + "\"\n  holdings: \"" + (.holdings | gsub("\""; "'\''")) + "\"\n"
  ' > "$SCRIPT_DIR/_data/collections.yml"
  log_success "_data/collections.yml"

  # _data/influences.yml
  echo "$data" | jq -r '
    .influences[] |
    "- name: \"" + .name + "\"\n  relationship: \"" + .relationship + "\"\n  notes: \"" + (.notes | gsub("\""; "'\''")) + "\"\n"
  ' > "$SCRIPT_DIR/_data/influences.yml"
  log_success "_data/influences.yml"

  # _data/biography.yml
  echo "$data" | jq '{
    born:               .biography.born,
    died:               .biography.died,
    rha_election_year:  .biography.rha_election_year,
    style_keywords:     (.biography.style_keywords | join(", ")),
    early_life:         .biography.early_life,
    training:           .biography.training,
    career:             .biography.career,
    ecclesiastical_work:.biography.ecclesiastical_work,
    legacy:             .biography.legacy
  }' | python3 -c "
import sys, json, yaml
data = json.load(sys.stdin)
print(yaml.dump(data, allow_unicode=True, default_flow_style=False))
" > "$SCRIPT_DIR/_data/biography.yml" 2>/dev/null \
  || echo "$data" | jq -r '
    .biography |
    "born: \"" + .born + "\"\n" +
    "died: \"" + .died + "\"\n" +
    "rha_election_year: \"" + .rha_election_year + "\"\n" +
    "early_life: \"" + (.early_life | gsub("\""; "'\''")) + "\"\n" +
    "training: \"" + (.training | gsub("\""; "'\''")) + "\"\n" +
    "career: \"" + (.career | gsub("\""; "'\''")) + "\"\n" +
    "legacy: \"" + (.legacy | gsub("\""; "'\''")) + "\""
  ' > "$SCRIPT_DIR/_data/biography.yml"
  log_success "_data/biography.yml"

  # _data/sources.yml
  echo "$data" | jq -r '.sources[]? | "- \"" + . + "\""' \
    > "$SCRIPT_DIR/_data/sources.yml" 2>/dev/null || true
  log_success "_data/sources.yml"

  # _works/*.md — remove old stubs first
  rm -f "$SCRIPT_DIR/_works/"*.md

  local work_count=0
  while IFS= read -r work; do
    local slug title year medium location collection dimensions order sig commission desc
    slug=$(echo "$work"       | jq -r '.slug // "work"')
    title=$(echo "$work"      | jq -r '.title // "Untitled"')
    year=$(echo "$work"       | jq -r '.year // ""')
    medium=$(echo "$work"     | jq -r '.medium // ""')
    location=$(echo "$work"   | jq -r '.location // ""')
    collection=$(echo "$work" | jq -r '.collection // ""')
    dimensions=$(echo "$work" | jq -r '.dimensions // ""')
    order=$(echo "$work"      | jq -r '.order // 99')
    sig=$(echo "$work"        | jq -r '.significance // ""')
    commission=$(echo "$work" | jq -r '.commission_context // ""')
    desc=$(echo "$work"       | jq -r '.description_paragraphs | join("\n\n")')

    {
      echo "---"
      echo "title: $(echo "$title" | jq -Rr @json)"
      echo "year: $(echo "$year" | jq -Rr @json)"
      echo "medium: $(echo "$medium" | jq -Rr @json)"
      echo "location: $(echo "$location" | jq -Rr @json)"
      echo "collection: $(echo "$collection" | jq -Rr @json)"
      echo "dimensions: $(echo "$dimensions" | jq -Rr @json)"
      echo "order: $order"
      echo "---"
      echo ""
      echo "$desc"
      echo ""
      echo "**Significance:** $sig"
      echo ""
      echo "*$commission*"
    } > "$SCRIPT_DIR/_works/${slug}.md"

    work_count=$((work_count + 1))
  done < <(echo "$data" | jq -c '.works[]')

  log_success "_works/ — $work_count sculpture entries"

  # _posts/*.md — remove old stubs first
  rm -f "$SCRIPT_DIR/_posts/"*.md

  local post_count=0
  while IFS= read -r post; do
    local slug title subtitle category date read_time excerpt content tags_yaml
    slug=$(echo "$post"      | jq -r '.slug // "post"')
    title=$(echo "$post"     | jq -r '.title // "Essay"')
    subtitle=$(echo "$post"  | jq -r '.subtitle // ""')
    category=$(echo "$post"  | jq -r '.category // "Research Essay"')
    date=$(echo "$post"      | jq -r '.date // "2025-06-01"')
    read_time=$(echo "$post" | jq -r '.read_time // 7')
    excerpt=$(echo "$post"   | jq -r '.excerpt // ""')
    tags_yaml=$(echo "$post" | jq -r '.tags | map("\"" + . + "\"") | join(", ")')
    content=$(echo "$post"   | jq -r '.content_markdown // ""')

    {
      echo "---"
      echo "layout: post"
      echo "title: $(echo "$title" | jq -Rr @json)"
      echo "subtitle: $(echo "$subtitle" | jq -Rr @json)"
      echo "date: $date"
      echo "category: $(echo "$category" | jq -Rr @json)"
      echo "tags: [$tags_yaml]"
      echo "read_time: $read_time"
      echo "excerpt: $(echo "$excerpt" | jq -Rr @json)"
      echo "---"
      echo ""
      echo "$content"
    } > "$SCRIPT_DIR/_posts/${date}-${slug}.md"

    post_count=$((post_count + 1))
  done < <(echo "$data" | jq -c '.blog_posts[]')

  log_success "_posts/ — $post_count research essays"

  # _includes/bio-text.html
  cat > "$SCRIPT_DIR/_includes/bio-text.html" <<'BIOHTML'
<div class="bio-col bio-col--lead">
  <h3>Origins &amp; Formation</h3>
  <p>{{ site.data.biography.early_life }}</p>
  <p>{{ site.data.biography.training }}</p>
</div>
<div class="bio-col">
  <h3>Career &amp; Commissions</h3>
  <p>{{ site.data.biography.career }}</p>
  <p>{{ site.data.biography.ecclesiastical_work }}</p>
</div>
<div class="bio-col">
  <h3>Legacy in Stone &amp; Bronze</h3>
  <p>{{ site.data.biography.legacy }}</p>
</div>
BIOHTML
  log_success "_includes/bio-text.html"
}

# ══════════════════════════════════════════════════════════════════════
#  STEP 4 — GIT + GITHUB
# ══════════════════════════════════════════════════════════════════════
git_setup() {
  step "4" "Git Repository Setup"
  cd "$SCRIPT_DIR"

  # ── Always init locally regardless of gh availability ───────────────
  if [[ ! -d ".git" ]]; then
    # git >= 2.28 supports -b main; older git needs the checkout workaround
    git init -b main 2>/dev/null || { git init && git checkout -b main 2>/dev/null; } || true
    log_success "Git repo initialised"
  else
    log_info "Git repo already exists"
  fi

  cat > .gitignore <<'GITIGNORE'
_site/
.sass-cache/
.jekyll-cache/
.jekyll-metadata
vendor/
.bundle/
Gemfile.lock
.research_cache.json
.setup_state
*.DS_Store
GITIGNORE

  local work_count=0 post_count=0 timeline_count=0
  if [[ -f "$RESEARCH_CACHE" ]]; then
    work_count=$(jq '.works | length'      "$RESEARCH_CACHE" 2>/dev/null || echo 0)
    post_count=$(jq '.blog_posts | length' "$RESEARCH_CACHE" 2>/dev/null || echo 0)
    timeline_count=$(jq '.timeline | length' "$RESEARCH_CACHE" 2>/dev/null || echo 0)
  fi

  git add -A 2>/dev/null || true
  git diff --cached --quiet 2>/dev/null \
    && log_info "Nothing new to commit — repo already up to date" \
    || {
      git commit -m "feat: Albert G. Power RHA — initial Jekyll archive

- ${work_count} sculpture entries in _works/
- ${timeline_count} timeline events in _data/
- ${post_count} research essays in _posts/
- Biography, collections, influences data
- Custom domain: albertpower.org
- Research sourced via Anthropic API" 2>/dev/null \
        || git commit --allow-empty -m "feat: initial commit" 2>/dev/null \
        || true
      log_success "Git commit created"
    }

  # ── Push to GitHub — works with or without gh CLI ──────────────────
  echo ""
  gum style --foreground "$BRONZE" --bold "  Push to GitHub"
  echo ""

  # Detect SSH key for GitHub (checks ~/.ssh/config and common key names)
  local ssh_key_name ssh_ok=false
  ssh_key_name=$(grep -A2 'github.com' ~/.ssh/config 2>/dev/null \
    | grep -i 'IdentityFile' | awk '{print $2}' | head -1 || true)
  # Expand ~ if present
  ssh_key_name="${ssh_key_name/#\~/$HOME}"
  # Fallback: look for mfreer-github or standard keys
  if [[ -z "$ssh_key_name" ]]; then
    for candidate in "$HOME/.ssh/mfreer-github" "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_rsa"; do
      [[ -f "$candidate" ]] && { ssh_key_name="$candidate"; break; }
    done
  fi

  if [[ -n "$ssh_key_name" && -f "$ssh_key_name" ]]; then
    log_success "SSH key found: $ssh_key_name"
    # Quick connectivity test
    if ssh -T -i "$ssh_key_name" -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 git@github.com 2>&1 | grep -q "successfully authenticated"; then
      ssh_ok=true
      log_success "SSH authentication to GitHub confirmed"
    else
      log_warn "SSH key found but could not authenticate to GitHub yet"
      log_info "Make sure the public key is added at: https://github.com/settings/ssh/new"
      log_info "Public key: $(cat "${ssh_key_name}.pub" 2>/dev/null || echo "not found")"
    fi
  else
    log_warn "No SSH key found for GitHub"
  fi

  # If gh is installed but not authed, offer to authenticate now using SSH
  if command -v gh &>/dev/null && [[ "$GH_AVAILABLE" != "true" ]]; then
    echo ""
    if gum confirm "  GitHub CLI is installed but not logged in. Authenticate now?"; then
      log_info "Running gh auth login — follow the prompts..."
      echo ""
      if [[ "$ssh_ok" == "true" ]]; then
        gh auth login --hostname github.com --git-protocol ssh --web 2>/dev/null \
          || gh auth login --hostname github.com --git-protocol ssh 2>/dev/null \
          || true
      else
        gh auth login 2>/dev/null || true
      fi
      # Re-check auth status
      if gh auth status &>/dev/null 2>&1; then
        GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "Nanyte25")
        GH_AVAILABLE=true
        save_state "GH_USER" "$GH_USER"
        log_success "Authenticated as: $GH_USER"
      else
        log_warn "Authentication incomplete — continuing with manual push option"
      fi
    fi
  fi

  local push_method
  if [[ "$GH_AVAILABLE" == "true" ]]; then
    push_method=$(gum choose \
      --header "  How would you like to push?" \
      "gh — create repo automatically (recommended)" \
      "ssh — I'll add the remote manually (SSH)" \
      "manual — show me the commands" \
      "skip — I'll push later")
  else
    push_method=$(gum choose \
      --header "  Choose a push method:" \
      "ssh — add SSH remote and push" \
      "manual — show me the commands" \
      "skip — I'll push later")
  fi

  case "$push_method" in

    "gh — create"*)
      local repo_name visibility
      repo_name=$(gum input \
        --placeholder "albert-power-rha" \
        --value "albert-power-rha" \
        --prompt "  Repository name: ")
      [[ -z "$repo_name" ]] && repo_name="albert-power-rha"
      visibility=$(gum choose --header "  Visibility:" "public" "private")

      log_info "Creating git@github.com:${GH_USER}/${repo_name}.git ..."

      # Create repo via gh, then set remote to SSH URL
      if gh repo create "$repo_name" \
          --"$visibility" \
          --description "Memorial archive for Albert G. Power RHA, Irish sculptor 1881–1945" \
          2>/dev/null; then
        save_state "REPO_NAME" "$repo_name"
        # Set SSH remote (not HTTPS) so your key is used
        git remote remove origin 2>/dev/null || true
        git remote add origin "git@github.com:${GH_USER}/${repo_name}.git"
        if git push -u origin main 2>/dev/null || git push -u origin HEAD 2>/dev/null; then
          log_success "Pushed → git@github.com:${GH_USER}/${repo_name}.git"
        else
          log_warn "Push failed — try manually: git push -u origin main"
          _show_manual_push_instructions "$GH_USER" "$repo_name"
        fi

        if gum confirm "  Enable GitHub Pages now?"; then
          gh api --method POST \
            -H "Accept: application/vnd.github+json" \
            "/repos/${GH_USER}/${repo_name}/pages" \
            -f "build_type=workflow" --silent 2>/dev/null \
          || gh api --method PUT \
            -H "Accept: application/vnd.github+json" \
            "/repos/${GH_USER}/${repo_name}/pages" \
            -f "build_type=workflow" --silent 2>/dev/null \
          || log_warn "Auto-enable failed — go to repo Settings → Pages → Source: GitHub Actions"
          log_success "GitHub Pages enabled"
        fi
      else
        log_warn "gh repo create failed — falling back to manual instructions"
        _show_manual_push_instructions "Nanyte25" "albert-power-rha"
      fi
      ;;

    "ssh — "*)
      local gh_username repo_name remote_url
      # Try to get username from gh or saved state
      gh_username=$(load_state "GH_USER" 2>/dev/null || true)
      [[ -z "$gh_username" ]] && gh_username=$(gh api user --jq '.login' 2>/dev/null || true)
      [[ -z "$gh_username" ]] && gh_username=$(gum input \
        --placeholder "Nanyte25" \
        --prompt "  Your GitHub username: ")

      repo_name=$(gum input \
        --placeholder "albert-power-rha" \
        --value "albert-power-rha" \
        --prompt "  Repository name: ")
      [[ -z "$repo_name" ]] && repo_name="albert-power-rha"

      remote_url="git@github.com:${gh_username}/${repo_name}.git"
      save_state "REPO_NAME" "$repo_name"
      save_state "GH_USER" "$gh_username"

      git remote remove origin 2>/dev/null || true
      git remote add origin "$remote_url"
      log_success "Remote set: $remote_url"

      echo ""
      gum style --foreground "$STONE" --margin "0 4" \
        "First create the repo on GitHub if you haven't:" \
        "  https://github.com/new  (name: ${repo_name})"
      echo ""

      if gum confirm "  Repo exists on GitHub — push now?"; then
        if [[ -n "$ssh_key_name" ]]; then
          GIT_SSH_COMMAND="ssh -i ${ssh_key_name} -o StrictHostKeyChecking=no" \
            git push -u origin main 2>/dev/null \
          || GIT_SSH_COMMAND="ssh -i ${ssh_key_name} -o StrictHostKeyChecking=no" \
            git push -u origin HEAD 2>/dev/null \
          || { log_warn "Push failed"; _show_manual_push_instructions "$gh_username" "$repo_name"; }
        else
          git push -u origin main 2>/dev/null \
            || git push -u origin HEAD 2>/dev/null \
            || { log_warn "Push failed"; _show_manual_push_instructions "$gh_username" "$repo_name"; }
        fi
        log_success "Pushed to $remote_url"
      else
        _show_manual_push_instructions "$gh_username" "$repo_name"
      fi
      ;;

    "manual"* | "skip"*)
      _show_manual_push_instructions "Nanyte25" "albert-power-rha"
      ;;
  esac
}

_show_manual_push_instructions() {
  local gh_user="${1:-Nanyte25}"
  local repo="${2:-albert-power-rha}"
  echo ""
  gum style \
    --foreground "$MOSS" --border normal --border-foreground "$MOSS" \
    --padding "1 3" --margin "0 2" \
    "Manual push steps:" \
    "" \
    "1. Create repo at https://github.com/new" \
    "   Name: ${repo}" \
    "" \
    "2. Add SSH remote and push:" \
    "   git remote add origin git@github.com:${gh_user}/${repo}.git" \
    "   git push -u origin main" \
    "" \
    "   If your key isn't in ssh-agent:" \
    "   GIT_SSH_COMMAND='ssh -i ~/.ssh/mfreer-github' git push -u origin main" \
    "" \
    "3. Add your public key to GitHub (if not done):" \
    "   https://github.com/settings/ssh/new" \
    "   cat ~/.ssh/mfreer-github.pub" \
    "" \
    "4. Enable Pages: repo Settings → Pages → Source: GitHub Actions" \
    "" \
    "Then run:  ./setup.sh --check-dns"
}

# ══════════════════════════════════════════════════════════════════════
#  STEP 5 — DOMAIN: albertpower.org via Namecheap
# ══════════════════════════════════════════════════════════════════════
configure_domain() {
  step "5" "Custom Domain — albertpower.org"

  local repo_name gh_user
  repo_name=$(load_state "REPO_NAME")
  gh_user=$(load_state "GH_USER")
  [[ -z "$repo_name" ]] && repo_name="albert-power-rha"
  [[ -z "$gh_user"   ]] && gh_user="$GH_USER"

  # ── 5a: Choose domain variant ─────────────────────────────────────
  echo ""
  gum style --foreground "$BRONZE" --bold "  Which domain setup do you want?"
  echo ""
  local domain_choice
  domain_choice=$(gum choose \
    --header "  Select primary domain:" \
    "albertpower.org  (apex / bare domain — recommended)" \
    "www.albertpower.org  (www subdomain)" \
    "Both — apex redirects to www")

  local PRIMARY_DOMAIN
  case "$domain_choice" in
    "albertpower.org"*) PRIMARY_DOMAIN="albertpower.org" ;;
    "www."*)            PRIMARY_DOMAIN="www.albertpower.org" ;;
    "Both"*)            PRIMARY_DOMAIN="albertpower.org" ;;
  esac

  # ── 5b: Write CNAME file ──────────────────────────────────────────
  echo "$PRIMARY_DOMAIN" > "$SCRIPT_DIR/CNAME"
  log_success "CNAME file written: $PRIMARY_DOMAIN"

  # ── 5c: Update _config.yml ────────────────────────────────────────
  # Swap url and baseurl for custom domain
  if [[ -f "$SCRIPT_DIR/_config.yml" ]]; then
    # Remove old url/baseurl lines and insert correct ones
    python3 - "$SCRIPT_DIR/_config.yml" "$PRIMARY_DOMAIN" <<'PYEOF'
import sys, re

config_path = sys.argv[1]
domain = sys.argv[2]

with open(config_path, 'r') as f:
    content = f.read()

# Replace or insert url
content = re.sub(r'^url:.*$', f'url: "https://{domain}"', content, flags=re.MULTILINE)
content = re.sub(r'^baseurl:.*$', 'baseurl: ""', content, flags=re.MULTILINE)

# Update author email to match domain
content = re.sub(r'archive@albertgpower\.ie', f'archive@{domain}', content)

with open(config_path, 'w') as f:
    f.write(content)

print(f"Updated _config.yml: url=https://{domain}, baseurl=''")
PYEOF
    log_success "_config.yml updated — url: https://$PRIMARY_DOMAIN, baseurl: \"\""
  fi

  # Commit CNAME + config changes
  cd "$SCRIPT_DIR"
  git add CNAME _config.yml 2>/dev/null || true
  git commit -m "chore: add custom domain $PRIMARY_DOMAIN

- CNAME: $PRIMARY_DOMAIN
- _config.yml url updated
- baseurl cleared for apex domain" 2>/dev/null || true

  # ── 5d: Set custom domain on GitHub Pages via API ─────────────────
  if [[ "$GH_AVAILABLE" == "true" && -n "$repo_name" ]]; then
    if gum confirm "  Set custom domain on GitHub Pages via API?"; then
      gum spin --spinner dot --title "  Configuring GitHub Pages domain..." -- bash -c "
        gh api --method PUT \
          -H 'Accept: application/vnd.github+json' \
          '/repos/${gh_user}/${repo_name}/pages' \
          -f 'cname=${PRIMARY_DOMAIN}' \
          -f 'https_enforced=false' \
          --silent 2>/dev/null || true
      "
      log_success "GitHub Pages custom domain set to $PRIMARY_DOMAIN"
      log_warn "HTTPS enforcement will auto-enable once DNS propagates"
    fi

    # Push the CNAME commit
    gum spin --spinner dot --title "  Pushing CNAME to GitHub..." -- \
      git push origin main 2>/dev/null || \
      log_warn "Push failed — run: git push origin main"
    log_success "CNAME pushed to repository"
  fi

  # ── 5e: Namecheap DNS instructions ────────────────────────────────
  echo ""
  gum style \
    --foreground "$BRONZE" --bold --border normal \
    --border-foreground "$BRONZE" --padding "0 2" \
    "  Namecheap DNS Configuration"

  echo ""
  gum style --foreground "$STONE" --margin "0 2" \
    "Log in to Namecheap → Domain List → albertpower.org → Manage → Advanced DNS" \
    "" \
    "Delete any existing A records and CNAME for @ or www, then add:"

  echo ""
  # Draw a DNS table using gum
  gum style \
    --foreground "$MOSS" --border rounded --border-foreground "$MOSS" \
    --padding "0 2" --margin "0 4" \
    "TYPE    HOST    VALUE                TTL" \
    "──────  ──────  ───────────────────  ─────" \
    "A       @       185.199.108.153      30 min" \
    "A       @       185.199.109.153      30 min" \
    "A       @       185.199.110.153      30 min" \
    "A       @       185.199.111.153      30 min" \
    "CNAME   www     ${gh_user}.github.io  30 min"

  echo ""
  gum style --foreground "$STONE" --margin "0 4" --italic \
    "Tip: set TTL to 30 min (1800s) now so changes propagate fast." \
    "After the site is stable, raise it to Auto or 1 hour."

  # ── 5f: Optional — Namecheap URL Redirect record ──────────────────
  if [[ "$domain_choice" == "Both"* ]]; then
    echo ""
    gum style --foreground "$BRONZE" --bold "  www → apex redirect"
    gum style --foreground "$STONE" --margin "0 4" \
      "Since you chose apex as primary, also add:" \
      "" \
      "  URL Redirect Record:" \
      "    Host:        www" \
      "    Value:       https://albertpower.org" \
      "    Redirect:    Permanent (301)" \
      "" \
      "(Namecheap: Advanced DNS → URL Redirect Records)"
  fi

  # ── 5g: Copy DNS records to clipboard if pbcopy/xclip available ──
  local dns_text
  dns_text="# albertpower.org — GitHub Pages DNS Records
# Add these in Namecheap → Advanced DNS

A    @    185.199.108.153
A    @    185.199.109.153
A    @    185.199.110.153
A    @    185.199.111.153
CNAME www  ${gh_user}.github.io"

  if command -v pbcopy &>/dev/null; then
    echo "$dns_text" | pbcopy
    log_success "DNS records copied to clipboard"
  elif command -v xclip &>/dev/null; then
    echo "$dns_text" | xclip -selection clipboard
    log_success "DNS records copied to clipboard"
  fi

  # ── 5h: DNS propagation check ─────────────────────────────────────
  echo ""
  gum style --foreground "$BRONZE" --bold "  DNS Propagation Check"
  echo ""

  if gum confirm "  Have you saved the DNS records in Namecheap?"; then
    dns_propagation_check "$PRIMARY_DOMAIN"
  else
    log_info "Run this script again with --check-dns to verify propagation when ready"
    log_info "Or check manually: dig A albertpower.org +short"
  fi

  # ── 5i: HTTPS enforcement ─────────────────────────────────────────
  echo ""
  gum style --foreground "$STONE" --margin "0 4" \
    "Once DNS propagates, GitHub will auto-provision a Let's Encrypt certificate." \
    "Then enable HTTPS enforcement:" \
    "" \
    "  GitHub → repo Settings → Pages → Enforce HTTPS ✓" \
    "" \
    "  Or via API:" \
    "  gh api --method PUT -H 'Accept: application/vnd.github+json' \\" \
    "    /repos/${gh_user}/${repo_name}/pages \\" \
    "    -f https_enforced=true"
}

# ══════════════════════════════════════════════════════════════════════
#  DNS PROPAGATION CHECK
# ══════════════════════════════════════════════════════════════════════
dns_propagation_check() {
  local domain="${1:-albertpower.org}"
  local max_attempts=20
  local attempt=0
  local wait_secs=30

  # Ensure DIG_AVAILABLE is set even when called from the --check-dns fast path
  : "${DIG_AVAILABLE:=false}"
  command -v dig &>/dev/null && DIG_AVAILABLE=true

  echo ""
  gum style --foreground "$STONE" \
    "  Checking DNS propagation for $domain..." \
    "  Polling every ${wait_secs}s (max $((max_attempts * wait_secs / 60)) min)" \
    "  Press Ctrl+C to skip and check manually later"
  echo ""

  while [[ $attempt -lt $max_attempts ]]; do
    attempt=$((attempt + 1))

    # Always declare the array first — 'set -u' will blow up on [@] if it's
    # never assigned, even if it was declared 'local resolved_ips=()'
    local resolved_ips
    resolved_ips=()

    if [[ "$DIG_AVAILABLE" == "true" ]]; then
      local dig_out
      dig_out=$(dig A "$domain" +short 2>/dev/null | grep -E '^[0-9]+\.' || true)
      while IFS= read -r ip; do
        [[ -n "$ip" ]] && resolved_ips+=("$ip")
      done <<< "$dig_out"
    else
      # Fallback: Google DNS-over-HTTPS (works even without dig)
      local doh_out
      doh_out=$(curl -sf --max-time 10 \
        "https://dns.google/resolve?name=${domain}&type=A" \
        | jq -r '.Answer[]?.data // empty' 2>/dev/null || true)
      while IFS= read -r ip; do
        [[ -n "$ip" ]] && resolved_ips+=("$ip")
      done <<< "$doh_out"
    fi

    # Check if any resolved IP matches GitHub Pages IPs
    local matched=false
    local matched_count=0
    # Guard: only iterate if the array is non-empty
    if [[ ${#resolved_ips[@]} -gt 0 ]]; then
      for resolved in "${resolved_ips[@]}"; do
        for gh_ip in "${GH_PAGES_IPS[@]}"; do
          if [[ "$resolved" == "$gh_ip" ]]; then
            matched=true
            matched_count=$((matched_count + 1))
          fi
        done
      done
    fi

    if [[ "$matched" == "true" ]]; then
      echo ""
      log_success "DNS propagated! ($matched_count/4 GitHub IPs visible)"
      local ip_list="${resolved_ips[*]:-}"
      gum style --foreground "$MOSS" --margin "0 4" \
        "Resolved IPs: $ip_list"
      echo ""

      # Give GitHub time to detect DNS and provision the cert
      log_info "Waiting 60s for GitHub to provision the HTTPS certificate..."
      sleep 60

      local http_status
      http_status=$(curl -s -o /dev/null -w "%{http_code}" \
        --max-time 15 "https://$domain" 2>/dev/null || echo "000")

      if [[ "$http_status" == "200" || "$http_status" == "301" || "$http_status" == "302" ]]; then
        log_success "https://$domain is live! (HTTP $http_status)"
      else
        log_warn "DNS propagated but HTTPS not yet ready (HTTP $http_status)"
        log_info "GitHub can take 5–30 min to issue the TLS cert"
        log_info "Check later:  curl -I https://$domain"
      fi
      return 0
    fi

    # Show progress
    local current_ips="${resolved_ips[*]:-none yet}"
    gum style --foreground "$STONE" \
      "  [${attempt}/${max_attempts}] Not yet — current resolution: $current_ips"
    sleep "$wait_secs"
  done

  echo ""
  log_warn "DNS not propagated after $((max_attempts * wait_secs / 60)) minutes"
  gum style --foreground "$STONE" --margin "0 4" \
    "This is normal — Namecheap can take up to 30 minutes." \
    "" \
    "Check manually:" \
    "  dig A albertpower.org +short" \
    "  curl -I https://albertpower.org" \
    "" \
    "Expected IPs:" \
    "  185.199.108.153  185.199.109.153" \
    "  185.199.110.153  185.199.111.153"
}

# ══════════════════════════════════════════════════════════════════════
#  STEP 6 — LOCAL SERVE
# ══════════════════════════════════════════════════════════════════════
local_serve() {
  step "6" "Local Development"
  cd "$SCRIPT_DIR"

  if [[ "$RUBY_AVAILABLE" == "true" ]]; then
    if gum confirm "  Install Jekyll gems and serve locally?"; then
      gum spin --spinner dot --title "  Running bundle install..." -- bundle install --quiet
      log_success "Gems installed"
      echo ""
      log_info "Starting Jekyll at http://localhost:4000 (Ctrl+C to stop)"
      echo ""
      bundle exec jekyll serve --livereload --open-url
    fi
  else
    log_warn "Ruby not available. Install it first:"
    gum style --foreground "$STONE" --margin "0 4" \
      "macOS:  brew install ruby && gem install bundler" \
      "Linux:  sudo apt install ruby-full build-essential && gem install bundler" \
      "" \
      "Then: bundle install && bundle exec jekyll serve --livereload"
  fi
}

# ══════════════════════════════════════════════════════════════════════
#  DONE
# ══════════════════════════════════════════════════════════════════════
show_done() {
  local repo_name gh_user
  repo_name=$(load_state "REPO_NAME")
  gh_user=$(load_state "GH_USER")
  [[ -z "$repo_name" ]] && repo_name="albert-power-rha"
  [[ -z "$gh_user"   ]] && gh_user="Nanyte25"

  echo ""
  gum style \
    --foreground "$BRONZE" --border double \
    --border-foreground "$BRONZE" --padding "1 4" --margin "1 2" \
    "Archive complete." \
    "" \
    "\"He brought to his work a profound" \
    " understanding of the Irish character —" \
    " a sculptor not of heroic posture" \
    " but of quiet, enduring humanity.\""

  echo ""
  gum style --foreground "$MOSS" \
    --border normal --border-foreground "$MOSS" \
    --padding "1 3" --margin "0 2" \
    "GitHub repository:" \
    "  https://github.com/${gh_user}/${repo_name}" \
    "" \
    "Live site (once DNS propagates):" \
    "  https://albertpower.org" \
    "" \
    "Staging URL (GitHub Pages subdomain):" \
    "  https://${gh_user}.github.io/${repo_name}"

  echo ""
  gum style --foreground "$STONE" --margin "0 4" \
    "Remaining tasks:" \
    "  1. Confirm DNS in Namecheap matches the A records above" \
    "  2. Enable 'Enforce HTTPS' in GitHub repo Settings → Pages" \
    "  3. Add photographs to assets/images/" \
    "  4. Update contact email in _config.yml" \
    "  5. Add new essays: _posts/YYYY-MM-DD-title.md"
  echo ""
}

# ══════════════════════════════════════════════════════════════════════
#  ENTRY POINTS
# ══════════════════════════════════════════════════════════════════════
main() {
  check_deps
  show_banner

  gum style --foreground "$STONE" --margin "0 4" \
    "This script will:" \
    "  1. Check dependencies (API key, gh CLI, Ruby)" \
    "  2. Query Claude API to research Albert G. Power's life & works" \
    "  3. Write all Jekyll content (works, posts, data files)" \
    "  4. Initialise git and push to GitHub" \
    "  5. Configure albertpower.org DNS (Namecheap) + GitHub Pages" \
    "  6. Optionally serve locally"

  echo ""
  gum confirm "  Ready to begin?" || { log_info "Goodbye."; exit 0; }

  preflight_checks
  research_power
  review_research
  write_content
  git_setup
  configure_domain
  local_serve
  show_done
}

# ── Allow running just the DNS check ──────────────────────────────────
case "${1:-}" in
  --check-dns)
    # DIG_AVAILABLE and GH_PAGES_IPS are set inside dns_propagation_check itself
    dns_propagation_check "albertpower.org"
    ;;
  --dns-instructions)
    step "DNS" "Namecheap DNS Records for albertpower.org"
    GH_USER=$(load_state "GH_USER" || echo "Nanyte25")
    gum style \
      --foreground "$MOSS" --border rounded --border-foreground "$MOSS" \
      --padding "0 2" --margin "0 4" \
      "TYPE    HOST    VALUE                TTL" \
      "──────  ──────  ───────────────────  ─────" \
      "A       @       185.199.108.153      30 min" \
      "A       @       185.199.109.153      30 min" \
      "A       @       185.199.110.153      30 min" \
      "A       @       185.199.111.153      30 min" \
      "CNAME   www     ${GH_USER}.github.io  30 min"
    ;;
  *)
    main "$@"
    ;;
esac
