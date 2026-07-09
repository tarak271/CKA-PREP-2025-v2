#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"


DIR=$(ensure_course_dir 2)
kubectl delete namespace minio --ignore-not-found --wait=false
helm uninstall minio-operator -n minio &>/dev/null || true
sleep 2
cat > "$DIR/minio-tenant.yaml" <<'YAML'
apiVersion: minio.min.io/v2
kind: Tenant
metadata:
  name: tenant
  namespace: minio
  labels:
    app: minio
spec:
  features:
    bucketDNS: false
  image: quay.io/minio/minio:latest
  pools:
    - servers: 1
      name: pool-0
      volumesPerServer: 0
      volumeClaimTemplate:
        metadata: {}
        spec:
          accessModes: [ReadWriteOnce]
          resources:
            requests:
              storage: 10Mi
          storageClassName: standard
  requestAutoCert: true
YAML
echo "MinIO tenant template at $DIR/minio-tenant.yaml (add enableSFTP: true under features)"

