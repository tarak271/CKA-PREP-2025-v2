#!/bin/bash
# Verify the cluster is healthy and has no user-defined objects.

if [[ -z "${CKA_CLUSTER_VERIFY_LOADED:-}" ]]; then
  CKA_CLUSTER_VERIFY_LOADED=1

  # Namespaces allowed on a fresh post-reset cluster (includes Flannel CNI).
  CLUSTER_ALLOWED_NAMESPACES=(
    default
    kube-system
    kube-public
    kube-node-lease
    kube-flannel
  )

  namespace_is_allowed() {
    local ns="$1"
    local allowed
    for allowed in "${CLUSTER_ALLOWED_NAMESPACES[@]}"; do
      [[ "$ns" == "$allowed" ]] && return 0
    done
    return 1
  }

  verify_cluster_clean() {
    echo "=== Verifying cluster is healthy and free of user objects ==="
    sleep 10
    if ! command -v kubectl &>/dev/null; then
      echo "ERROR: kubectl not found." >&2
      return 1
    fi

    if ! kubectl cluster-info &>/dev/null; then
      echo "ERROR: Kubernetes API is not reachable." >&2
      return 1
    fi

    local ready_nodes
    ready_nodes=$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready' || true)
    if [[ "$ready_nodes" -lt 1 ]]; then
      echo "ERROR: No Ready nodes found." >&2
      kubectl get nodes 2>/dev/null || true
      return 1
    fi
    echo "  ✓ Node(s) Ready: $ready_nodes"

    local ns unexpected_ns=()
    while IFS= read -r ns; do
      [[ -z "$ns" ]] && continue
      if ! namespace_is_allowed "$ns"; then
        unexpected_ns+=("$ns")
      fi
    done < <(kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null)

    if [[ ${#unexpected_ns[@]} -gt 0 ]]; then
      echo "ERROR: User-defined namespaces found: ${unexpected_ns[*]}" >&2
      return 1
    fi
    echo "  ✓ Only system namespaces present"

    local default_resources
    default_resources=$(kubectl get all -n default --no-headers 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$default_resources" != "0" ]]; then
      echo "ERROR: User resources still exist in default namespace." >&2
      kubectl get all -n default 2>/dev/null || true
      return 1
    fi
    echo "  ✓ default namespace is empty"

    local user_pv
    user_pv=$(kubectl get pv --no-headers 2>/dev/null | grep -v '^No resources' | wc -l | tr -d ' ')
    if [[ "$user_pv" != "0" ]]; then
      echo "ERROR: PersistentVolumes still exist." >&2
      kubectl get pv 2>/dev/null || true
      return 1
    fi
    echo "  ✓ No PersistentVolumes"

    local user_pc
    user_pc=$(kubectl get priorityclass -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    if [[ -n "$user_pc" ]]; then
      echo "ERROR: User PriorityClasses found: $user_pc" >&2
      return 1
    fi
    echo "  ✓ No user PriorityClasses"

    if ! kubectl wait --namespace=kube-system --for=condition=Ready pods --all --timeout=120s &>/dev/null; then
      echo "WARNING: Not all kube-system pods are Ready yet; continuing anyway." >&2
    else
      echo "  ✓ kube-system pods Ready"
    fi

    echo "Cluster is clean and ready for the exam."
    return 0
  }

  run_cluster_reset() {
    local reset_script="$1"
    if [[ ! -f "$reset_script" ]]; then
      echo "ERROR: Cluster reset script not found: $reset_script" >&2
      return 1
    fi
    chmod +x "$reset_script"
    bash "$reset_script"
  }
fi
