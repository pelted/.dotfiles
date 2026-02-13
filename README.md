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

### Already Have Homebrew?

```bash
brew install chezmoi
chezmoi init pelted/.dotfiles --apply
```

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
├── private_dot_config/
│   └── agent-instructions.md # Global AI assistant preferences
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
Global agent instructions at `~/.config/agent-instructions.md` for consistent AI assistant behavior.

## Requirements

- macOS
- [Homebrew](https://brew.sh/)
- [1Password](https://1password.com/) (for templated secrets)
