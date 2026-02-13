#!/bin/bash
# One-time setup for new machines
# This runs once after chezmoi apply

set -e

echo "🚀 Running one-time setup..."

# ============================================================================
# Install Homebrew if not present
# ============================================================================
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================================================
# Install tools via Brewfile
# ============================================================================
echo "📦 Installing packages from Brewfile..."
brew bundle --file="$HOME/.local/share/chezmoi/Brewfile"

# ============================================================================
# Configure 1Password CLI
# ============================================================================
if command -v op &> /dev/null; then
    echo "🔐 1Password CLI is installed"
    echo "   Run 'op signin' to authenticate if needed"
fi

# ============================================================================
# Initialize mise
# ============================================================================
if command -v mise &> /dev/null; then
    echo "🔧 Activating mise..."
    mise trust --all
fi

# ============================================================================
# Configure fzf
# ============================================================================
if command -v fzf &> /dev/null; then
    echo "🔍 fzf is ready"
fi

# ============================================================================
# Set up zsh completions
# ============================================================================
echo "🐚 Setting up zsh completions..."
if [[ ! -d ~/.zfunc ]]; then
    mkdir -p ~/.zfunc
fi

# ============================================================================
# Done
# ============================================================================
echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or run: exec zsh)"
echo "  2. Sign in to 1Password CLI: op signin"
echo "  3. Configure git signing key in ~/.gitconfig"
echo "  4. Install language versions: mise use ruby@3.3 node@lts"
echo ""
