#!/bin/bash
# Cleanup for Killer.sh Set-A

KILLER_COURSE_DIR="${KILLER_COURSE_DIR:-/opt/course}"
_KILLER_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$_KILLER_LIB/course.sh"

cleanup_a01() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/1" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/1" 2>/dev/null || true
}

cleanup_a02() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/2" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/2" 2>/dev/null || true
}

cleanup_a03() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/3" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/3" 2>/dev/null || true
}

cleanup_a04() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/4" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/4" 2>/dev/null || true
}

cleanup_a05() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/5" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/5" 2>/dev/null || true
}

cleanup_a06() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/6" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/6" 2>/dev/null || true
}

cleanup_a07() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/7" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/7" 2>/dev/null || true
}

cleanup_a08() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/8" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/8" 2>/dev/null || true
}

cleanup_a09() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/9" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/9" 2>/dev/null || true
}

cleanup_a10() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/10" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/10" 2>/dev/null || true
}

cleanup_a11() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/11" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/11" 2>/dev/null || true
}

cleanup_a12() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/12" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/12" 2>/dev/null || true
}

cleanup_a13() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/13" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/13" 2>/dev/null || true
}

cleanup_a14() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/14" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/14" 2>/dev/null || true
}

cleanup_a15() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/15" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/15" 2>/dev/null || true
}

cleanup_a16() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/16" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/16" 2>/dev/null || true
}

cleanup_a17() {
cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true
                  kubectl delete namespace minio --ignore-not-found --wait=false
kubectl delete namespace project-h800 --ignore-not-found --wait=false
kubectl delete namespace project-c13 --ignore-not-found --wait=false
kubectl delete namespace api-gateway-staging --ignore-not-found --wait=false
kubectl delete namespace api-gateway-prod --ignore-not-found --wait=false
kubectl delete namespace project-t230 --ignore-not-found --wait=false
kubectl delete namespace project-swan --ignore-not-found --wait=false
kubectl delete namespace project-hamster --ignore-not-found --wait=false
kubectl delete namespace project-r500 --ignore-not-found --wait=false
kubectl delete namespace project-tiger --ignore-not-found --wait=false
kubectl delete namespace project-park --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/17" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/17" 2>/dev/null || true
}

run_question_cleanup() {
  local qid="$1"
  local fn="cleanup_${qid}"
  if ! declare -f "$fn" &>/dev/null; then
    echo "No cleanup for $qid"
    return 0
  fi
  echo -e "\033[0;36m==> Cleaning up $qid\033[0m"
  set +e
  "$fn"
  local rc=$?
  set -e
  sleep 2
  return $rc
}
