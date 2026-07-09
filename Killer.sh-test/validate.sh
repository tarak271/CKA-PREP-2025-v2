#!/bin/bash
set -euo pipefail

KILLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$KILLER_DIR/lib/common.sh"

usage() {
  cat <<EOF
Usage: Killer.sh-test/validate.sh <question-id> [--record <scores-file>]

Examples:
  Killer.sh-test/validate.sh a01
  Killer.sh-test/validate.sh b05 --record ~/.killer-exam/scores.tsv

Question IDs: a01-a17 (Set-A), b01-b17 (Set-B)
EOF
}

RECORD_FILE=""
QUESTION_INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --record) RECORD_FILE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) QUESTION_INPUT="$1"; shift ;;
  esac
done

[[ -z "$QUESTION_INPUT" ]] && { usage; exit 1; }

QID="$QUESTION_INPUT"
SET_CHAR="${QID:0:1}"
if [[ "$SET_CHAR" != "a" && "$SET_CHAR" != "b" ]]; then
  echo "Unknown question: $QUESTION_INPUT (use a01-a17 or b01-b17)" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$KILLER_DIR/lib/questions-set-${SET_CHAR}.sh"

CHECK_SCRIPT=$(get_check_script "$QID")
if [[ ! -f "$CHECK_SCRIPT" ]]; then
  echo "No validator for $QID at $CHECK_SCRIPT" >&2
  exit 1
fi

chmod +x "$CHECK_SCRIPT"
echo -e "${BOLD}Validating ${QID}...${NC}"
echo
reset_results

set +e
set +u
source "$CHECK_SCRIPT"
exit_code=0
[[ ${FAIL:-0} -gt 0 ]] && exit_code=1
set -e
set -u
set -o pipefail

if [[ -n "$RECORD_FILE" ]]; then
  mkdir -p "$(dirname "$RECORD_FILE")"
  : > "$RECORD_FILE.partial"
  export_results_tsv "$QID" "$RECORD_FILE.partial"
  if [[ -f "$RECORD_FILE" ]]; then
    grep -v "^${QID}	" "$RECORD_FILE" > "$RECORD_FILE.tmp" 2>/dev/null || true
    cat "$RECORD_FILE.tmp" "$RECORD_FILE.partial" > "$RECORD_FILE"
    rm -f "$RECORD_FILE.tmp" "$RECORD_FILE.partial"
  else
    mv "$RECORD_FILE.partial" "$RECORD_FILE"
  fi
fi

exit $exit_code
