#!/bin/bash
# Bootstrap GitHub CLI authentication with 1Password SSH keys
# This runs once after chezmoi apply

set -e

echo ""
echo "🔐 GitHub CLI Bootstrap"
echo "======================="

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "⏭️  gh not installed yet, skipping"
    exit 0
fi

# Check if 1Password CLI is available
if ! command -v op &> /dev/null; then
    echo "⏭️  1Password CLI not available, skipping"
    exit 0
fi

# Check if already authenticated
if gh auth status &> /dev/null; then
    echo "✅ Already authenticated with GitHub CLI:"
    gh auth status
    exit 0
fi

echo "📡 Not authenticated with GitHub CLI yet."
echo ""

# Get list of SSH keys from 1Password
echo "🔑 Available SSH keys in 1Password:"
echo ""

# Store keys in array
KEYS=()
while IFS= read -r key; do
    KEYS+=("$key")
done < <(op item list --categories "SSH Key" --format=json 2>/dev/null | jq -r '.[].title')

if [[ ${#KEYS[@]} -eq 0 ]]; then
    echo "⚠️  No SSH keys found in 1Password"
    exit 1
fi

# Display keys with numbers
for i in "${!KEYS[@]}"; do
    echo "  $((i+1)). ${KEYS[$i]}"
done

echo ""
read -p "Select auth key to use [1-${#KEYS[@]}]: " -r KEY_NUM
echo ""

# Validate selection
if [[ ! "$KEY_NUM" =~ ^[0-9]+$ ]] || [[ "$KEY_NUM" -lt 1 ]] || [[ "$KEY_NUM" -gt ${#KEYS[@]} ]]; then
    echo "❌ Invalid selection"
    exit 1
fi

SELECTED_KEY="${KEYS[$((KEY_NUM-1))]}"
echo "Selected: $SELECTED_KEY"
echo ""

# Get the public key
PUBLIC_KEY=$(op item get "$SELECTED_KEY" --fields "public key" 2>/dev/null)
if [[ -z "$PUBLIC_KEY" ]]; then
    echo "❌ Could not get public key from 1Password"
    exit 1
fi

echo "📋 Public key:"
echo "   $PUBLIC_KEY"
echo ""

# Authenticate with gh
echo "🚀 Starting GitHub CLI authentication..."
echo "   Select 'SSH' when prompted for git protocol"
echo ""

gh auth login -p ssh -h github.com

echo ""

# Check if key needs to be added to GitHub
if gh ssh-key list 2>/dev/null | grep -q "$(echo $PUBLIC_KEY | awk '{print $2}')"; then
    echo "✅ SSH key already exists in your GitHub account"
else
    read -p "Add this SSH key to your GitHub account? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$PUBLIC_KEY" | gh ssh-key add --title "$SELECTED_KEY (dotfiles)" --type authentication
        echo "✅ SSH key added to GitHub!"
    fi
fi

echo ""
echo "✅ GitHub CLI configured!"
echo ""
