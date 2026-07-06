#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

read_sysctl() {
  sysctl -n "$1" 2>/dev/null || cat "/proc/sys/${1//.//}" 2>/dev/null || echo ""
}

# Task 1: Package installed
if dpkg -l cri-dockerd 2>/dev/null | grep -q '^ii' || \
   dpkg -l 2>/dev/null | grep -qi 'cri-docker'; then
  pass_task "package-installed" "cri-dockerd Debian package installed"
else
  fail_task "package-installed" "cri-dockerd Debian package installed" \
    "Run: sudo dpkg -i ~/cri-dockerd.deb (or /root/cri-dockerd.deb)"
fi

# Task 2: Service running
if systemctl is-active cri-docker.service &>/dev/null || systemctl is-active cri-docker &>/dev/null; then
  pass_task "service-running" "cri-docker service enabled and running"
else
  fail_task "service-running" "cri-docker service enabled and running" \
    "Run: sudo systemctl enable --now cri-docker.service"
fi

# Task 3-6: Sysctl values
ipt=$(read_sysctl net.bridge.bridge-nf-call-iptables)
if [[ "$ipt" == "1" ]]; then
  pass_task "sysctl-iptables" "net.bridge.bridge-nf-call-iptables set to 1"
else
  fail_task "sysctl-iptables" "net.bridge.bridge-nf-call-iptables set to 1" "Current: $ipt"
fi

ipv6=$(read_sysctl net.ipv6.conf.all.forwarding)
if [[ "$ipv6" == "1" ]]; then
  pass_task "sysctl-ipv6-forward" "net.ipv6.conf.all.forwarding set to 1"
else
  fail_task "sysctl-ipv6-forward" "net.ipv6.conf.all.forwarding set to 1" "Current: $ipv6"
fi

ipfwd=$(read_sysctl net.ipv4.ip_forward)
if [[ "$ipfwd" == "1" ]]; then
  pass_task "sysctl-ip-forward" "net.ipv4.ip_forward set to 1"
else
  fail_task "sysctl-ip-forward" "net.ipv4.ip_forward set to 1" "Current: $ipfwd"
fi

conntrack=$(read_sysctl net.netfilter.nf_conntrack_max)
if [[ "$conntrack" == "131072" ]]; then
  pass_task "sysctl-conntrack" "net.netfilter.nf_conntrack_max set to 131072"
else
  fail_task "sysctl-conntrack" "net.netfilter.nf_conntrack_max set to 131072" "Current: $conntrack"
fi

print_summary "q09"
[[ $FAIL -eq 0 ]]
