#!/bin/bash
set -euo pipefail

EXERCISES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$EXERCISES_DIR/.." && pwd)"
source "$EXERCISES_DIR/lib/common.sh"
source "$EXERCISES_DIR/lib/questions.sh"

usage() {
  cat <<EOF
Usage: exercises/validate.sh <question-id|question-dir> [--record <scores-file>]

Validate a single question and report per-sub-task results (1 mark each).

Examples:
  exercises/validate.sh q05
  exercises/validate.sh "Question-5 HPA"
  exercises/validate.sh q01 --record ~/.cka-exam/scores.tsv

EOF
}

RECORD_FILE=""
QUESTION_INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --record)
      RECORD_FILE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      QUESTION_INPUT="$1"
      shift
      ;;
  esac
done

if [[ -z "$QUESTION_INPUT" ]]; then
  usage
  exit 1
fi

require_kubectl

QID=$(resolve_question_id "$QUESTION_INPUT")
if [[ -z "$QID" ]]; then
  echo "Unknown question: $QUESTION_INPUT" >&2
  exit 1
fi

CHECK_SCRIPT=$(get_check_script "$QID")
if [[ ! -f "$CHECK_SCRIPT" ]]; then
  echo "No validator found for $QID at $CHECK_SCRIPT" >&2
  exit 1
fi

chmod +x "$CHECK_SCRIPT"

echo -e "${BOLD}Validating ${QID}...${NC}"
echo

reset_results
set +e
# Source (not execute) so RESULTS from common.sh are available for --record.
source "$CHECK_SCRIPT"
exit_code=$?
set -e

if [[ -n "$RECORD_FILE" ]]; then
  mkdir -p "$(dirname "$RECORD_FILE")"
  : > "$RECORD_FILE.partial"
  export_results_tsv "$QID" "$RECORD_FILE.partial"
  # Merge: remove old entries for this question, append new
  if [[ -f "$RECORD_FILE" ]]; then
    grep -v "^${QID}	" "$RECORD_FILE" > "$RECORD_FILE.tmp" 2>/dev/null || true
    cat "$RECORD_FILE.tmp" "$RECORD_FILE.partial" > "$RECORD_FILE"
    rm -f "$RECORD_FILE.tmp" "$RECORD_FILE.partial"
  else
    mv "$RECORD_FILE.partial" "$RECORD_FILE"
  fi
fi

exit $exit_code
