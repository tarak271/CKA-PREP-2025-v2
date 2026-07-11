#!/bin/bash
# Cleanup for Killer.sh Set-B

KILLER_COURSE_DIR="${KILLER_COURSE_DIR:-/opt/course}"
_KILLER_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$_KILLER_LIB/course.sh"

cleanup_b01() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/1" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/1" 2>/dev/null || true
}

cleanup_b02() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/2" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/2" 2>/dev/null || true
}

cleanup_b03() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/3" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/3" 2>/dev/null || true
}

cleanup_b04() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/4" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/4" 2>/dev/null || true
}

cleanup_b05() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/5" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/5" 2>/dev/null || true
}

cleanup_b06() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/6" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/6" 2>/dev/null || true
}

cleanup_b07() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/7" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/7" 2>/dev/null || true
}

cleanup_b08() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/8" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/8" 2>/dev/null || true
}

cleanup_b09() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/9" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/9" 2>/dev/null || true
}

cleanup_b10() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/10" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/10" 2>/dev/null || true
}

cleanup_b11() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/11" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/11" 2>/dev/null || true
}

cleanup_b12() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/12" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/12" 2>/dev/null || true
}

cleanup_b13() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/13" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/13" 2>/dev/null || true
}

cleanup_b14() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/14" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/14" 2>/dev/null || true
}

cleanup_b15() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/15" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/15" 2>/dev/null || true
}

cleanup_b16() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
                rm -rf "${KILLER_COURSE_DIR}/16" 2>/dev/null || sudo rm -rf "${KILLER_COURSE_DIR}/16" 2>/dev/null || true
}

cleanup_b17() {
kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false
                  kubectl delete namespace lima-control --ignore-not-found --wait=false
kubectl delete namespace lima-workload --ignore-not-found --wait=false
kubectl delete namespace project-bern --ignore-not-found --wait=false
kubectl delete namespace operator-prod --ignore-not-found --wait=false
kubectl delete namespace secret --ignore-not-found --wait=false
kubectl delete namespace project-jinan --ignore-not-found --wait=false
kubectl delete namespace project-miami --ignore-not-found --wait=false
kubectl delete namespace project-melbourne --ignore-not-found --wait=false
kubectl delete namespace project-seoul --ignore-not-found --wait=false
kubectl delete namespace project-toronto --ignore-not-found --wait=false
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
