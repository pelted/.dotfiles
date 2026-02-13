#!/bin/bash
# =============================================================================
# Bootstrap script for new machines
# =============================================================================
# Run this on a fresh Mac:
#   curl -fsSL https://raw.githubusercontent.com/pelted/.dotfiles/main/bootstrap.sh | bash
#
# Or clone and run:
#   git clone https://github.com/pelted/.dotfiles.git ~/.dotfiles-temp
#   ~/.dotfiles-temp/bootstrap.sh
# =============================================================================

set -e

echo ""
echo "🖥️  Dotfiles Bootstrap"
echo "======================"
echo ""

# =============================================================================
# Prerequisites Check
# =============================================================================

# Check for macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Check for 1Password app (required for secrets)
if [[ ! -d "/Applications/1Password.app" ]]; then
    echo "⚠️  1Password app not found!"
    echo ""
    echo "Please install 1Password first:"
    echo "  1. Download from https://1password.com/downloads/mac/"
    echo "  2. Sign in to your account"
    echo "  3. Enable CLI integration: Settings → Developer → CLI"
    echo ""
    echo "Then re-run this script."
    exit 1
fi

echo "✅ 1Password app found"

# =============================================================================
# Install Xcode Command Line Tools (required for git, brew)
# =============================================================================
if ! xcode-select -p &> /dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    echo ""
    echo "⏳ Please complete the Xcode installation popup, then re-run this script."
    exit 0
fi

echo "✅ Xcode Command Line Tools installed"

# =============================================================================
# Install Homebrew
# =============================================================================
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add brew to path for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew already installed"
fi

# =============================================================================
# Install chezmoi and 1Password CLI
# =============================================================================
echo "📦 Installing chezmoi and 1Password CLI..."
brew install chezmoi 1password-cli

# =============================================================================
# Verify 1Password CLI is connected
# =============================================================================
echo ""
echo "🔐 Checking 1Password CLI..."

if ! op account list &> /dev/null; then
    echo ""
    echo "⚠️  1Password CLI needs to be connected to the app."
    echo ""
    echo "Please:"
    echo "  1. Open 1Password app"
    echo "  2. Go to Settings → Developer"
    echo "  3. Enable 'Integrate with 1Password CLI'"
    echo ""
    echo "Then re-run this script."
    exit 1
fi

echo "✅ 1Password CLI connected"

# =============================================================================
# Initialize chezmoi with dotfiles
# =============================================================================
echo ""
echo "🏠 Initializing dotfiles..."
chezmoi init pelted/.dotfiles --apply

# =============================================================================
# Done
# =============================================================================
echo ""
echo "============================================"
echo "✅ Bootstrap complete!"
echo "============================================"
echo ""
echo "Your dotfiles are now installed. Next steps:"
echo ""
echo "  1. Restart your terminal (or run: exec zsh)"
echo "  2. Install language versions:"
echo "     mise use ruby@3.3 node@lts"
echo ""
