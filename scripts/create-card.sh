#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# create-card.sh — append a new card entry to assets/sets/{SET_ID}/cards.json
#
# Usage:
#   create-card.sh [--set-id <id>] <name> <description> <attributes>
#
# Arguments:
#   --set-id <id>   Optional. The set to add the card to (default: "base")
#   <name>          Card name
#   <description>   Card description
#   <attributes>    Comma-separated key=value pairs  e.g. "rarity=common,cost=3"
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# --- jq check ---------------------------------------------------------------
if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' is required but not installed." >&2
  echo "" >&2
  echo "Install it with:" >&2
  echo "  brew install jq        # macOS (Homebrew)" >&2
  echo "  sudo apt-get install jq  # Debian/Ubuntu" >&2
  exit 1
fi

# --- Parse flags ------------------------------------------------------------
SET_ID="base"
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --set-id)
      if [[ -z "${2-}" ]]; then
        echo "Error: --set-id requires a value." >&2
        exit 1
      fi
      SET_ID="$2"
      shift 2
      ;;
    --set-id=*)
      SET_ID="${1#*=}"
      shift
      ;;
    --)
      shift
      POSITIONAL+=("$@")
      break
      ;;
    -*)
      echo "Error: Unknown flag '$1'." >&2
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

# --- Validate positional args -----------------------------------------------
if [[ ${#POSITIONAL[@]} -ne 3 ]]; then
  echo "Usage: $(basename "$0") [--set-id <id>] <name> <description> <attributes>" >&2
  echo "" >&2
  echo "  <attributes>  Comma-separated key=value pairs, e.g. \"rarity=common,cost=3\"" >&2
  echo "" >&2
  echo "Example:" >&2
  echo "  $(basename "$0") --set-id base \"Fire Drake\" \"A fierce dragon\" \"rarity=rare,cost=5\"" >&2
  exit 1
fi

NAME="${POSITIONAL[0]}"
DESCRIPTION="${POSITIONAL[1]}"
ATTRIBUTES_RAW="${POSITIONAL[2]}"

# --- Derive image_filename --------------------------------------------------
image_filename="$(echo "$NAME" \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/[[:space:]]/-/g' \
  | sed 's/[^a-z0-9-]//g' \
  | sed 's/-\{2,\}/-/g').png"

# --- Locate cards file ------------------------------------------------------
CARDS_FILE="${REPO_ROOT}/assets/sets/${SET_ID}/cards.json"

if [[ ! -f "$CARDS_FILE" ]]; then
  echo "Error: cards file not found: ${CARDS_FILE}" >&2
  echo "Make sure the set '${SET_ID}' exists under assets/sets/." >&2
  exit 1
fi

# --- Parse attributes into a jq --arg chain ---------------------------------
# Build arrays of keys and values, then construct the jq expression at runtime.
jq_args=()
jq_obj_parts=()

IFS=',' read -ra PAIRS <<< "$ATTRIBUTES_RAW"
for pair in "${PAIRS[@]}"; do
  if [[ "$pair" != *"="* ]]; then
    echo "Error: Invalid attribute format '${pair}'. Expected key=value." >&2
    exit 1
  fi
  key="${pair%%=*}"
  value="${pair#*=}"

  if [[ -z "$key" ]]; then
    echo "Error: Empty key in attribute pair '${pair}'." >&2
    exit 1
  fi

  jq_args+=(--arg "attr_${#jq_obj_parts[@]}_key" "$key" --arg "attr_${#jq_obj_parts[@]}_val" "$value")
  jq_obj_parts+=("${#jq_obj_parts[@]}")
done

# Build the attributes object expression for jq
# We pass keys and values via --arg and reconstruct the object inside jq.
attr_jq_expr="{"
for i in "${!jq_obj_parts[@]}"; do
  [[ $i -gt 0 ]] && attr_jq_expr+=","
  attr_jq_expr+="\$attr_${i}_key: \$attr_${i}_val"
done
attr_jq_expr+="}"

# --- Build the new card object ----------------------------------------------
new_card="$(jq -n \
  --arg name        "$NAME"           \
  --arg description "$DESCRIPTION"    \
  --arg image       "$image_filename" \
  "${jq_args[@]}"                     \
  "{
    name: \$name,
    description: \$description,
    image_filename: \$image,
    attributes: ${attr_jq_expr}
  }")"

# --- Append card to file ----------------------------------------------------
tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

if ! jq --argjson card "$new_card" '. += [$card]' "$CARDS_FILE" > "$tmp_file" 2>&1; then
  echo "Error: Failed to update ${CARDS_FILE}:" >&2
  cat "$tmp_file" >&2
  exit 1
fi

mv "$tmp_file" "$CARDS_FILE"

# --- Success ----------------------------------------------------------------
echo "Card '${NAME}' created successfully!"
echo "Ensure that an image exists at assets/sets/${SET_ID}/images/${image_filename}"
