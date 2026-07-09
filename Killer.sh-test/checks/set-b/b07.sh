#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


[[ -f "$(course_path 7)/etcd-version" ]] && pass_task "version" "etcd version saved" || fail_task "version" "etcd version saved"
[[ -f "$(course_path 7)/etcd-snapshot.db" ]] && pass_task "snapshot" "etcd snapshot saved" || fail_task "snapshot" "etcd snapshot saved"


print_summary "b07"
