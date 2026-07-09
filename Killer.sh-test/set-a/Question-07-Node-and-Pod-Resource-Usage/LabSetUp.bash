#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 7)
rm -f "$DIR/node.sh" "$DIR/pod.sh"
echo "Create scripts node.sh and pod.sh in $DIR"

