---
name: private-notes
description: |
  Bootstrap and maintain a personal Obsidian-compatible markdown vault for
  per-project working notes (plans, PR drafts, reviews, context, archive).
  Auto-load this skill's conventions when entering a project that has a
  `.private/` directory, or invoke explicitly to bootstrap a new vault in a
  project that doesn't have one yet.
license: MIT
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# Private Notes — Personal Per-Project Vault

A skill that sets up and maintains a `.private/` directory in a project as a
personal Obsidian-compatible markdown vault. Conventions cover directory
layout, YAML frontmatter, wiki-link usage, archive + index hygiene, and
commit discipline.

This is a *personal* workflow — it is not designed for team-shared notes.

## When to use

- **Bootstrap:** the user asks to set up private notes, or invokes
  `/private-notes` in a project that doesn't have a `.private/` directory.
- **Recognition:** an agent enters a project that already has `.private/`.
  Silently load the conventions below and follow them for any work that
  touches the vault. Don't announce — just behave correctly.

## Bootstrap flow

When `.private/` doesn't exist and the user wants it set up, run this flow.
Use `AskUserQuestion` for each prompt; don't assume answers.

### Step 1 — private vs in-repo

Ask: **"Should this vault be private (gitignored, optionally a separate
git repo) or part of the project repo (committed alongside code)?"**

- **Private** is the right answer for most personal scratch work, especially
  in a work repo or any codebase shared with other people.
- **In-repo** is appropriate only when the user explicitly wants the notes
  committed alongside the project — typically a personal project where the
  wiki is part of the repo's value.

### Step 2 — create the directory structure

Create:

```
.private/
  context/
  plans/
  reviews/
  drafts/
  archive/
    INDEX.md
```

Drop the INDEX.md template (see *Archive and INDEX* below).

### Step 3 — private-mode setup (if Step 1 = private)

- Confirm `.private` is in the project's `.gitignore`. Add it if not.
- Ask: **"Init `.private/` as its own git repo so notes can be committed
  separately from the project?"** If yes:
  - `git -C .private init -b main`
  - Create `.private/.gitignore` containing `.DS_Store` and `._*`
  - Optionally ask about a remote, but don't push to one without a URL
    explicitly provided by the user
- Update or create the current tool's local instruction file at the *project*
  root with the thin pointer template (see *Project pointer file* below):
  `CLAUDE.local.md` for Claude Code or an ignored `AGENTS.override.md` for Codex.

### Step 4 — in-repo-mode setup (if Step 1 = in-repo)

- Skip `.gitignore` and `git init` steps
- Ensure `AGENTS.md` (or whatever the project's primary instructions file
  is) references this skill so the conventions are visible to anyone
  working in the project. A short pointer is enough — don't restate the
  conventions.

### Step 5 — confirm and hand off

Tell the user the vault is ready. Mention:

- They can open the project root (or `.private/`) in Obsidian as a vault
  to get backlinks, search, and the graph view.
- Dataview is the one plugin worth installing right away — the skill's
  frontmatter schema is designed to drive Dataview tables.

## Recognition flow (auto, when `.private/` already exists)

Silently:

- Treat the conventions in this skill as active for any work touching the
  vault.
- Use `archive/INDEX.md` as a grep target for historical context before
  starting non-trivial work on an unfamiliar system. Search for system
  names, PR numbers, incident keywords.
- If `.private/` is its own git repo and the working tree is dirty, mention
  it once at a natural break in the work — don't be pushy. The user knows
  their own state.

## Directory layout

| Subdir              | Use for                                                            |
|---------------------|--------------------------------------------------------------------|
| `.private/context/` | Long-lived reference docs (architecture notes, RCAs, system memos) |
| `.private/plans/`   | Specs and plans drafted before implementation work                 |
| `.private/reviews/` | PR review notes (incoming and outgoing)                            |
| `.private/drafts/`  | Final PR description drafts                                        |
| `.private/archive/` | Items moved out of active subdirs once no longer in active use     |

Drop new docs into the matching subdir from the start. Never put fresh
`.md` files at the project root — that pollutes `git status`.

## Frontmatter schema (v1)

Every doc starts with YAML frontmatter:

```yaml
---
type: context     # one of: context, plan, spec, review, draft
date: 2026-05-01  # ISO date — when the doc was created or last meaningfully updated
status: active    # active or archived
summary: One-line description that drives the INDEX and Dataview tables.
---
```

Optional, add as needed:

```yaml
tags: [saml, device-trust]   # free-form topic tags
pr: 14261                    # PR number this doc is tied to (drafts/reviews)
incident: saml-bypass        # incident slug for related context docs
```

The schema is intentionally small. **Add fields when a Dataview query
needs them, not before.** If the user proposes an extension, write it
into this skill so the convention stays consistent across projects.

## Wiki-link convention

Inside `.private/`, prefer `[[file-name]]` for cross-references between
docs. This builds Obsidian's backlink graph automatically and makes
"what other docs touch this incident" a one-click answer.

### Hard prohibition

**Never** use `[[wiki-links]]` in:

- Git commit messages
- PR descriptions (drafts that will be pasted to GitHub, or PRs created
  via `gh pr create`)
- GitHub PR/issue comments
- Code comments
- Any other text that leaves the vault

Outside the vault, use plain markdown links, file paths, or PR numbers.
The wiki-link syntax renders as literal `[[text]]` on GitHub and looks
broken.

When drafting a PR description in `.private/drafts/` that will be pasted
to GitHub, scan for `[[...]]` and replace with plain markdown before
handing off.

## Archive and INDEX

Move items into `.private/archive/<original-subdir>/` once they're no
longer in active use — PR merged, plan shipped, incident resolved. When
archiving:

1. Move the file to `archive/<original-subdir>/`
2. Flip frontmatter `status: archived`
3. Append a one-line entry to `.private/archive/INDEX.md` with the date,
   the new path, and the doc's `summary`

INDEX.md format:

```markdown
# Archive Index

One-line summaries of archived working docs under `.private/archive/`.
This file is what agents grep when they need historical context for a
system or change.

Format:
- `YYYY-MM-DD [type] path/to/file — one-line summary`

## Entries

- 2026-04-20 [context] archive/context/2026-04-20-saml-rca.md — RCA on SAML auth bypass for Databricks Security Team
- ...
```

Keep entries sorted newest-first.

Before starting non-trivial work on an unfamiliar system, grep
`archive/INDEX.md` for related prior context (system names, PR numbers,
incident keywords) and read any matching entries. Treat it as a
lightweight knowledge base.

## Commit hygiene (private-mode `.private/` repo)

When `.private/` is its own git repo, commit when:

- A context/reference doc is created or substantially rewritten
- Multiple files are sorted, moved, or archived in a batch
- `archive/INDEX.md` is updated after archiving items
- Files are consolidated or split apart
- A plan or PR draft hits a logical checkpoint worth a snapshot

Don't bother committing for:

- Tiny typo fixes
- A single in-progress edit to a draft the user is iterating on within
  the same session
- Pure read activity

When unsure whether the repo has accumulated significant uncommitted
work, run `git -C .private status` and ask whether to commit before
piling on more changes.

### Commit message rules

- Meaningful messages explaining the *why*, not just the *what*
- Never disable signing (`-c commit.gpgsign=false`, `--no-gpg-sign`) — if
  the user has signing configured, let it sign
- No agent co-authoring (`Co-Authored-By:`, "🤖 Generated with...", or
  any other authorship attribution to Claude). This is a hard rule across
  all artifacts, not just commits.

## Starter Dataview queries

Drop any of these into `.private/dashboard.md` (or anywhere in the vault)
for an auto-generated table.

**All active docs by date:**

````markdown
```dataview
TABLE type, date, summary
FROM "."
WHERE status = "active"
SORT date DESC
```
````

**Open PR drafts with their PR number:**

````markdown
```dataview
TABLE pr, summary
FROM "drafts"
WHERE pr != null AND status = "active"
SORT date DESC
```
````

**Everything tagged `#saml`, newest first:**

````markdown
```dataview
TABLE date, type, summary
FROM #saml
SORT date DESC
```
````

**Archive contents grouped by type:**

````markdown
```dataview
TABLE date, summary
FROM "archive"
WHERE status = "archived"
GROUP BY type
SORT date DESC
```
````

## Project pointer file

In private mode, create or update the current tool's local instruction file at
the *project* root: `CLAUDE.local.md` for Claude Code or an ignored
`AGENTS.override.md` for Codex. Use this thin pointer (kept short on purpose —
conventions live in the skill, not duplicated per project):

```markdown
# Local Agent Instructions

This project uses the `private-notes` skill for personal working notes
under `.private/`. See `~/.agents/skills/private-notes/SKILL.md` for the
full conventions (directory layout, YAML frontmatter, wiki-link rules,
archive + INDEX hygiene, commit discipline).

## Project-specific notes

(Add anything specific to this project's vault — preferred tags, naming
conventions, references to other internal systems, etc. Leave empty until
something actually warrants it.)
```

## Bootstrap output checklist

After running the bootstrap flow, the project should have:

- `.private/{context,plans,reviews,drafts,archive}/` directories
- `.private/archive/INDEX.md` with the template header
- `.gitignore` containing `.private` (private mode only)
- `.private/.git/` initialized as a separate repo (private mode + user
  opted in)
- `.private/.gitignore` with `.DS_Store` and `._*` (private repo mode)
- The current tool's local instruction file with the thin pointer (private mode),
  or a reference to this skill in the project's primary instruction file
  (in-repo mode)

Confirm each is in place before reporting bootstrap complete.
