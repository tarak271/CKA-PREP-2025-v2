#!/bin/bash
# Helpers for /opt/course paths used by Killer.sh-style questions.

KILLER_COURSE_DIR="${KILLER_COURSE_DIR:-/opt/course}"

ensure_course_dir() {
  local num="$1"
  local dir="${KILLER_COURSE_DIR}/${num}"
  if [[ ! -d "$dir" ]]; then
    if [[ "$(id -u)" -eq 0 ]]; then
      mkdir -p "$dir"
    else
      sudo mkdir -p "$dir"
      sudo chown "$(id -u):$(id -g)" "$dir" 2>/dev/null || true
    fi
  fi
  echo "$dir"
}

course_path() {
  echo "${KILLER_COURSE_DIR}/$1"
}

reset_course_outputs() {
  local num="$1"
  shift
  local dir
  dir=$(ensure_course_dir "$num")
  for f in "$@"; do
    rm -f "${dir}/${f}"
  done
}

# Tear down Q6 safari storage without hanging on a bound PV.
cleanup_safari_storage() {
  kubectl -n project-t230 delete deployment safari --ignore-not-found --wait=false
  kubectl -n project-t230 delete pvc safari-pvc --ignore-not-found --wait=false
  sleep 1
  kubectl patch pv safari-pv -p '{"spec":{"claimRef":null}}' 2>/dev/null || true
  kubectl delete pv safari-pv --ignore-not-found --wait=false
}

# Install metrics-server when missing (required for Q7 kubectl top).
ensure_metrics_server() {
  if kubectl top nodes &>/dev/null 2>&1; then
    echo "metrics-server is already available"
    return 0
  fi

  echo "Installing metrics-server..."
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

  # Common lab clusters use self-signed kubelet certs
  kubectl patch deployment metrics-server -n kube-system --type=json -p='[
    {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"},
    {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"}
  ]' 2>/dev/null || true

  kubectl rollout status deployment/metrics-server -n kube-system --timeout=120s 2>/dev/null || true

  echo "Waiting for Metrics API..."
  local i
  for i in $(seq 1 60); do
    if kubectl top nodes &>/dev/null 2>&1; then
      echo "metrics-server ready"
      return 0
    fi
    sleep 2
  done

  echo "Warning: metrics-server installed but 'kubectl top nodes' not ready yet — wait a minute and retry"
  return 0
}
