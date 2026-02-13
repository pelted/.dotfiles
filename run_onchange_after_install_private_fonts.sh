#!/bin/bash
# Install licensed fonts from private Homebrew tap
# Requires: gh (GitHub CLI) authenticated, brew

set -e

echo "🔤 Installing private fonts..."

# ============================================================================
# Check prerequisites
# ============================================================================
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found, skipping private fonts"
    exit 0
fi

if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not found, skipping private fonts"
    exit 0
fi

if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI not authenticated, skipping private fonts"
    echo "   Run 'gh auth login' then 'chezmoi apply' to retry"
    exit 0
fi

# ============================================================================
# Set up GitHub token for private release downloads
# ============================================================================
export HOMEBREW_GITHUB_API_TOKEN=$(gh auth token)

# ============================================================================
# Add private tap (via SSH for private repo access)
# ============================================================================
if ! brew tap | grep -q "pelted/casks"; then
    echo "📦 Adding private tap..."
    brew tap pelted/casks git@github.com:pelted/homebrew-casks.git
fi

# ============================================================================
# Install fonts
# ============================================================================
if ! brew list --cask font-dank-mono &> /dev/null; then
    echo "📦 Installing Dank Mono..."
    brew install --cask font-dank-mono
else
    echo "✅ Dank Mono already installed"
fi

echo "✅ Private fonts installed"
