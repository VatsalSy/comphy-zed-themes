#!/usr/bin/env bash
set -euo pipefail

REGISTRY_REPO="${1:-zed-industries/extensions}"

if [[ ! "$REGISTRY_REPO" =~ ^[^/]+/[^/]+$ ]]; then
  echo "Usage: $0 [owner/repo]"
  echo "Example: $0 zed-industries/extensions"
  exit 1
fi

url="https://raw.githubusercontent.com/${REGISTRY_REPO}/main/extensions.toml"
tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

curl -fsSL "$url" -o "$tmp_file"

contains_section() {
  local section="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -q "^\[$section\]$" "$tmp_file"
  else
    grep -q "^\[$section\]$" "$tmp_file"
  fi
}

extract_version() {
  local section="$1"
  awk -v section="$section" '
    $0 == "[" section "]" { in_section = 1; next }
    in_section && /^\[/ { exit }
    in_section && $1 == "version" {
      gsub(/"/, "", $3)
      print $3
      exit
    }
  ' "$tmp_file"
}

comphy_status="missing"
gruvbox_status="missing"
mode="bootstrap"

if contains_section "comphy-crisp-themes"; then
  comphy_status="present"
  mode="update"
fi

if contains_section "gruvbox-crisp-themes"; then
  gruvbox_status="present"
fi

comphy_version="$(extract_version "comphy-crisp-themes")"
gruvbox_version="$(extract_version "gruvbox-crisp-themes")"

echo "MODE=${mode}"
echo "REGISTRY_REPO=${REGISTRY_REPO}"
echo "COMPHY_STATUS=${comphy_status}"
echo "COMPHY_VERSION=${comphy_version:-n/a}"
echo "GRUVBOX_STATUS=${gruvbox_status}"
echo "GRUVBOX_VERSION=${gruvbox_version:-n/a}"
