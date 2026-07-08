#!/bin/bash
# Run a single Killer.sh question (practice mode, no timer)
set -euo pipefail

KILLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$KILLER_DIR/lib/course.sh"

SET=""
QUESTION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --set) SET="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: scripts/run-killer-question.sh --set A|B <question-id|dir>"
      exit 0
      ;;
    *) QUESTION="$1"; shift ;;
  esac
done

[[ -z "$SET" || -z "$QUESTION" ]] && {
  echo "Usage: scripts/run-killer-question.sh --set A|B <a01|Question-01-...>"
  exit 1
}

SET=$(echo "$SET" | tr '[:upper:]' '[:lower:]')
# shellcheck source=/dev/null
source "$KILLER_DIR/lib/questions-set-${SET}.sh"
# shellcheck source=/dev/null
source "$KILLER_DIR/lib/cleanup-set-${SET}.sh"

QID=$(resolve_question_id "$QUESTION")
[[ -z "$QID" ]] && { echo "Unknown question: $QUESTION"; exit 1; }

num=$((10#${QID:1:2}))
dir=$(ls -1d "$KILLER_DIR/set-${SET}/Question-$(printf '%02d' "$num")-"* 2>/dev/null | head -1)
[[ -z "$dir" ]] && { echo "Question dir not found for $QID"; exit 1; }

run_question_cleanup "$QID"
bash "$dir/LabSetUp.bash"
bash "$dir/Questions.bash"
echo
echo "Validate: Killer.sh-test/validate.sh $QID"
echo "Hints:    bash $dir/SolutionNotes.bash"
