#!/bin/bash
# Remove Kubernetes and filesystem artifacts before each question lab setup.

if [[ -z "${CKA_CLEANUP_LIB_LOADED:-}" ]]; then
  CKA_CLEANUP_LIB_LOADED=1

  _cleanup_init() {
    local lib_dir
    lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=/dev/null
    [[ -z "${CKA_SAFE_OPS_LOADED:-}" ]] && source "$lib_dir/safe-ops.sh"
  }
  cleanup_q01() {
    kubectl delete namespace mariadb --ignore-not-found --wait=false
    kubectl delete pv mariadb-pv --ignore-not-found --wait=false
    rm -f "${HOME}/mariadb-deploy.yaml" /root/mariadb-deploy.yaml
  }

  cleanup_q02() {
    kubectl delete namespace argocd --ignore-not-found --wait=false
    rm -f /root/argo-helm.yaml
    helm repo remove argocd &>/dev/null || true
  }

  cleanup_q03() {
    kubectl delete deployment wordpress --ignore-not-found --wait=false
    kubectl delete service wordpress --ignore-not-found --wait=false
  }

  cleanup_q04() {
    kubectl delete deployment wordpress --ignore-not-found --wait=false
    kubectl delete service wordpress --ignore-not-found --wait=false
  }

  cleanup_q05() {
    kubectl delete hpa apache-server -n autoscale --ignore-not-found --wait=false
    kubectl delete namespace autoscale --ignore-not-found --wait=false
  }

  cleanup_q06() {
    kubectl delete namespace cert-manager --ignore-not-found --wait=false
    kubectl delete crd -l app.kubernetes.io/name=cert-manager --ignore-not-found --wait=false 2>/dev/null || \
      kubectl get crd -o name 2>/dev/null | grep cert-manager | xargs -r kubectl delete --ignore-not-found --wait=false
    rm -f /root/resources.yaml /root/subject.yaml
  }

  cleanup_q07() {
    kubectl delete priorityclass high-priority --ignore-not-found --wait=false
    kubectl delete priorityclass user-critical --ignore-not-found --wait=false
    kubectl delete namespace priority --ignore-not-found --wait=false
  }

  cleanup_q08() {
    kubectl delete -f https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml --ignore-not-found --wait=false 2>/dev/null || true
    kubectl delete namespace kube-flannel --ignore-not-found --wait=false
    kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml --ignore-not-found --wait=false 2>/dev/null || true
    kubectl delete namespace tigera-operator calico-system --ignore-not-found --wait=false
    kubectl get ns -o name 2>/dev/null | grep 'cka-cni-test' | xargs -r kubectl delete --ignore-not-found --wait=false
  }

  cleanup_q09() {
    _cleanup_init
    cleanup_cri_docker
  }

  cleanup_q10() {
    local node ns
    for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
      kubectl taint nodes "$node" PERMISSION=granted:NoSchedule- &>/dev/null || true
    done
    for ns in $(kubectl get pods -A --no-headers 2>/dev/null | awk '$2=="nginx" || $2=="nginx-fail" {print $1}' | sort -u); do
      kubectl delete pod nginx nginx-fail -n "$ns" --ignore-not-found --wait=false
    done
  }

  cleanup_q11() {
    kubectl delete gateway web-gateway --ignore-not-found --wait=false
    kubectl delete httproute web-route --ignore-not-found --wait=false
    kubectl delete ingress web --ignore-not-found --wait=false
    kubectl delete deployment web-deployment --ignore-not-found --wait=false
    kubectl delete service web-service --ignore-not-found --wait=false
    kubectl delete secret web-tls --ignore-not-found --wait=false
    kubectl delete gatewayclass nginx-class --ignore-not-found --wait=false
  }

  cleanup_q12() {
    kubectl delete namespace echo-sound --ignore-not-found --wait=false
  }

  cleanup_q13() {
    kubectl delete networkpolicy --all -n backend --ignore-not-found --wait=false
    kubectl delete namespace frontend backend --ignore-not-found --wait=false
    rm -rf /root/network-policies
  }

  cleanup_q14() {
    kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' &>/dev/null || true
    kubectl delete storageclass local-storage --ignore-not-found --wait=false
  }

  cleanup_q15() {
    if [[ -f /root/kube-apiserver.yaml.bak ]]; then
      sudo cp /root/kube-apiserver.yaml.bak /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null || true
      local i
      for i in $(seq 1 30); do
        kubectl get nodes &>/dev/null && break
        sleep 2
      done
    fi
  }

  cleanup_q16() {
    kubectl delete namespace relative --ignore-not-found --wait=false
  }

  cleanup_q17() {
    kubectl delete namespace nginx-static --ignore-not-found --wait=false
    if [[ -f /etc/hosts ]]; then
      sudo sed -i '/ckaquestion\.k8s\.local/d' /etc/hosts 2>/dev/null || \
        sed -i '/ckaquestion\.k8s\.local/d' /etc/hosts 2>/dev/null || true
    fi
    rm -f tls.key tls.crt
  }

  run_question_cleanup() {
    local qid="$1"
    local cleanup_fn="cleanup_${qid}"

    if ! declare -f "$cleanup_fn" &>/dev/null; then
      echo "No cleanup defined for ${qid}, skipping."
      return 0
    fi

    echo -e "\033[0;36m==> Cleaning up previous artifacts for ${qid}\033[0m"

    set +e
    set +u
    "$cleanup_fn"
    local rc=$?
    set -u
    set -e

    sleep 2

    if [[ $rc -ne 0 ]]; then
      echo -e "\033[1;33mCleanup exited with code $rc (continuing with lab setup)\033[0m"
    fi
  }
fi
