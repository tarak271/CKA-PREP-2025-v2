#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 15)
rm -f "$DIR/cluster_events.sh" "$DIR/pod_kill.log" "$DIR/container_kill.log"

