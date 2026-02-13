#!/bin/bash
# Configure GitHub CLI with SSH keys
# This runs once after chezmoi apply

set -e

echo ""
echo "🔐 GitHub CLI Configuration"
echo "============================"

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "⏭️  gh not installed yet, skipping (will run after brew bundle)"
    exit 0
fi

# Check if 1Password CLI is available
if ! command -v op &> /dev/null; then
    echo "⏭️  1Password CLI not available, skipping"
    exit 0
fi

# Get the signing key from 1Password
SIGNING_KEY=$(op item get "Github - Signing" --fields "public key" 2>/dev/null)
if [[ -z "$SIGNING_KEY" ]]; then
    echo "⚠️  Could not get signing key from 1Password"
    echo "   Make sure 'Github - Signing' exists in your Private vault"
    exit 0
fi

echo ""
echo "📋 Your signing key:"
echo "   $SIGNING_KEY"
echo ""

# Function to add signing key to a GitHub account
add_signing_key() {
    local account_name=$1
    
    echo ""
    echo "🔑 Adding signing key to $account_name..."
    
    # Check if key already exists
    if gh ssh-key list 2>/dev/null | grep -q "$(echo $SIGNING_KEY | awk '{print $2}')"; then
        echo "   ✅ Signing key already added to this account"
        return 0
    fi
    
    # Add the key
    echo "$SIGNING_KEY" | gh ssh-key add --title "Signing Key (dotfiles)" --type signing
    echo "   ✅ Signing key added!"
}

# Check current gh auth status
echo "📡 Checking GitHub CLI authentication..."
echo ""

if ! gh auth status &> /dev/null; then
    echo "⚠️  Not authenticated with GitHub CLI"
    echo ""
    echo "To set up GitHub CLI, run these commands:"
    echo ""
    echo "  # Personal account"
    echo "  gh auth login"
    echo ""
    echo "  # Add signing key to personal account"
    echo "  op item get 'Github - Signing' --fields 'public key' | gh ssh-key add --title 'Signing Key' --type signing"
    echo ""
    echo "  # Work account (if using multiple accounts)"
    echo "  gh auth login"
    echo "  gh auth switch --user <work-username>"
    echo "  op item get 'Github - Signing' --fields 'public key' | gh ssh-key add --title 'Signing Key' --type signing"
    echo ""
    exit 0
fi

# Show current auth status
echo "Current GitHub CLI authentication:"
gh auth status
echo ""

# Prompt to add signing key
read -p "Add signing key to current GitHub account? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    add_signing_key "current account"
fi

echo ""
echo "💡 Tip: To add the signing key to another GitHub account:"
echo "   gh auth login  # login to other account"
echo "   op item get 'Github - Signing' --fields 'public key' | gh ssh-key add --title 'Signing Key' --type signing"
echo ""
