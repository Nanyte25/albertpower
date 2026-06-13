#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
#  install-deps.sh — Install gum, jq, gh, and ruby for the setup script
#  Run once before setup.sh
# ══════════════════════════════════════════════════════════════════════

set -euo pipefail

BRONZE="\033[38;2;139;115;85m"
MOSS="\033[38;2;74;103;65m"
STONE="\033[38;2;201;185;154m"
RESET="\033[0m"

ok()   { echo -e "${MOSS}  ✓  $*${RESET}"; }
info() { echo -e "${STONE}  ◆  $*${RESET}"; }
warn() { echo -e "${BRONZE}  ⚠  $*${RESET}"; }

echo ""
echo -e "${BRONZE}  Albert G. Power RHA — Dependency Installer${RESET}"
echo -e "${STONE}  ─────────────────────────────────────────────${RESET}"
echo ""

# ── Detect OS ──────────────────────────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ -f /etc/debian_version ]]; then
  OS="debian"
elif [[ -f /etc/redhat-release ]]; then
  OS="rhel"
else
  OS="unknown"
fi
info "Detected OS: $OS"
echo ""

# ── Homebrew (macOS) ───────────────────────────────────────────────────
install_macos() {
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    ok "Homebrew already installed"
  fi

  info "Installing tools via Homebrew..."
  brew install gum jq gh ruby 2>/dev/null || brew upgrade gum jq gh ruby 2>/dev/null || true

  # Bundler
  if ! command -v bundle &>/dev/null; then
    gem install bundler --no-document
  fi
}

# ── Debian/Ubuntu ──────────────────────────────────────────────────────
install_debian() {
  info "Updating apt..."
  sudo apt-get update -qq

  # jq
  if ! command -v jq &>/dev/null; then
    info "Installing jq..."
    sudo apt-get install -y jq
  else
    ok "jq already installed"
  fi

  # Ruby
  if ! command -v ruby &>/dev/null; then
    info "Installing Ruby..."
    sudo apt-get install -y ruby-full build-essential zlib1g-dev
    gem install bundler --no-document
  else
    ok "Ruby already installed"
  fi

  # gum — charmbracelet package repo
  if ! command -v gum &>/dev/null; then
    info "Installing gum (Charmbracelet)..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key \
      | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
      | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt-get update -qq
    sudo apt-get install -y gum
  else
    ok "gum already installed"
  fi

  # GitHub CLI
  if ! command -v gh &>/dev/null; then
    info "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt-get update -qq
    sudo apt-get install -y gh
  else
    ok "gh already installed"
  fi
}

# ── RHEL/Fedora ────────────────────────────────────────────────────────
install_rhel() {
  # jq
  if ! command -v jq &>/dev/null; then
    info "Installing jq..."
    sudo dnf install -y jq || sudo yum install -y jq
  else
    ok "jq already installed"
  fi

  # Ruby
  if ! command -v ruby &>/dev/null; then
    info "Installing Ruby..."
    sudo dnf install -y ruby ruby-devel || sudo yum install -y ruby ruby-devel
    gem install bundler --no-document
  else
    ok "Ruby already installed"
  fi

  # gum — binary release
  if ! command -v gum &>/dev/null; then
    info "Installing gum from GitHub release..."
    GUM_VER=$(curl -s https://api.github.com/repos/charmbracelet/gum/releases/latest \
      | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
    ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
    curl -Lo /tmp/gum.tar.gz \
      "https://github.com/charmbracelet/gum/releases/download/v${GUM_VER}/gum_${GUM_VER}_Linux_${ARCH}.tar.gz"
    tar -xzf /tmp/gum.tar.gz -C /tmp
    sudo mv /tmp/gum /usr/local/bin/gum
    rm /tmp/gum.tar.gz
  else
    ok "gum already installed"
  fi

  # GitHub CLI
  if ! command -v gh &>/dev/null; then
    info "Installing GitHub CLI..."
    sudo dnf install -y 'dnf-command(config-manager)' 2>/dev/null || true
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo 2>/dev/null \
      || sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh 2>/dev/null || sudo yum install -y gh
  else
    ok "gh already installed"
  fi
}

# ── Dispatch ───────────────────────────────────────────────────────────
case "$OS" in
  macos)  install_macos  ;;
  debian) install_debian ;;
  rhel)   install_rhel   ;;
  *)
    warn "Unknown OS — install these tools manually:"
    echo ""
    echo "  gum:  https://github.com/charmbracelet/gum#installation"
    echo "  jq:   https://jqlang.github.io/jq/download/"
    echo "  gh:   https://cli.github.com/"
    echo "  ruby: https://www.ruby-lang.org/en/documentation/installation/"
    echo ""
    ;;
esac

echo ""
info "Checking final status..."
echo ""
for cmd in gum jq git gh ruby bundle; do
  if command -v "$cmd" &>/dev/null; then
    ok "$cmd — $(command -v "$cmd")"
  else
    warn "$cmd — NOT FOUND"
  fi
done

echo ""
echo -e "${STONE}  ─────────────────────────────────────────────${RESET}"
echo ""
info "GitHub CLI auth (if not already done):"
echo -e "${STONE}    gh auth login${RESET}"
echo ""
info "Set your Anthropic API key:"
echo -e "${STONE}    export ANTHROPIC_API_KEY=sk-ant-...${RESET}"
echo ""
info "Then run the setup script:"
echo -e "${STONE}    ./setup.sh${RESET}"
echo ""
