#!/usr/bin/env bash
#
# Dotfiles installer — sets up a new machine with my shell environment:
#   Homebrew packages, Oh My Zsh, Oh My Tmux, Starship, and my dotfiles
#   (symlinked back to this repo so edits stay tracked).
#
# Usage:
#   ./install.sh              # full setup
#   ./install.sh --links-only # only (re)create the symlinks + ~/.gitconfig
#
# Safe to re-run: every step checks before acting, and any real file it would
# overwrite is backed up to <file>.bak first.

set -euo pipefail

# --- locations ---------------------------------------------------------------
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMZ_DIR="$HOME/.oh-my-zsh"
OMT_DIR="$HOME/.local/share/tmux/oh-my-tmux"

# --- pretty logging ----------------------------------------------------------
if [ -t 1 ]; then BLUE=$'\033[34m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'; else BLUE=; GREEN=; YELLOW=; RESET=; fi
log()  { printf '%s==>%s %s\n' "$BLUE" "$RESET" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s  !!%s %s\n' "$YELLOW" "$RESET" "$*"; }

LINKS_ONLY=0
[ "${1:-}" = "--links-only" ] && LINKS_ONLY=1

# --- symlink helper: back up any existing real file, then link ---------------
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "linked $dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    warn "backed up existing $dst -> $dst.bak"
  fi
  ln -s "$src" "$dst"
  ok "linked $dst -> $src"
}

# --- 1. Homebrew -------------------------------------------------------------
install_homebrew() {
  if command -v brew >/dev/null 2>&1; then ok "Homebrew present"; return; fi
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # make brew available for the rest of this run (Apple Silicon / Intel / Linux)
  for p in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [ -x "$p" ] && eval "$("$p" shellenv)" && break
  done
}

# --- 2. Homebrew packages ----------------------------------------------------
install_packages() {
  log "Installing packages from Brewfile"
  brew bundle --file "$DOTFILES/Brewfile"
}

# --- 3. Oh My Zsh (framework, installed fresh — not vendored) ----------------
install_omz() {
  if [ -d "$OMZ_DIR" ]; then ok "Oh My Zsh present"; return; fi
  log "Installing Oh My Zsh"
  # --unattended: don't run zsh or chsh here; we manage .zshrc ourselves
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

# --- 4. Oh My Tmux (framework, installed fresh) ------------------------------
install_omt() {
  if [ ! -d "$OMT_DIR" ]; then
    log "Cloning Oh My Tmux"
    git clone --depth 1 https://github.com/gpakosz/.tmux.git "$OMT_DIR"
  else
    ok "Oh My Tmux present"
  fi
  # XDG layout: ~/.config/tmux/tmux.conf -> the framework's .tmux.conf
  link "$OMT_DIR/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
}

# --- 5. Symlink dotfiles -----------------------------------------------------
link_dotfiles() {
  log "Linking dotfiles"
  link "$DOTFILES/home/.zshrc"                    "$HOME/.zshrc"
  link "$DOTFILES/config/starship.toml"           "$HOME/.config/starship.toml"
  link "$DOTFILES/config/tmux/tmux.conf.local"    "$HOME/.config/tmux/tmux.conf.local"
  link "$DOTFILES/config/tmux/cheatsheet-bar.sh"  "$HOME/.config/tmux/cheatsheet-bar.sh"
  chmod +x "$DOTFILES/config/tmux/cheatsheet-bar.sh"
}

# --- 6. Render ~/.gitconfig from the template (kept out of the repo) ----------
render_gitconfig() {
  local tpl="$DOTFILES/home/.gitconfig.template" dst="$HOME/.gitconfig"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    ok "~/.gitconfig already exists — leaving it untouched"
    return
  fi
  log "Setting up ~/.gitconfig"
  local name email key gpgsign
  read -r -p "  git user.name  [${GIT_NAME:-}]: " name;   name="${name:-${GIT_NAME:-}}"
  read -r -p "  git user.email [${GIT_EMAIL:-}]: " email; email="${email:-${GIT_EMAIL:-}}"
  read -r -p "  GPG signing key ID (blank = no signing): " key
  if [ -n "$key" ]; then gpgsign=true; else gpgsign=false; fi

  sed -e "s|{{GIT_NAME}}|$name|" \
      -e "s|{{GIT_EMAIL}}|$email|" \
      -e "s|{{GIT_SIGNINGKEY}}|$key|" \
      -e "s|{{GPGSIGN}}|$gpgsign|" \
      "$tpl" > "$dst"
  # drop the signingkey line entirely when no key was given
  [ -z "$key" ] && sed -i.tmp '/signingkey = *$/d' "$dst" && rm -f "$dst.tmp"
  ok "wrote $dst"
}

# --- 7. Make zsh the login shell --------------------------------------------
set_default_shell() {
  local zsh_path; zsh_path="$(command -v zsh)"
  if [ "${SHELL:-}" = "$zsh_path" ]; then ok "login shell already zsh"; return; fi
  grep -qx "$zsh_path" /etc/shells 2>/dev/null || { warn "add $zsh_path to /etc/shells then run: chsh -s $zsh_path"; return; }
  log "Changing login shell to zsh"
  chsh -s "$zsh_path" || warn "chsh failed — run manually: chsh -s $zsh_path"
}

main() {
  if [ "$LINKS_ONLY" -eq 1 ]; then
    link_dotfiles
    render_gitconfig
    log "Done (links only). Restart your shell."
    return
  fi
  install_homebrew
  install_packages
  install_omz
  install_omt
  link_dotfiles
  render_gitconfig
  set_default_shell
  log "All set. Start a new terminal (a fresh tmux session will auto-launch)."
}

main "$@"
