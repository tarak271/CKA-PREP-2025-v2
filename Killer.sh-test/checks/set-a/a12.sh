#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


kubectl get deploy overlord &>/dev/null && pass_task "deploy" "Deployment overlord exists" || fail_task "deploy" "Deployment overlord exists"


print_summary "a12"
