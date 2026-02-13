#!/bin/bash
# Configure 1Password CLI plugins
# This runs once after chezmoi apply

set -e

echo ""
echo "🔐 1Password CLI Plugins"
echo "========================"

# Check if op is installed
if ! command -v op &> /dev/null; then
    echo "⏭️  1Password CLI not installed yet, skipping"
    exit 0
fi

# Check if signed in
if ! op account list &> /dev/null; then
    echo "⏭️  Not signed in to 1Password CLI, skipping"
    exit 0
fi

# Plugins to configure
# Note: gh is excluded - we use SSH auth via run_once_after_configure_gh.sh
PLUGINS=(heroku ngrok openai)

echo ""
echo "Checking 1Password CLI plugins..."
echo ""

# Check if plugins.sh exists and is sourced
PLUGINS_FILE="$HOME/.config/op/plugins.sh"

for plugin in "${PLUGINS[@]}"; do
    if [[ -f "$PLUGINS_FILE" ]] && grep -q "alias $plugin=" "$PLUGINS_FILE" 2>/dev/null; then
        echo "  ✅ $plugin - already configured"
    else
        echo "  ⚙️  $plugin - setting up..."
        echo ""
        echo "  Running: op plugin init $plugin"
        echo "  Follow the prompts to select the credential from 1Password"
        echo ""
        op plugin init "$plugin" || echo "  ⚠️  Could not configure $plugin (credential may not exist)"
        echo ""
    fi
done

echo ""

# Remind about sourcing
if [[ -f "$PLUGINS_FILE" ]]; then
    echo "✅ Plugins configured!"
    echo ""
    echo "Make sure this line is in your .zshrc:"
    echo "  [[ -f ~/.config/op/plugins.sh ]] && source ~/.config/op/plugins.sh"
else
    echo "⚠️  No plugins configured yet."
    echo ""
    echo "To manually set up a plugin:"
    echo "  op plugin init <tool>"
fi

echo ""
