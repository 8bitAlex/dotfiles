# dotfiles

My shell environment — zsh (Oh My Zsh), the [Starship](https://starship.rs)
prompt (Gruvbox Rainbow), and [Oh My Tmux](https://github.com/gpakosz/.tmux)
with a custom Gruvbox status bar + a keybinding cheatsheet row.

## New machine

```sh
git clone <this-repo-url> ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

`install.sh` is idempotent — it installs Homebrew, the Brewfile packages, Oh My
Zsh and Oh My Tmux (fresh, from upstream), then **symlinks** the tracked
dotfiles into place. Any existing real file it would replace is backed up to
`<file>.bak` first. Re-run anytime; `./install.sh --links-only` skips the
package/framework steps and just refreshes the symlinks + `~/.gitconfig`.

## What's tracked

| Repo path                          | Symlinked to                       |
|------------------------------------|------------------------------------|
| `home/.zshrc`                      | `~/.zshrc`                          |
| `home/.gitconfig.template`         | rendered to `~/.gitconfig`\*        |
| `config/starship.toml`             | `~/.config/starship.toml`           |
| `config/tmux/tmux.conf.local`      | `~/.config/tmux/tmux.conf.local`    |
| `config/tmux/cheatsheet-bar.sh`    | `~/.config/tmux/cheatsheet-bar.sh`  |
| `config/ghostty/config`            | `~/.config/ghostty/config`          |
| `Brewfile`                         | consumed by `brew bundle`           |

\* `~/.gitconfig` is **generated**, not symlinked: `install.sh` prompts for
name / email / GPG key and fills in `.gitconfig.template`, so personal details
stay out of this (public) repo.

## Not vendored (installed by the script)

- **Oh My Zsh** → `~/.oh-my-zsh` (upstream framework, self-updating)
- **Oh My Tmux** → `~/.local/share/tmux/oh-my-tmux`; `~/.config/tmux/tmux.conf`
  is symlinked to its `.tmux.conf`. My overrides live in `tmux.conf.local`.

## Notes

- The zsh config auto-starts a fresh tmux session on each interactive shell.
- A **Nerd Font** is required for the prompt glyphs and tmux powerline
  separators — the Brewfile installs `font-meslo-lg-nerd-font`; set your
  terminal to it after install.
- Editing any tracked file edits it in this repo directly (they're symlinks),
  so changes are ready to `git commit`.
