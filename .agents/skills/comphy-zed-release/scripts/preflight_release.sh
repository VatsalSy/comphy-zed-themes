#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH="${1:-master}"
REMOTE="${2:-origin}"

errors=()
warnings=()

add_error() {
  errors+=("$1")
}

add_warning() {
  warnings+=("$1")
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git repository."
  exit 1
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" != "$TARGET_BRANCH" ]]; then
  add_error "Current branch is '$current_branch' (expected '$TARGET_BRANCH')."
fi

if [[ -n "$(git status --porcelain)" ]]; then
  add_error "Working tree is not clean."
fi

if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
  add_error "Remote '$REMOTE' is not configured."
else
  if git ls-remote --exit-code --heads "$REMOTE" "$TARGET_BRANCH" >/dev/null 2>&1; then
    if ! git fetch "$REMOTE" "$TARGET_BRANCH" --tags >/dev/null 2>&1; then
      add_warning "Could not fetch '$REMOTE/$TARGET_BRANCH'. Ahead/behind check may be stale."
    fi
  else
    add_error "Remote branch '$REMOTE/$TARGET_BRANCH' was not found."
  fi
fi

ahead=0
behind=0
if git rev-parse --verify "$REMOTE/$TARGET_BRANCH" >/dev/null 2>&1; then
  read -r behind ahead <<<"$(git rev-list --left-right --count "$REMOTE/$TARGET_BRANCH...HEAD")"
  if (( ahead > 0 )); then
    add_error "Local branch has $ahead unpushed commit(s)."
  fi
  if (( behind > 0 )); then
    add_error "Local branch is behind '$REMOTE/$TARGET_BRANCH' by $behind commit(s)."
  fi
fi

last_tag="$(git tag --list 'v*' --sort=-version:refname | head -1 || true)"
commits_since_last_tag=0
if [[ -n "$last_tag" ]]; then
  commits_since_last_tag="$(git rev-list --count "${last_tag}..HEAD" || echo 0)"
  if (( commits_since_last_tag == 0 )); then
    add_error "No commits found since last release tag '$last_tag'."
  fi
else
  add_warning "No previous v* tags found (first release path)."
  commits_since_last_tag="$(git rev-list --count HEAD || echo 0)"
fi

if [[ ! -f extension.toml ]]; then
  add_error "extension.toml not found in repository root."
else
  extension_id="$(sed -n 's/^id = "\(.*\)"/\1/p' extension.toml | head -1)"
  extension_version="$(sed -n 's/^version = "\(.*\)"/\1/p' extension.toml | head -1)"

  if [[ "$extension_id" != "comphy-crisp-themes" ]]; then
    add_error "extension.toml id is '$extension_id' (expected 'comphy-crisp-themes')."
  fi

  if [[ ! "$extension_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    add_error "extension.toml version '$extension_version' is not semver (x.y.z)."
  fi
fi

if [[ ! -f .github/workflows/release.yml ]]; then
  add_error ".github/workflows/release.yml not found."
else
  if command -v rg >/dev/null 2>&1; then
    if ! rg -q "extension-name:\\s*comphy-crisp-themes" .github/workflows/release.yml; then
      add_error "release workflow is not configured for extension-name 'comphy-crisp-themes'."
    fi
  else
    if ! grep -Eq "extension-name:[[:space:]]*comphy-crisp-themes" .github/workflows/release.yml; then
      add_error "release workflow is not configured for extension-name 'comphy-crisp-themes'."
    fi
  fi
fi

if ! command -v gh >/dev/null 2>&1; then
  add_error "gh CLI is not installed."
elif ! gh auth status >/dev/null 2>&1; then
  add_error "gh CLI is not authenticated."
fi

echo "=== Release Preflight ==="
echo "Branch: $current_branch"
echo "Target branch: $TARGET_BRANCH"
echo "Remote: $REMOTE"
echo "Ahead (local-only): $ahead"
echo "Behind (missing pulls): $behind"
if [[ -n "$last_tag" ]]; then
  echo "Last release tag: $last_tag"
else
  echo "Last release tag: (none)"
fi
echo "Commits since last tag: $commits_since_last_tag"
echo

if (( ${#warnings[@]} > 0 )); then
  echo "⚠️  Warnings"
  for msg in "${warnings[@]}"; do
    echo "  - $msg"
  done
  echo
fi

if (( ${#errors[@]} > 0 )); then
  echo "❌ Blocking issues"
  for msg in "${errors[@]}"; do
    echo "  - $msg"
  done
  exit 1
fi

echo "✅ Preflight passed."
