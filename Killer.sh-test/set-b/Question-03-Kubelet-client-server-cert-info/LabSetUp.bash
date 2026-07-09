#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 3)
rm -f "$DIR/certificate-info.txt"
echo "Inspect kubelet certificates on this node (or worker if available)"

