#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 1)
rm -f "$DIR/contexts" "$DIR/current-context" "$DIR/cert"
if [[ ! -f "$DIR/kubeconfig" ]]; then
  # Generate kubeconfig fixture with three contexts
  openssl req -x509 -newkey rsa:2048 -keyout /tmp/killer-a01.key -out /tmp/killer-a01.crt -days 365 -nodes -subj "/CN=account-0027@internal" 2>/dev/null
  CERT_B64=$(base64 -w0 /tmp/killer-a01.crt 2>/dev/null || base64 < /tmp/killer-a01.crt | tr -d '\n')
  KEY_B64=$(base64 -w0 /tmp/killer-a01.key 2>/dev/null || base64 < /tmp/killer-a01.key | tr -d '\n')
  CA_B64="$CERT_B64"
  cat > "$DIR/kubeconfig" <<KCFG
apiVersion: v1
kind: Config
current-context: cluster-w200
clusters:
- name: kubernetes
  cluster:
    server: https://127.0.0.1:6443
    certificate-authority-data: ${CA_B64}
contexts:
- name: cluster-admin
  context:
    cluster: kubernetes
    user: admin@internal
- name: cluster-w100
  context:
    cluster: kubernetes
    user: account-0027@internal
- name: cluster-w200
  context:
    cluster: kubernetes
    user: account-0028@internal
users:
- name: account-0027@internal
  user:
    client-certificate-data: ${CERT_B64}
    client-key-data: ${KEY_B64}
- name: account-0028@internal
  user:
    client-certificate-data: ${CERT_B64}
    client-key-data: ${KEY_B64}
- name: admin@internal
  user:
    client-certificate-data: ${CERT_B64}
    client-key-data: ${KEY_B64}
KCFG
  rm -f /tmp/killer-a01.key /tmp/killer-a01.crt
fi
echo "Kubeconfig ready at $DIR/kubeconfig"

