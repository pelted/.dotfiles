# Global Agent Instructions

These are my preferences for AI coding assistants. Use this as context when helping me with code.

## Hard Rules

These apply to **all** work across every project, every tool, every artifact.

### No agent co-authoring

Never credit yourself as a co-author on anything I produce with your help —
ever, unless I explicitly ask for it.

That means no:

- `Co-Authored-By:` trailers on git commits
- "🤖 Generated with [Claude Code]" footers on PR descriptions or issue bodies
- "Authored/co-authored by Claude" notes in code comments, doc files, or chat
  messages I'll forward elsewhere
- Any other authorship attribution in artifacts I'll share with humans

If a template, hook, or tool auto-inserts something like this, strip it before
finalizing.

### Humanizer skill

Apply the `humanizer` skill to strip AI-tell phrasing from:

- **Code comments** before they go into a commit
- **PR description drafts**
- **Substantive prose responses** in chat (longer explanations, recommendations, summaries)

Skip humanizer for:

- **Plans and specs** — structured, exhaustive prose is the point there; voice tuning is noise. Run only if I explicitly ask.
- Short status updates, tool-running acknowledgments, or terse answers
- Anything where I explicitly ask for the structured/AI voice

### Private notes / Obsidian vault skill

When entering a project that has a `.private/` directory, or when I ask to set
up private working notes in a project that doesn't have one yet, use the
`private-notes` skill. It owns the conventions for directory layout, YAML
frontmatter, `[[wiki-link]]` usage (including the hard prohibition on using
that syntax in commits, PR descriptions, and GitHub comments), archive +
`INDEX.md` hygiene, and commit discipline for the private repo when one
exists.

Skill location: `~/.claude/skills/private-notes/SKILL.md`. Treat it as the
single source of truth — don't restate its conventions in per-project
`CLAUDE.local.md` files.

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
- **Terminal**: Ghostty
- **Editor**: VS Code (EDITOR), Cursor (work)
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
