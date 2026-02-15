---
name: comphy-zed-release
description: "Run the release workflow for this repository after the Path B rename to `comphy-crisp-themes`. Use when `master` is ahead of the last release and ready to publish: validate release preflight checks, detect whether one-time Zed registry bootstrap is still needed, delegate release-note drafting/tagging to `$release-notes-writer`, publish the GitHub release, and verify Zed registry update PR status."
---

# CoMPhy Zed Release

Use this skill for release operations in `comphy-zed-themes` after the clean-break package rename.

## Workflow

1. Run preflight validation.
   - Command: `scripts/preflight_release.sh`
   - Requirement: no local changes, no local-only commits, on `master`, signed into `gh`, `extension.toml` ID is `comphy-crisp-themes`.
2. Detect registry mode.
   - Command: `scripts/check_zed_registry_state.sh`
   - `MODE=bootstrap`: one-time Path B PR still required. Follow `references/path-b-bootstrap.md`.
   - `MODE=update`: normal release flow; continue.
3. Delegate release-note drafting to `$release-notes-writer`.
   - Run `$release-notes-writer` and use its workflow for:
   - `check_prerequisites.sh`
   - `gather_changes.sh`
   - drafting `release-notes-<tag>.md`
4. Present for explicit approval before tagging.
   - Proposed tag (breaking-change guidance: prefer next major, e.g. `v1.0.0`)
   - Release notes draft
   - Bootstrap status and expected Zed PR behavior
5. Publish release via `$release-notes-writer`.
   - Run `create_release.sh <tag> <notes-file>`
   - This creates tag, pushes tag, and publishes GitHub release.
6. Verify automation outcomes.
   - Confirm GitHub release exists: `gh release view <tag>`
   - Confirm workflow run: `gh run list --workflow release.yml --limit 5`
   - Confirm Zed PR status:
   - Bootstrap: confirm one-time PR to `zed-industries/extensions` is open/merged.
   - Update mode: confirm action-created PR `Update comphy-crisp-themes to <version>` exists.

## Mode Rules

- Treat `comphy-crisp-themes` as the canonical package identity.
- Keep `gruvbox-crisp-themes` untouched in `zed-industries/extensions`.
- Do not remove or mutate the old package entry in the same PR as the new package bootstrap.
- If `MODE=bootstrap`, complete and merge the bootstrap PR before expecting automated update PRs to work.

## Files In This Skill

- `scripts/preflight_release.sh`: repository and branch readiness checks.
- `scripts/check_zed_registry_state.sh`: detects bootstrap vs update mode in Zed registry.
- `references/path-b-bootstrap.md`: one-time manual bootstrap PR checklist for the renamed package.
