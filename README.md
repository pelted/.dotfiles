# .dotfiles

Modern, agent-focused dotfiles managed with [chezmoi](https://chezmoi.io/).

## What's Included

- **Shell**: Minimal zsh config (no oh-my-zsh) with fast startup
- **Prompt**: [Starship](https://starship.rs/) with Gruvbox Rainbow theme
- **Tools**: mise, zoxide, fzf, bat, ripgrep, and more
- **Secrets**: 1Password integration for sensitive config values
- **Agents**: Configurations for AI coding assistants

## Quick Start

### New Machine Setup

**Prerequisites:** Install [1Password](https://1password.com/downloads/mac/) and sign in first.

Then run the bootstrap script:

```bash
curl -fsSL https://raw.githubusercontent.com/pelted/.dotfiles/main/bootstrap.sh | bash
```

This will:
1. Install Xcode Command Line Tools (if needed)
2. Install Homebrew
3. Install chezmoi and 1Password CLI
4. Verify 1Password CLI integration
5. Apply all dotfiles

During `apply`, a few one-time scripts run **interactively**, so keep 1Password
unlocked and its CLI integration on:

- **GitHub CLI auth** (`run_once_after_configure_gh.sh`) — prompts you to pick an
  SSH key from 1Password and signs `gh` in over SSH.
- **1Password CLI plugins** (`run_once_after_configure_op_plugins.sh`) — runs
  `op plugin init` for heroku, ngrok, and openai.
- **Brew bundle + mise trust** (`run_once_after_setup.sh`) — installs everything
  in the Brewfile.
- **Private fonts** (`run_onchange_after_install_private_fonts.sh`) — licensed
  fonts from the private tap; needs the GitHub CLI auth above.

### Already Have Homebrew?

```bash
brew install chezmoi
chezmoi init pelted/.dotfiles --apply
```

### After Setup

Once `apply` finishes:

1. Restart your shell: `exec zsh`
2. Sign in to the 1Password CLI if needed: `op signin`
3. Install language runtimes: `mise use ruby@3.3 node@lts`
4. Confirm the templated git identity resolved: `git config user.email`
   (pulled from 1Password via `~/.gitconfig`)
5. Confirm `~/.context` cloned (see [Private Context Repos](#private-context-repos))

### Updating

```bash
chezmoi update
```

### Adding/Changing Files

```bash
# After editing a dotfile directly
chezmoi re-add

# Edit via chezmoi (opens in $EDITOR)
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff
```

## Structure

```
├── Brewfile                 # Homebrew packages
├── dot_zshrc                # Main shell config
├── dot_zprofile             # Login shell
├── dot_zshenv               # Environment variables
├── dot_gitconfig.tmpl       # Git config (1Password template)
├── dot_gitignore_global     # Global gitignore
├── dot_config/
│   ├── starship.toml        # Prompt configuration
│   └── mise/
│       └── config.toml      # Version manager config
├── .chezmoiexternal.toml    # Clones private context-global repo into ~/.context
├── run_once_after_setup.sh  # One-time setup script
├── run_onchange_brewfile.sh.tmpl # Auto-run brew bundle
└── run_onchange_after_install_private_fonts.sh # Licensed fonts from private tap
```

## Key Features

### Fast Shell Startup
No oh-my-zsh. Individual tools sourced directly for ~100ms startup.

### 1Password Integration
Secrets (git email, API keys) pulled from 1Password at apply time:
```
{{ onepasswordRead "op://Private/item/field" }}
```

### Private Fonts (Licensed)

Licensed fonts are installed from a private Homebrew tap ([`pelted/homebrew-casks`](https://github.com/pelted/homebrew-casks)) via `run_onchange_after_install_private_fonts.sh`.

This script:
- Authenticates using `gh auth token` for private release asset downloads
- Adds the private tap via SSH
- Installs any casks defined in the script

Because it's a `run_onchange_` script, it re-runs automatically whenever the script is modified. To add a new licensed font:

1. Add the font to the private tap repo (see its README for full instructions)
2. Add an install block to `run_onchange_after_install_private_fonts.sh`
3. Commit and push -- all machines will pick it up on `chezmoi update`

### Agent-Ready
Global agent instructions and cross-device context live in the **private**
`context-global` repo, cloned to `~/.context` via `.chezmoiexternal.toml`
(kept out of this public repo). `~/.context/agent-instructions.md` is the
source of truth for AI assistant behavior; Claude Code (`~/.claude/CLAUDE.md`)
and Codex (`~/.codex/AGENTS.md`) are thin pointers into it.

### Private Context Repos

`context-global` is a **private** repo, so the `~/.context` clone in
`.chezmoiexternal.toml` needs GitHub auth. On a brand-new machine the first
`chezmoi apply` runs the external clone *before* the GitHub CLI step has
signed you in, so that clone can fail the first time. Fix: after the `gh` auth
prompt completes, run `chezmoi apply` (or `chezmoi update`) again and `~/.context`
will pull.

Per-project context lives in sibling `context-<project>` repos (e.g.
`context-k2`), cloned manually into each project's `.private/` directory as you
set that project up — they are not managed by chezmoi. See `~/.context/dashboard.md`
for the full repo family.

## Requirements

- macOS
- [Homebrew](https://brew.sh/)
- [1Password](https://1password.com/) (for templated secrets)
