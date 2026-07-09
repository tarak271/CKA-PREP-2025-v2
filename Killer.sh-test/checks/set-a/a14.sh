#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results


[[ -f "$(course_path 14)/expiration" ]] && pass_task "expiration" "Certificate expiration date recorded" || fail_task "expiration" "Certificate expiration date recorded"
[[ -f "$(course_path 14)/kubeadm-renew-certs.sh" ]] && pass_task "renew-cmd" "kubeadm renew command written" || fail_task "renew-cmd" "kubeadm renew command written"


print_summary "a14"
