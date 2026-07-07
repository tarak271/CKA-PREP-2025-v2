#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/run-question.sh \"Question-XX Topic\"" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXERCISES_DIR="$REPO_ROOT/exercises"

source "$EXERCISES_DIR/lib/questions.sh"
source "$EXERCISES_DIR/lib/cleanup.sh"

QUESTION_DIR="$*"
if [[ ! -d "$QUESTION_DIR" ]]; then
  echo "Question directory '$QUESTION_DIR' not found" >&2
  exit 1
fi

SETUP="$QUESTION_DIR/LabSetUp.bash"
QUESTION_TEXT="$QUESTION_DIR/Questions.bash"
SOLUTION="$QUESTION_DIR/SolutionNotes.bash"

[[ -f "$SETUP" ]] || { echo "Missing $SETUP" >&2; exit 1; }
[[ -f "$QUESTION_TEXT" ]] || { echo "Missing $QUESTION_TEXT" >&2; exit 1; }

QID=$(resolve_question_id "$QUESTION_DIR")
if [[ -z "$QID" ]]; then
  echo "Unknown question directory: $QUESTION_DIR" >&2
  exit 1
fi

run_question_cleanup "$QID"

chmod +x "$SETUP"

echo "==> Running lab setup for $QUESTION_DIR"
"$SETUP"

echo
echo "==> Question"
cat "$QUESTION_TEXT"

echo
if [[ -f "$SOLUTION" ]]; then
  echo "Hints: see $SOLUTION"
fi

echo
echo "When done, validate your work:"
echo "  exercises/validate.sh \"$QUESTION_DIR\""
