# Global Agent Instructions

These are my preferences for AI coding assistants. Use this as context when helping me with code.

## About Me
- I'm a Ruby/Rails developer at 1Password
- I work primarily on macOS
- I value clean, readable code over cleverness

## Language & Framework Preferences
- **Ruby**: My primary language
- **Rails**: My primary framework
- **Testing**: Minitest (NOT RSpec)
- **C#**: .NET/Mono
- **Testing (C#)**: xUnit
- **JavaScript**: When needed, prefer vanilla JS or Stimulus

## Code Style
- Explicit over implicit
- Prefer readability over brevity
- Use meaningful variable and method names
- Keep methods small and focused
- Follow Ruby community style guide

## Tools & Environment
- **Version Manager**: mise (not rbenv, asdf, or rvm)
- **Secrets**: Always use 1Password CLI (`op`) - never hardcode secrets
- **Terminal**: Warp
- **Editor**: Zed (EDITOR), Cursor (work)
- **IDE**: JetBrains (RubyMine, Rider)
- **Git**: Use conventional commits when appropriate

## Dotfiles Management
- **Tool**: chezmoi (source at `~/.local/share/chezmoi/`)
- **Repo**: github.com/pelted/.dotfiles
- **Secrets in templates**: Use `{{ onepasswordRead "op://vault/item/field" }}`
- **Environment variables**: All exports go in `.zshenv`, not `.zshrc`
- **PATH additions**: Centralized in `.zshenv` only
- **After editing dotfiles**: Run `chezmoi re-add` to update source
- **To apply changes**: Run `chezmoi apply`
- **Brewfile location**: `~/.local/share/chezmoi/Brewfile`

## When Writing Code
- Think deeply and plan before jumping into implementation
- Ask clarifying questions when requirements are ambiguous
- Add comments only when the "why" isn't obvious
- Prefer composition over inheritance
- Write tests first when fixing bugs
- Don't over-engineer - start simple

## When Suggesting Changes
- Explain trade-offs when there are multiple approaches
- If you're unsure, say so
- Don't assume - ask clarifying questions
