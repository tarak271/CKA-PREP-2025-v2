#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
reset_results

cni_type=""
if kubectl get pods -n kube-flannel -l app=flannel --no-headers 2>/dev/null | grep -q Running; then
  cni_type="flannel"
elif kubectl get pods -n calico-system --no-headers 2>/dev/null | grep -q Running; then
  cni_type="calico"
elif kubectl get pods -n tigera-operator --no-headers 2>/dev/null | grep -q Running; then
  cni_type="calico"
fi

# Task 1: CNI installed
if [[ -n "$cni_type" ]]; then
  pass_task "cni-installed" "CNI (Flannel or Calico) installed from manifest"
else
  fail_task "cni-installed" "CNI (Flannel or Calico) installed from manifest" \
    "Install Flannel v0.26.1 or Calico v3.28.2 from the official manifest"
fi

# Task 2: CNI pods running
if [[ "$cni_type" == "flannel" ]]; then
  running=$(kubectl get pods -n kube-flannel -l app=flannel --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$running" -ge 1 ]]; then
    pass_task "cni-running" "CNI pods are running"
  else
    fail_task "cni-running" "CNI pods are running"
  fi
elif [[ "$cni_type" == "calico" ]]; then
  if kubectl get pods -n calico-system --field-selector=status.phase=Running --no-headers 2>/dev/null | grep -q . || \
     kubectl get pods -n tigera-operator --field-selector=status.phase=Running --no-headers 2>/dev/null | grep -q .; then
    pass_task "cni-running" "CNI pods are running"
  else
    fail_task "cni-running" "CNI pods are running"
  fi
else
  fail_task "cni-running" "CNI pods are running"
fi

# Task 3: Pod connectivity test
test_ns="cka-cni-test-$$"
if kubectl create namespace "$test_ns" &>/dev/null; then
  kubectl run cka-test-a -n "$test_ns" --image=busybox:1.36 --restart=Never --command -- sleep 3600 &>/dev/null || true
  kubectl run cka-test-b -n "$test_ns" --image=busybox:1.36 --restart=Never --command -- sleep 3600 &>/dev/null || true
  kubectl wait --for=condition=Ready pod/cka-test-a -n "$test_ns" --timeout=60s &>/dev/null || true
  kubectl wait --for=condition=Ready pod/cka-test-b -n "$test_ns" --timeout=60s &>/dev/null || true

  pod_b_ip=$(kubectl get pod cka-test-b -n "$test_ns" -o jsonpath='{.status.podIP}' 2>/dev/null)
  if [[ -n "$pod_b_ip" ]] && kubectl exec -n "$test_ns" cka-test-a -- wget -q -O- --timeout=3 "http://${pod_b_ip}" &>/dev/null 2>&1 || \
     kubectl exec -n "$test_ns" cka-test-a -- ping -c 1 -W 2 "$pod_b_ip" &>/dev/null; then
    pass_task "pod-connectivity" "Pods can communicate with each other"
  else
    # ping is more reliable for connectivity
    if [[ -n "$pod_b_ip" ]] && kubectl exec -n "$test_ns" cka-test-a -- ping -c 1 -W 3 "$pod_b_ip" &>/dev/null; then
      pass_task "pod-connectivity" "Pods can communicate with each other"
    else
      fail_task "pod-connectivity" "Pods can communicate with each other" \
        "Pods in the same namespace cannot reach each other"
    fi
  fi
  kubectl delete namespace "$test_ns" --wait=false &>/dev/null || true
else
  fail_task "pod-connectivity" "Pods can communicate with each other" \
    "Could not create test namespace"
fi

print_summary "q08"
[[ $FAIL -eq 0 ]]
