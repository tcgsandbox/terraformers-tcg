#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# delete-card.sh — remove a card entry from assets/sets/{SET_ID}/cards.json
#                  and delete its associated image file
#
# Usage:
#   delete-card.sh [--set-id <id>] <name>
#
# Arguments:
#   --set-id <id>   Optional. The set to delete the card from (default: "base")
#   <name>          Card name (case-insensitive match; spacing and special
#                   characters must match exactly)
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# --- jq check ---------------------------------------------------------------
if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' is required but not installed." >&2
  echo "" >&2
  echo "Install it with:" >&2
  echo "  brew install jq          # macOS (Homebrew)" >&2
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
if [[ ${#POSITIONAL[@]} -ne 1 ]]; then
  echo "Usage: $(basename "$0") [--set-id <id>] <name>" >&2
  echo "" >&2
  echo "Example:" >&2
  echo "  $(basename "$0") --set-id base \"Fire Drake\"" >&2
  exit 1
fi

NAME="${POSITIONAL[0]}"

# --- Locate cards file ------------------------------------------------------
CARDS_FILE="${REPO_ROOT}/assets/sets/${SET_ID}/cards.json"

if [[ ! -f "$CARDS_FILE" ]]; then
  echo "Error: cards file not found: ${CARDS_FILE}" >&2
  echo "Make sure the set '${SET_ID}' exists under assets/sets/." >&2
  exit 1
fi

# --- Find matching card (case-insensitive name) -----------------------------
# Returns the image_filename of the matched card, or empty if not found.
matched_image="$(jq -r --arg name "$NAME" \
  'map(select(.name | ascii_downcase == ($name | ascii_downcase))) | first | .image_filename // empty' \
  "$CARDS_FILE" 2>&1)" || {
  echo "Error: Failed to read ${CARDS_FILE}:" >&2
  echo "$matched_image" >&2
  exit 1
}

if [[ -z "$matched_image" ]]; then
  echo "Error: No card named '${NAME}' found in ${CARDS_FILE}." >&2
  exit 1
fi

# --- Remove card from JSON array --------------------------------------------
tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

if ! jq --arg name "$NAME" \
  'map(select(.name | ascii_downcase != ($name | ascii_downcase)))' \
  "$CARDS_FILE" > "$tmp_file" 2>&1; then
  echo "Error: Failed to update ${CARDS_FILE}:" >&2
  cat "$tmp_file" >&2
  exit 1
fi

mv "$tmp_file" "$CARDS_FILE"

# --- Delete image file ------------------------------------------------------
IMAGE_FILE="${REPO_ROOT}/assets/sets/${SET_ID}/images/${matched_image}"

if [[ -f "$IMAGE_FILE" ]]; then
  rm "$IMAGE_FILE"
  echo "Deleted image: assets/sets/${SET_ID}/images/${matched_image}"
else
  echo "Note: Image not found, skipping deletion: assets/sets/${SET_ID}/images/${matched_image}"
fi

# --- Success ----------------------------------------------------------------
echo "Card '${NAME}' deleted successfully."
