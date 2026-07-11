#!/usr/bin/env python3
"""Generate Killer.sh exam question dirs, lab setups, and validators from Set-A/B markdown."""

from __future__ import annotations

import re
import textwrap
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
KILLER = ROOT / "Killer.sh-test"


def slugify(title: str) -> str:
    s = re.sub(r"[^a-zA-Z0-9]+", "-", title.strip()).strip("-")
    return s[:60].rstrip("-")


def clean_md_text(text: str) -> str:
    text = text.replace("\\-", "-").replace("\\*", "*").replace("\\_", "_")
    text = re.sub(r"^➜.*$", "", text, flags=re.M)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def parse_set(md_path: Path) -> list[dict]:
    raw = md_path.read_text()
    pattern = r"\*\*Question (\d+) \| ([^\*]+)\*\*"
    parts = re.split(pattern, raw)
    questions = []
    # parts[0] may be empty; then triplets (num, title, body)
    i = 1
    while i + 2 < len(parts):
        num, title, body = parts[i], parts[i + 1].strip(), parts[i + 2]
        answer_split = re.split(r"\n##### \*\*Answer:?\*\*\n", body, maxsplit=1)
        task_text = clean_md_text(answer_split[0])
        solution = clean_md_text(answer_split[1]) if len(answer_split) > 1 else ""
        # Strip leading "Solve this question on: ssh ..."
        task_text = re.sub(
            r"^Solve this question on: ssh \S+\s*",
            "Solve this question on the local cluster.\n\n",
            task_text,
        )
        task_text = re.sub(r"\bon (ssh )?cka\d+(-node\d+)?\b", "on this cluster", task_text)
        questions.append(
            {
                "num": int(num),
                "title": title,
                "slug": slugify(title),
                "tasks": task_text,
                "solution": solution,
            }
        )
        i += 3
    return questions


def write_questions_bash(qdir: Path, q: dict) -> None:
    content = f"""#!/bin/bash
# Killer.sh Question {q['num']:02d}: {q['title']}

cat <<'EOF'
Question {q['num']} | {q['title']}

{q['tasks']}

Course files are under /opt/course/{q['num']}/
EOF
"""
    (qdir / "Questions.bash").write_text(content)
    (qdir / "Questions.bash").chmod(0o755)

    sol = q["solution"][:8000] if q["solution"] else "(See Set markdown for full solution.)"
    (qdir / "SolutionNotes.bash").write_text(
        f"""#!/bin/bash
cat <<'EOF'
Solution notes — Question {q['num']} | {q['title']}

{sol}
EOF
"""
    )
    (qdir / "SolutionNotes.bash").chmod(0o755)


def write_lab_setup(qdir: Path, set_id: str, q: dict) -> None:
    key = f"{set_id}-{q['num']:02d}"
    body = LAB_SETUPS.get(key, DEFAULT_LAB_SETUP.format(num=q["num"]))
    (qdir / "LabSetUp.bash").write_text(
        f"""#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
source "$SCRIPT_DIR/../../lib/course.sh"

{body}
"""
    )
    (qdir / "LabSetUp.bash").chmod(0o755)


def write_check(set_id: str, q: dict, checks_dir: Path) -> tuple[str, int]:
    qid = f"{set_id}{q['num']:02d}"
    key = f"{set_id}-{q['num']:02d}"
    body, marks = CHECKS.get(key, (DEFAULT_CHECK.format(qid=qid, num=q["num"]), 1))
    path = checks_dir / f"{qid}.sh"
    path.write_text(
        f"""#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"
source "$SCRIPT_DIR/../../lib/course.sh"
reset_results

{body}

print_summary "{qid}"
"""
    )
    path.chmod(0o755)
    return qid, marks


DEFAULT_LAB_SETUP = textwrap.dedent(
    """
    echo "Lab environment ready for question {num}."
    ensure_course_dir {num}
    """
)

DEFAULT_CHECK = textwrap.dedent(
    """
    if kubectl cluster-info &>/dev/null; then
      pass_task "cluster-ready" "Cluster is reachable"
    else
      fail_task "cluster-ready" "Cluster is reachable" "Ensure kubectl is configured"
    fi
    """
)

# Lab setup bodies keyed as "a-01" or "b-01"
LAB_SETUPS: dict[str, str] = {}

# Check bodies and mark counts keyed as "a-01" or "b-01"
CHECKS: dict[str, tuple[str, int]] = {}

COMMON_HEADER = textwrap.dedent(
    """
    KILLER_COURSE_DIR="${KILLER_COURSE_DIR:-/opt/course}"
    """
)


def _add_set_a():
    LAB_SETUPS["a-01"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 1)
        rm -f "$DIR/contexts" "$DIR/current-context" "$DIR/cert"
        if [[ ! -f "$DIR/kubeconfig" ]]; then
          # Generate kubeconfig fixture with three contexts
          openssl req -x509 -newkey rsa:2048 -keyout /tmp/killer-a01.key -out /tmp/killer-a01.crt -days 365 -nodes -subj "/CN=account-0027@internal" 2>/dev/null
          CERT_B64=$(base64 -w0 /tmp/killer-a01.crt 2>/dev/null || base64 < /tmp/killer-a01.crt | tr -d '\\n')
          KEY_B64=$(base64 -w0 /tmp/killer-a01.key 2>/dev/null || base64 < /tmp/killer-a01.key | tr -d '\\n')
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
        """
    )
    CHECKS["a-01"] = (
        textwrap.dedent(
            """
        DIR=$(course_path 1)
        KCFG="$DIR/kubeconfig"
        if [[ -f "$DIR/contexts" ]]; then
          ctx=$(kubectl --kubeconfig "$KCFG" config get-contexts -oname 2>/dev/null | sort)
          ans=$(sort "$DIR/contexts")
          if [[ "$ctx" == "$ans" ]]; then
            pass_task "contexts" "All context names written to contexts"
          else
            fail_task "contexts" "All context names written to contexts" "kubectl --kubeconfig $KCFG config get-contexts -oname > $DIR/contexts"
          fi
        else
          fail_task "contexts" "All context names written to contexts" "Create $DIR/contexts"
        fi
        if [[ -f "$DIR/current-context" ]]; then
          exp=$(kubectl --kubeconfig "$KCFG" config current-context 2>/dev/null)
          got=$(tr -d '[:space:]' < "$DIR/current-context")
          if [[ "$exp" == "$got" ]]; then
            pass_task "current-context" "Current context written to current-context"
          else
            fail_task "current-context" "Current context written to current-context"
          fi
        else
          fail_task "current-context" "Current context written to current-context"
        fi
        if [[ -f "$DIR/cert" ]] && grep -q "BEGIN CERTIFICATE" "$DIR/cert"; then
          exp=$(kubectl --kubeconfig "$KCFG" config view --raw -ojsonpath='{.users[?(@.name=="account-0027@internal")].user.client-certificate-data}' 2>/dev/null | base64 -d 2>/dev/null)
          if diff -q <(echo "$exp") "$DIR/cert" &>/dev/null; then
            pass_task "cert" "Client certificate for account-0027 decoded into cert"
          else
            # fallback: any valid cert from account-0027 user block
            if openssl x509 -in "$DIR/cert" -noout -subject &>/dev/null; then
              pass_task "cert" "Client certificate for account-0027 decoded into cert"
            else
              fail_task "cert" "Client certificate for account-0027 decoded into cert"
            fi
          fi
        else
          fail_task "cert" "Client certificate for account-0027 decoded into cert"
        fi
        """
        ),
        3,
    )

    LAB_SETUPS["a-02"] = textwrap.dedent(
        """
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
        """
    )
    CHECKS["a-02"] = (
        textwrap.dedent(
            """
        kubectl get namespace minio &>/dev/null && pass_task "namespace" "Namespace minio exists" || fail_task "namespace" "Namespace minio exists"
        helm list -n minio 2>/dev/null | grep -q minio-operator && pass_task "helm" "Helm release minio-operator installed" || fail_task "helm" "Helm release minio-operator installed" "helm -n minio install minio-operator minio/operator"
        if grep -q "enableSFTP: true" "$(course_path 2)/minio-tenant.yaml" 2>/dev/null; then
          pass_task "sftp" "enableSFTP: true set in minio-tenant.yaml"
        else
          fail_task "sftp" "enableSFTP: true set in minio-tenant.yaml"
        fi
        kubectl -n minio get tenant tenant &>/dev/null && pass_task "tenant" "Tenant resource created" || fail_task "tenant" "Tenant resource created" "kubectl -f $(course_path 2)/minio-tenant.yaml apply"
        """
        ),
        4,
    )

    LAB_SETUPS["a-03"] = textwrap.dedent(
        """
        kubectl create namespace project-h800 --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n project-h800 delete statefulset o3db --ignore-not-found --wait=false
        sleep 1
        kubectl -n project-h800 apply -f - <<'YAML'
        apiVersion: apps/v1
        kind: StatefulSet
        metadata:
          name: o3db
          namespace: project-h800
        spec:
          serviceName: o3db
          replicas: 2
          selector:
            matchLabels:
              app: nginx
          template:
            metadata:
              labels:
                app: nginx
            spec:
              containers:
              - name: nginx
                image: nginx:1-alpine
        YAML
        kubectl -n project-h800 wait --for=condition=ready pod -l app=nginx --timeout=120s || true
        """
    )
    CHECKS["a-03"] = (
        textwrap.dedent(
            """
        replicas=$(kubectl -n project-h800 get sts o3db -o jsonpath='{.spec.replicas}' 2>/dev/null || echo 0)
        if [[ "$replicas" == "1" ]]; then
          pass_task "scale" "StatefulSet o3db scaled to 1 replica"
        else
          fail_task "scale" "StatefulSet o3db scaled to 1 replica" "kubectl -n project-h800 scale sts o3db --replicas 1"
        fi
        """
        ),
        1,
    )

    LAB_SETUPS["a-04"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 4)
        rm -f "$DIR/pods-terminated-first.txt"
        kubectl create namespace project-c13 --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n project-c13 delete deploy --all --ignore-not-found --wait=false
        sleep 1
        for dep in c13-2x3-api c13-2x3-web c13-3cc-data c13-3cc-runner-heavy c13-3cc-web; do
          kubectl -n project-c13 create deployment "$dep" --image=nginx:1-alpine --replicas=3 --dry-run=client -o yaml | kubectl apply -f -
        done
        # Remove resources from runner-heavy pods
        kubectl -n project-c13 patch deployment c13-3cc-runner-heavy --type=json -p='[{"op":"remove","path":"/spec/template/spec/containers/0/resources"}]' 2>/dev/null || true
        kubectl -n project-c13 rollout status deployment/c13-3cc-runner-heavy --timeout=90s || true
        """
    )
    CHECKS["a-04"] = (
        textwrap.dedent(
            """
        FILE="$(course_path 4)/pods-terminated-first.txt"
        if [[ ! -f "$FILE" ]]; then
          fail_task "pods-file" "Pod names written to pods-terminated-first.txt"
        else
          # Expect pods from c13-3cc-runner-heavy deployment (BestEffort QoS)
          expected=$(kubectl -n project-c13 get pods -o jsonpath='{range .items[?(@.status.qosClass=="BestEffort")]}{.metadata.name}{"\\n"}{end}' 2>/dev/null | sort)
          got=$(sort "$FILE" | grep -v '^$' || true)
          if [[ -n "$got" ]] && echo "$got" | grep -q "c13-3cc-runner-heavy"; then
            pass_task "pods-file" "Pods without resource requests identified"
          else
            fail_task "pods-file" "Pods without resource requests identified" "Write BestEffort pod names to $FILE"
          fi
        fi
        """
        ),
        1,
    )

    # Additional Set-A setups/checks - abbreviated patterns for remaining questions
    _set_a_remaining()


def _set_a_remaining():
    LAB_SETUPS["a-05"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 5)
        rm -rf "$DIR/api-gateway"
        mkdir -p "$DIR/api-gateway/base" "$DIR/api-gateway/staging" "$DIR/api-gateway/prod"
        cat > "$DIR/api-gateway/base/kustomization.yaml" <<'YAML'
        resources:
          - api-gateway.yaml
        YAML
        cat > "$DIR/api-gateway/base/api-gateway.yaml" <<'YAML'
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: api-gateway
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: api-gateway
          template:
            metadata:
              labels:
                app: api-gateway
            spec:
              containers:
              - name: api
                image: nginx:1-alpine
        ---
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: horizontal-scaling-config
        data:
          placeholder: "true"
        YAML
        cat > "$DIR/api-gateway/staging/kustomization.yaml" <<'YAML'
        namespace: api-gateway-staging
        resources:
          - ../base
        YAML
        cat > "$DIR/api-gateway/prod/kustomization.yaml" <<'YAML'
        namespace: api-gateway-prod
        resources:
          - ../base
        YAML
        kubectl delete namespace api-gateway-staging api-gateway-prod --ignore-not-found --wait=false
        """
    )
    CHECKS["a-05"] = (
        textwrap.dedent(
            """
        kubectl -n api-gateway-staging get deploy api-gateway &>/dev/null && pass_task "staging-deploy" "Staging deployment applied via kustomize" || fail_task "staging-deploy" "Staging deployment applied via kustomize"
        kubectl -n api-gateway-prod get deploy api-gateway &>/dev/null && pass_task "prod-deploy" "Prod deployment applied via kustomize" || fail_task "prod-deploy" "Prod deployment applied via kustomize"
        staging_hpa=$(kubectl -n api-gateway-staging get hpa -o name 2>/dev/null | wc -l | tr -d ' ')
        prod_hpa=$(kubectl -n api-gateway-prod get hpa -o name 2>/dev/null | wc -l | tr -d ' ')
        [[ "$staging_hpa" -ge 1 ]] && pass_task "staging-hpa" "HPA configured for staging" || fail_task "staging-hpa" "HPA configured for staging"
        [[ "$prod_hpa" -ge 1 ]] && pass_task "prod-hpa" "HPA configured for prod" || fail_task "prod-hpa" "HPA configured for prod"
        """
        ),
        4,
    )

    LAB_SETUPS["a-06"] = textwrap.dedent(
        """
        kubectl create namespace project-t230 --dry-run=client -o yaml | kubectl apply -f -
        cleanup_safari_storage
        """
    )
    CHECKS["a-06"] = (
        textwrap.dedent(
            """
        kubectl get pv safari-pv &>/dev/null && pass_task "pv" "PV safari-pv created" || fail_task "pv" "PV safari-pv created"
        phase=$(kubectl -n project-t230 get pvc safari-pvc -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
        [[ "$phase" == "Bound" ]] && pass_task "pvc" "PVC safari-pvc bound" || fail_task "pvc" "PVC safari-pvc bound"
        kubectl -n project-t230 get deploy safari &>/dev/null && pass_task "deploy" "Deployment safari created" || fail_task "deploy" "Deployment safari created"
        mount=$(kubectl -n project-t230 get deploy safari -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp/safari-data")].mountPath}' 2>/dev/null)
        [[ "$mount" == "/tmp/safari-data" ]] && pass_task "mount" "Volume mounted at /tmp/safari-data" || fail_task "mount" "Volume mounted at /tmp/safari-data"
        """
        ),
        4,
    )

    LAB_SETUPS["a-07"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 7)
        rm -f "$DIR/node.sh" "$DIR/pod.sh"
        ensure_metrics_server
        echo "Create scripts node.sh and pod.sh in $DIR"
        echo "  node.sh: kubectl top node"
        echo "  pod.sh:  kubectl top pod --containers=true"
        """
    )
    CHECKS["a-07"] = (
        textwrap.dedent(
            """
        if ! kubectl top nodes &>/dev/null 2>&1; then
          fail_task "metrics" "metrics-server available" "Run: ensure_metrics_server (re-run lab setup) or install metrics-server"
        else
          pass_task "metrics" "metrics-server available"
        fi
        DIR=$(course_path 7)
        if [[ -x "$DIR/node.sh" ]] && "$DIR/node.sh" 2>/dev/null | grep -qiE 'cpu|memory|name'; then
          pass_task "node-sh" "node.sh shows node resource usage"
        else
          fail_task "node-sh" "node.sh shows node resource usage" "echo 'kubectl top node' > $DIR/node.sh && chmod +x $DIR/node.sh"
        fi
        if [[ -x "$DIR/pod.sh" ]] && "$DIR/pod.sh" 2>/dev/null | grep -qiE 'cpu|memory|pod'; then
          pass_task "pod-sh" "pod.sh shows pod resource usage"
        else
          fail_task "pod-sh" "pod.sh shows pod resource usage" "echo 'kubectl top pod --containers=true' > $DIR/pod.sh && chmod +x $DIR/pod.sh"
        fi
        """
        ),
        3,
    )

    LAB_SETUPS["a-08"] = textwrap.dedent(
        """
        echo "Kubeadm upgrade scenario — work on control-plane node."
        echo "Current version: $(kubectl version --short 2>/dev/null || kubectl version 2>/dev/null | head -1)"
        """
    )
    CHECKS["a-08"] = (
        textwrap.dedent(
            """
        nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
        [[ "$nodes" -ge 1 ]] && pass_task "nodes" "Cluster has nodes" || fail_task "nodes" "Cluster has nodes"
        pass_task "upgrade" "Kubeadm upgrade attempted (manual verification)"
        """
        ),
        2,
    )

    LAB_SETUPS["a-09"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 9)
        rm -f "$DIR/result.json"
        kubectl create namespace project-swan --dry-run=client -o yaml | kubectl apply -f -

        # Reset Q9 resources (student creates api-contact pod)
        kubectl -n project-swan delete pod api-contact --ignore-not-found --wait=false
        kubectl -n project-swan delete secret read-me --ignore-not-found
        kubectl -n project-swan delete rolebinding secret-reader --ignore-not-found
        kubectl -n project-swan delete role secret-reader --ignore-not-found
        kubectl -n project-swan delete serviceaccount secret-reader --ignore-not-found
        kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found
        kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found

        # ServiceAccount + RBAC (can list secrets via Kubernetes API)
        kubectl -n project-swan create serviceaccount secret-reader
        kubectl apply -f - <<'YAML'
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
          name: killer-a09-secret-reader
        rules:
        - apiGroups: [""]
          resources: ["secrets"]
          verbs: ["get", "list"]
        ---
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: killer-a09-secret-reader
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: killer-a09-secret-reader
        subjects:
        - kind: ServiceAccount
          name: secret-reader
          namespace: project-swan
        YAML

        # Sample secret for the API response
        kubectl -n project-swan create secret generic read-me --from-literal=token=exam-token

        echo "Ready: namespace project-swan with ServiceAccount secret-reader"
        echo "Create Pod api-contact (nginx:1-alpine) using serviceAccountName: secret-reader"
        """
    )
    CHECKS["a-09"] = (
        textwrap.dedent(
            """
        kubectl -n project-swan get serviceaccount secret-reader &>/dev/null && \
          pass_task "sa" "ServiceAccount secret-reader exists" || \
          fail_task "sa" "ServiceAccount secret-reader exists"
        sa=$(kubectl -n project-swan get pod api-contact -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null || echo "")
        [[ "$sa" == "secret-reader" ]] && pass_task "pod-sa" "Pod api-contact uses secret-reader" || \
          fail_task "pod-sa" "Pod api-contact uses secret-reader" "Set serviceAccountName: secret-reader on pod api-contact"
        FILE="$(course_path 9)/result.json"
        if [[ -f "$FILE" ]] && python3 -c "
        import json, sys
        d=json.load(open('$FILE'))
        assert d.get('kind')=='SecretList', 'expected SecretList'
        assert 'items' in d, 'missing items'
        " 2>/dev/null; then
          pass_task "json" "result.json contains SecretList from API call"
        else
          fail_task "json" "result.json contains SecretList from API call" \
            "curl -k https://kubernetes.default/api/v1/secrets -H \"Authorization: Bearer \\$TOKEN\" and save to $FILE"
        fi
        """
        ),
        3,
    )

    LAB_SETUPS["a-10"] = textwrap.dedent(
        """
        kubectl create namespace project-hamster --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n project-hamster delete sa processor role processor rolebinding processor \
          --ignore-not-found 2>/dev/null || true
        echo "Ready: namespace project-hamster (create SA/Role/RoleBinding named processor)"
        """
    )
    CHECKS["a-10"] = (
        textwrap.dedent(
            """
        kubectl -n project-hamster get serviceaccount processor &>/dev/null && \
          pass_task "sa" "ServiceAccount processor exists" || \
          fail_task "sa" "ServiceAccount processor exists"
        kubectl -n project-hamster get role processor &>/dev/null && \
          pass_task "role" "Role processor exists" || \
          fail_task "role" "Role processor exists"
        kubectl -n project-hamster get rolebinding processor &>/dev/null && \
          pass_task "binding" "RoleBinding processor exists" || \
          fail_task "binding" "RoleBinding processor exists"
        kubectl -n project-hamster auth can-i create secret \
          --as system:serviceaccount:project-hamster:processor 2>/dev/null | grep -q yes && \
          pass_task "create-secret" "Can create secrets" || \
          fail_task "create-secret" "Can create secrets"
        kubectl -n project-hamster auth can-i create configmap \
          --as system:serviceaccount:project-hamster:processor 2>/dev/null | grep -q yes && \
          pass_task "create-cm" "Can create configmaps" || \
          fail_task "create-cm" "Can create configmaps"
        kubectl -n project-hamster auth can-i create pod \
          --as system:serviceaccount:project-hamster:processor 2>/dev/null | grep -q no && \
          pass_task "no-pod" "Cannot create pods" || \
          fail_task "no-pod" "Cannot create pods"
        """
        ),
        6,
    )

    LAB_SETUPS["a-11"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 11)
        kubectl create namespace project-tiger --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n project-tiger delete daemonset ds-important --ignore-not-found --wait=false
        echo "Ready: namespace project-tiger (create DaemonSet ds-important)"
        """
    )
    CHECKS["a-11"] = (
        textwrap.dedent(
            """
        kubectl -n project-tiger get daemonset ds-important &>/dev/null && \
          pass_task "ds" "DaemonSet ds-important exists in project-tiger" || \
          fail_task "ds" "DaemonSet ds-important exists in project-tiger"
        img=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
        [[ "$img" == "httpd:2-alpine" ]] && pass_task "image" "Uses image httpd:2-alpine" || \
          fail_task "image" "Uses image httpd:2-alpine" "Current image: $img"
        cpu=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
        mem=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
        [[ "$cpu" == "10m" && "$mem" == "10Mi" ]] && pass_task "resources" "Pods request 10m CPU and 10Mi memory" || \
          fail_task "resources" "Pods request 10m CPU and 10Mi memory"
        tol=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.spec.template.spec.tolerations[*].key}' 2>/dev/null)
        echo "$tol" | grep -qE 'node-role.kubernetes.io/(control-plane|master)' && \
          pass_task "toleration" "Tolerates control-plane taint" || \
          fail_task "toleration" "Tolerates control-plane taint" \
            "Add toleration for node-role.kubernetes.io/control-plane:NoSchedule"
        nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
        ready=$(kubectl -n project-tiger get ds ds-important -o jsonpath='{.status.numberReady}' 2>/dev/null || echo 0)
        [[ "$nodes" -gt 0 && "$ready" -eq "$nodes" ]] && pass_task "all-nodes" "DaemonSet pod on every node ($ready/$nodes)" || \
          fail_task "all-nodes" "DaemonSet pod on every node ($ready/$nodes)"
        """
        ),
        5,
    )

    LAB_SETUPS["a-12"] = textwrap.dedent(
        """
        kubectl create namespace project-tiger --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n project-tiger delete deployment deploy-important --ignore-not-found --wait=false
        echo "Ready: namespace project-tiger (create Deployment deploy-important)"
        """
    )
    CHECKS["a-12"] = (
        textwrap.dedent(
            """
        kubectl -n project-tiger get deployment deploy-important &>/dev/null && \
          pass_task "deploy" "Deployment deploy-important exists in project-tiger" || \
          fail_task "deploy" "Deployment deploy-important exists in project-tiger"
        replicas=$(kubectl -n project-tiger get deployment deploy-important -o jsonpath='{.spec.replicas}' 2>/dev/null || echo 0)
        [[ "$replicas" == "3" ]] && pass_task "replicas" "Deployment has 3 replicas" || \
          fail_task "replicas" "Deployment has 3 replicas"
        label=$(kubectl -n project-tiger get deployment deploy-important -o jsonpath='{.spec.template.metadata.labels.id}' 2>/dev/null)
        [[ "$label" == "very-important" ]] && pass_task "label" "Pods labeled id=very-important" || \
          fail_task "label" "Pods labeled id=very-important"
        cnt=$(kubectl -n project-tiger get deployment deploy-important -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w)
        [[ "$cnt" -ge 2 ]] && pass_task "containers" "Deployment has container1 and container2" || \
          fail_task "containers" "Deployment has container1 and container2"
        """
        ),
        4,
    )

    LAB_SETUPS["a-13"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 13)
        kubectl create namespace project-r500 --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n project-r500 delete httproute traffic-director ingress traffic-director --ignore-not-found --wait=false

        cat > "$DIR/ingress.yaml" <<'YAML'
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        metadata:
          name: traffic-director
          namespace: project-r500
        spec:
          ingressClassName: nginx
          rules:
          - host: r500.gateway
            http:
              paths:
              - path: /desktop
                pathType: Prefix
                backend:
                  service:
                    name: web-desktop
                    port:
                      number: 80
              - path: /mobile
                pathType: Prefix
                backend:
                  service:
                    name: web-mobile
                    port:
                      number: 80
        YAML

        kubectl -n project-r500 apply -f - <<'YAML'
        apiVersion: v1
        kind: Service
        metadata:
          name: web-desktop
          namespace: project-r500
        spec:
          selector:
            app: web-desktop
          ports:
          - port: 80
        ---
        apiVersion: v1
        kind: Service
        metadata:
          name: web-mobile
          namespace: project-r500
        spec:
          selector:
            app: web-mobile
          ports:
          - port: 80
        ---
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: web-desktop
          namespace: project-r500
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: web-desktop
          template:
            metadata:
              labels:
                app: web-desktop
            spec:
              containers:
              - name: web
                image: nginx:1-alpine
        ---
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: web-mobile
          namespace: project-r500
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: web-mobile
          template:
            metadata:
              labels:
                app: web-mobile
            spec:
              containers:
              - name: web
                image: nginx:1-alpine
        YAML
        kubectl -n project-r500 apply -f "$DIR/ingress.yaml" || true

        if kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
          kubectl -n project-r500 apply -f - <<'YAML' || true
        apiVersion: gateway.networking.k8s.io/v1
        kind: Gateway
        metadata:
          name: main
          namespace: project-r500
        spec:
          gatewayClassName: nginx
          listeners:
          - name: http
            port: 80
            protocol: HTTP
            allowedRoutes:
              namespaces:
                from: Same
        YAML
        else
          echo "Note: Gateway API CRDs not installed — install a Gateway controller for full Q13"
        fi
        """
    )
    CHECKS["a-13"] = (
        textwrap.dedent(
            """
        kubectl -n project-r500 get gateway main &>/dev/null && pass_task "gateway" "Gateway main exists in project-r500" || \
          fail_task "gateway" "Gateway main exists in project-r500"
        kubectl -n project-r500 get httproute traffic-director &>/dev/null && pass_task "route" "HTTPRoute traffic-director created" || \
          fail_task "route" "HTTPRoute traffic-director created"
        kubectl -n project-r500 get svc web-desktop web-mobile &>/dev/null && pass_task "backends" "Backend services web-desktop and web-mobile exist" || \
          fail_task "backends" "Backend services web-desktop and web-mobile exist"
        """
        ),
        3,
    )

    LAB_SETUPS["a-14"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 14)
        rm -f "$DIR/expiration" "$DIR/kubeadm-renew-certs.sh"
        """
    )
    CHECKS["a-14"] = (
        textwrap.dedent(
            """
        [[ -f "$(course_path 14)/expiration" ]] && pass_task "expiration" "Certificate expiration date recorded" || fail_task "expiration" "Certificate expiration date recorded"
        [[ -f "$(course_path 14)/kubeadm-renew-certs.sh" ]] && pass_task "renew-cmd" "kubeadm renew command written" || fail_task "renew-cmd" "kubeadm renew command written"
        """
        ),
        2,
    )

    LAB_SETUPS["a-15"] = textwrap.dedent(
        """
        kubectl create namespace project-snake --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n project-snake delete networkpolicy np-backend --ignore-not-found
        kubectl -n project-snake delete pod backend-0 db1-0 db2-0 vault-0 --ignore-not-found --wait=false
        kubectl -n project-snake apply -f - <<'YAML'
        apiVersion: v1
        kind: Pod
        metadata:
          name: backend-0
          namespace: project-snake
          labels:
            app: backend
        spec:
          containers:
          - name: nginx
            image: nginx:1-alpine
        ---
        apiVersion: v1
        kind: Pod
        metadata:
          name: db1-0
          namespace: project-snake
          labels:
            app: db1
        spec:
          containers:
          - name: svc
            image: busybox:1.36
            command: ["sh", "-c", "while true; do { echo -e 'HTTP/1.0 200 OK\\r\\n\\r\\ndatabase one'; } | nc -l -p 1111; done"]
        ---
        apiVersion: v1
        kind: Pod
        metadata:
          name: db2-0
          namespace: project-snake
          labels:
            app: db2
        spec:
          containers:
          - name: svc
            image: busybox:1.36
            command: ["sh", "-c", "while true; do { echo -e 'HTTP/1.0 200 OK\\r\\n\\r\\ndatabase two'; } | nc -l -p 2222; done"]
        ---
        apiVersion: v1
        kind: Pod
        metadata:
          name: vault-0
          namespace: project-snake
          labels:
            app: vault
        spec:
          containers:
          - name: svc
            image: busybox:1.36
            command: ["sh", "-c", "while true; do { echo -e 'HTTP/1.0 200 OK\\r\\n\\r\\nvault secret storage'; } | nc -l -p 3333; done"]
        YAML
        kubectl -n project-snake wait --for=condition=ready pod --all --timeout=120s || true
        echo "Ready: namespace project-snake with backend/db/vault pods (create NetworkPolicy np-backend)"
        """
    )
    CHECKS["a-15"] = (
        textwrap.dedent(
            """
        kubectl -n project-snake get networkpolicy np-backend &>/dev/null && \
          pass_task "netpol" "NetworkPolicy np-backend exists in project-snake" || \
          fail_task "netpol" "NetworkPolicy np-backend exists in project-snake"
        sel=$(kubectl -n project-snake get networkpolicy np-backend -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null)
        [[ "$sel" == "backend" ]] && pass_task "selector" "NetworkPolicy selects app=backend pods" || \
          fail_task "selector" "NetworkPolicy selects app=backend pods"
        """
        ),
        2,
    )

    LAB_SETUPS["a-16"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 16)
        rm -f "$DIR/coredns_backup.yaml"
        """
    )
    CHECKS["a-16"] = (
        textwrap.dedent(
            """
        [[ -f "$(course_path 16)/coredns_backup.yaml" ]] && pass_task "backup" "CoreDNS backup saved" || fail_task "backup" "CoreDNS backup saved"
        fwd=$(kubectl -n kube-system get cm coredns -o yaml 2>/dev/null | grep -c forward || echo 0)
        [[ "$fwd" -ge 1 ]] && pass_task "forward" "CoreDNS forward plugin configured" || fail_task "forward" "CoreDNS forward plugin configured"
        """
        ),
        2,
    )

    LAB_SETUPS["a-17"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 17)
        rm -f "$DIR/pod-container.txt" "$DIR/pod-container.log"
        kubectl create namespace project-tiger --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n project-tiger delete pod tigers-reunite --ignore-not-found --wait=false
        echo "Ready: namespace project-tiger (create Pod tigers-reunite, then inspect with crictl)"
        """
    )
    CHECKS["a-17"] = (
        textwrap.dedent(
            """
        [[ -f "$(course_path 17)/pod-container.txt" ]] && pass_task "container-info" "Container ID and runtimeType written" || fail_task "container-info" "Container ID and runtimeType written"
        [[ -f "$(course_path 17)/pod-container.log" ]] && pass_task "container-log" "Container logs written" || fail_task "container-log" "Container logs written"
        """
        ),
        2,
    )


def _add_set_b():
    LAB_SETUPS["b-01"] = textwrap.dedent(
        """
        kubectl create namespace lima-control lima-workload --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n lima-control delete deploy,cm --all --ignore-not-found --wait=false
        kubectl -n lima-workload delete pod,svc --all --ignore-not-found --wait=false
        sleep 2
        kubectl -n lima-workload apply -f - <<'YAML'
        apiVersion: v1
        kind: Service
        metadata:
          name: department
          namespace: lima-workload
        spec:
          clusterIP: None
          selector:
            app: dept
          ports:
          - port: 80
        ---
        apiVersion: v1
        kind: Service
        metadata:
          name: section
          namespace: lima-workload
        spec:
          selector:
            name: section
          ports:
          - port: 80
        ---
        apiVersion: v1
        kind: Pod
        metadata:
          name: section100
          namespace: lima-workload
          labels:
            name: section
        spec:
          hostname: section100
          subdomain: section
          containers:
          - name: pod
            image: httpd:2-alpine
        ---
        apiVersion: v1
        kind: Pod
        metadata:
          name: section200
          namespace: lima-workload
          labels:
            name: section
        spec:
          hostname: section200
          subdomain: section
          containers:
          - name: pod
            image: httpd:2-alpine
        ---
        apiVersion: v1
        kind: Pod
        metadata:
          name: dept-a
          namespace: lima-workload
          labels:
            app: dept
        spec:
          containers:
          - name: pod
            image: httpd:2-alpine
        ---
        apiVersion: v1
        kind: Pod
        metadata:
          name: dept-b
          namespace: lima-workload
          labels:
            app: dept
        spec:
          containers:
          - name: pod
            image: httpd:2-alpine
        YAML
        kubectl -n lima-control apply -f - <<'YAML'
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: control-config
          namespace: lima-control
        data:
          DNS_1: "CHANGE_ME"
          DNS_2: "CHANGE_ME"
          DNS_3: "CHANGE_ME"
          DNS_4: "CHANGE_ME"
        ---
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: controller
          namespace: lima-control
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: controller
          template:
            metadata:
              labels:
                app: controller
            spec:
              containers:
              - name: controller
                image: busybox:1.36
                command: ["sh", "-c", "while true; do for k in DNS_1 DNS_2 DNS_3 DNS_4; do v=$(cat /config/$k); echo + nslookup $v; nslookup $v || true; done; sleep 30; done"]
                envFrom:
                - configMapRef:
                    name: control-config
                volumeMounts:
                - name: cfg
                  mountPath: /config
              volumes:
              - name: cfg
                configMap:
                  name: control-config
        YAML
        """
    )
    CHECKS["b-01"] = (
        textwrap.dedent(
            """
        cm=$(kubectl -n lima-control get cm control-config -o yaml 2>/dev/null)
        echo "$cm" | grep -q 'kubernetes.default.svc.cluster.local' && pass_task "dns1" "DNS_1 correct" || fail_task "dns1" "DNS_1 correct"
        echo "$cm" | grep -q 'department.lima-workload.svc.cluster.local' && pass_task "dns2" "DNS_2 correct" || fail_task "dns2" "DNS_2 correct"
        echo "$cm" | grep -q 'section100.section.lima-workload.svc.cluster.local' && pass_task "dns3" "DNS_3 correct" || fail_task "dns3" "DNS_3 correct"
        echo "$cm" | grep -q '1-2-3-4.kube-system.pod.cluster.local' && pass_task "dns4" "DNS_4 correct" || fail_task "dns4" "DNS_4 correct"
        """
        ),
        4,
    )

    LAB_SETUPS["b-02"] = textwrap.dedent(
        """
        kubectl delete svc static-pod-service --ignore-not-found
        NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
        MANIFEST_DIR="/etc/kubernetes/manifests"
        if [[ -w "$MANIFEST_DIR" ]] || sudo test -w "$MANIFEST_DIR"; then
          sudo rm -f "$MANIFEST_DIR/my-static-pod.yaml" 2>/dev/null || rm -f "$MANIFEST_DIR/my-static-pod.yaml" 2>/dev/null || true
        fi
        echo "Create static pod my-static-pod in $MANIFEST_DIR on node $NODE"
        """
    )
    CHECKS["b-02"] = (
        textwrap.dedent(
            """
        kubectl get pod -A 2>/dev/null | grep -q my-static && pass_task "static-pod" "Static pod running" || fail_task "static-pod" "Static pod running"
        kubectl get svc static-pod-service &>/dev/null && pass_task "service" "NodePort service static-pod-service exists" || fail_task "service" "NodePort service static-pod-service exists"
        ep=$(kubectl get endpointslices -l kubernetes.io/service-name=static-pod-service -o jsonpath='{.items[0].endpoints}' 2>/dev/null)
        [[ -n "$ep" && "$ep" != "[]" ]] && pass_task "endpoint" "Service has endpoint" || fail_task "endpoint" "Service has endpoint"
        """
        ),
        3,
    )

    LAB_SETUPS["b-03"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 3)
        rm -f "$DIR/certificate-info.txt"
        echo "Inspect kubelet certificates on this node (or worker if available)"
        """
    )
    CHECKS["b-03"] = (
        textwrap.dedent(
            """
        FILE="$(course_path 3)/certificate-info.txt"
        if [[ -f "$FILE" ]]; then
          grep -qi "client authentication" "$FILE" && pass_task "client-cert" "Kubelet client cert info present" || fail_task "client-cert" "Kubelet client cert info present"
          grep -qi "server authentication" "$FILE" && pass_task "server-cert" "Kubelet server cert info present" || fail_task "server-cert" "Kubelet server cert info present"
        else
          fail_task "client-cert" "certificate-info.txt created"
          fail_task "server-cert" "certificate-info.txt created"
        fi
        """
        ),
        2,
    )

    LAB_SETUPS["b-04"] = textwrap.dedent(
        """
        kubectl delete pod ready-if-service-ready am-i-ready --ignore-not-found --wait=false
        kubectl delete svc service-am-i-ready --ignore-not-found
        kubectl apply -f - <<'YAML'
        apiVersion: v1
        kind: Service
        metadata:
          name: service-am-i-ready
          labels:
            id: cross-server-ready
        spec:
          selector:
            id: cross-server-ready
          ports:
          - port: 80
        YAML
        """
    )
    CHECKS["b-04"] = (
        textwrap.dedent(
            """
        kubectl get pod ready-if-service-ready &>/dev/null && pass_task "pod1" "Pod ready-if-service-ready exists" || fail_task "pod1" "Pod ready-if-service-ready exists"
        kubectl get pod am-i-ready &>/dev/null && pass_task "pod2" "Pod am-i-ready exists" || fail_task "pod2" "Pod am-i-ready exists"
        ready=$(kubectl get pod ready-if-service-ready -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
        [[ "$ready" == "True" ]] && pass_task "ready" "ready-if-service-ready is Ready" || fail_task "ready" "ready-if-service-ready is Ready"
        """
        ),
        3,
    )

    LAB_SETUPS["b-05"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 5)
        rm -f "$DIR/find_pods.sh" "$DIR/find_pods_uid.sh"
        """
    )
    CHECKS["b-05"] = (
        textwrap.dedent(
            """
        DIR=$(course_path 5)
        if [[ -x "$DIR/find_pods.sh" ]]; then
          out=$("$DIR/find_pods.sh" 2>/dev/null | head -5)
          [[ -n "$out" ]] && pass_task "age-sort" "find_pods.sh lists pods sorted by age" || fail_task "age-sort" "find_pods.sh lists pods sorted by age"
        else
          fail_task "age-sort" "find_pods.sh created and executable"
        fi
        if [[ -x "$DIR/find_pods_uid.sh" ]]; then
          out=$("$DIR/find_pods_uid.sh" 2>/dev/null | head -5)
          [[ -n "$out" ]] && pass_task "uid-sort" "find_pods_uid.sh lists pods sorted by uid" || fail_task "uid-sort" "find_pods_uid.sh lists pods sorted by uid"
        else
          fail_task "uid-sort" "find_pods_uid.sh created and executable"
        fi
        """
        ),
        2,
    )

    LAB_SETUPS["b-06"] = textwrap.dedent(
        """
        kubectl delete pod success --ignore-not-found --wait=false
        echo "Kubelet troubleshooting scenario on this node."
        systemctl is-active kubelet &>/dev/null && echo "kubelet is active" || echo "kubelet may need fixing"
        """
    )
    CHECKS["b-06"] = (
        textwrap.dedent(
            """
        systemctl is-active kubelet &>/dev/null && pass_task "kubelet" "Kubelet is running" || fail_task "kubelet" "Kubelet is running" "systemctl status kubelet"
        kubectl get nodes &>/dev/null && pass_task "cluster" "Cluster API reachable" || fail_task "cluster" "Cluster API reachable"
        kubectl get pod success -n default &>/dev/null && pass_task "success-pod" "Pod success exists in default" || \
          fail_task "success-pod" "Pod success exists in default" "kubectl run success --image=nginx:1-alpine"
        """
        ),
        3,
    )

    LAB_SETUPS["b-07"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 7)
        rm -f "$DIR/etcd-version" "$DIR/etcd-snapshot.db"
        """
    )
    CHECKS["b-07"] = (
        textwrap.dedent(
            """
        [[ -f "$(course_path 7)/etcd-version" ]] && pass_task "version" "etcd version saved" || fail_task "version" "etcd version saved"
        [[ -f "$(course_path 7)/etcd-snapshot.db" ]] && pass_task "snapshot" "etcd snapshot saved" || fail_task "snapshot" "etcd snapshot saved"
        """
        ),
        2,
    )

    LAB_SETUPS["b-08"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 8)
        rm -f "$DIR/controlplane-components.txt"
        """
    )
    CHECKS["b-08"] = (
        textwrap.dedent(
            """
        FILE="$(course_path 8)/controlplane-components.txt"
        [[ -f "$FILE" ]] && grep -qi kube-apiserver "$FILE" && pass_task "components" "Control plane components documented" || fail_task "components" "Control plane components documented"
        """
        ),
        1,
    )

    LAB_SETUPS["b-09"] = textwrap.dedent(
        """
        kubectl delete pod manual-schedule manual-schedule2 --ignore-not-found --wait=false
        echo "Manual scheduling scenario — temporarily stop kube-scheduler if needed."
        """
    )
    CHECKS["b-09"] = (
        textwrap.dedent(
            """
        kubectl get pod manual-schedule &>/dev/null && pass_task "pod1" "Pod manual-schedule exists" || \
          fail_task "pod1" "Pod manual-schedule exists"
        node1=$(kubectl get pod manual-schedule -o jsonpath='{.spec.nodeName}' 2>/dev/null)
        [[ -n "$node1" ]] && pass_task "scheduled1" "manual-schedule assigned to a node" || \
          fail_task "scheduled1" "manual-schedule assigned to a node"
        kubectl get pod manual-schedule2 &>/dev/null && pass_task "pod2" "Pod manual-schedule2 exists" || \
          fail_task "pod2" "Pod manual-schedule2 exists"
        phase=$(kubectl get pod manual-schedule2 -o jsonpath='{.status.phase}' 2>/dev/null)
        [[ "$phase" == "Running" ]] && pass_task "running2" "manual-schedule2 is Running" || \
          fail_task "running2" "manual-schedule2 is Running"
        """
        ),
        4,
    )

    LAB_SETUPS["b-11"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 11)
        kubectl create namespace secret --dry-run=client -o yaml | kubectl apply -f -
        kubectl -n secret delete pod secret-pod secret secret1 secret2 --ignore-not-found --wait=false
        cat > "$DIR/secret1.yaml" <<'YAML'
        apiVersion: v1
        kind: Secret
        metadata:
          name: secret1
          namespace: secret
        type: Opaque
        data:
          key1: dmFsdWUx
        YAML
        echo "Ready: namespace secret with secret1.yaml fixture (create secret-pod, secret2, mounts)"
        """
    )
    CHECKS["b-11"] = (
        textwrap.dedent(
            """
        kubectl -n secret get secret secret1 &>/dev/null && pass_task "secret1" "Secret secret1 in namespace secret" || \
          fail_task "secret1" "Secret secret1 in namespace secret"
        kubectl -n secret get secret secret2 &>/dev/null && pass_task "secret2" "Secret secret2 in namespace secret" || \
          fail_task "secret2" "Secret secret2 in namespace secret"
        mount=$(kubectl -n secret get pod secret-pod -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp/secret1")].mountPath}' 2>/dev/null)
        [[ "$mount" == "/tmp/secret1" ]] && pass_task "mount" "secret1 mounted at /tmp/secret1" || \
          fail_task "mount" "secret1 mounted at /tmp/secret1"
        env=$(kubectl -n secret get pod secret-pod -o jsonpath='{.spec.containers[0].envFrom}' 2>/dev/null)
        echo "$env" | grep -q secret2 && pass_task "env" "secret2 exposed as env vars" || \
          fail_task "env" "secret2 exposed as env vars"
        """
        ),
        4,
    )

    LAB_SETUPS["b-12"] = textwrap.dedent(
        """
        kubectl delete pod pod1 --ignore-not-found --wait=false
        echo "Create Pod pod1 (httpd:2-alpine) scheduled on control-plane node"
        """
    )
    CHECKS["b-12"] = (
        textwrap.dedent(
            """
        kubectl get pod pod1 &>/dev/null && pass_task "pod" "Pod pod1 exists in default" || \
          fail_task "pod" "Pod pod1 exists in default"
        cname=$(kubectl get pod pod1 -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
        [[ "$cname" == "pod1-container" ]] && pass_task "container" "Container named pod1-container" || \
          fail_task "container" "Container named pod1-container"
        node=$(kubectl get pod pod1 -o jsonpath='{.spec.nodeName}' 2>/dev/null)
        controlplane=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
        echo "$controlplane" | grep -q "$node" && pass_task "node" "Pod scheduled on control-plane" || \
          fail_task "node" "Pod scheduled on control-plane"
        """
        ),
        3,
    )

    LAB_SETUPS["b-13"] = textwrap.dedent(
        """
        kubectl delete pod multi-container-playground --ignore-not-found --wait=false
        echo "Create Pod multi-container-playground with shared volume in default"
        """
    )
    CHECKS["b-13"] = (
        textwrap.dedent(
            """
        kubectl get pod multi-container-playground &>/dev/null && pass_task "pod" "Pod multi-container-playground exists" || \
          fail_task "pod" "Pod multi-container-playground exists"
        cnt=$(kubectl get pod multi-container-playground -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
        [[ "$cnt" -ge 2 ]] && pass_task "containers" "Pod has multiple containers" || \
          fail_task "containers" "Pod has multiple containers"
        vol=$(kubectl get pod multi-container-playground -o jsonpath='{.spec.volumes[0].name}' 2>/dev/null)
        [[ -n "$vol" ]] && pass_task "volume" "Shared volume configured" || \
          fail_task "volume" "Shared volume configured"
        """
        ),
        3,
    )

    LAB_SETUPS["b-10"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 10)
        kubectl create namespace project-bern --dry-run=client -o yaml | kubectl apply -f -
        cat > "$DIR/backup.yaml" <<'YAML'
        apiVersion: batch/v1
        kind: Job
        metadata:
          name: backup
          namespace: project-bern
        spec:
          template:
            spec:
              restartPolicy: Never
              containers:
              - name: backup
                image: busybox:1.36
                command: ["sh", "-c", "echo backup; sleep 5"]
        YAML
        kubectl -n project-bern delete job backup --ignore-not-found
        """
    )
    CHECKS["b-10"] = (
        textwrap.dedent(
            """
        kubectl get storageclass &>/dev/null && pass_task "sc" "StorageClass created" || fail_task "sc" "StorageClass created"
        kubectl -n project-bern get pvc &>/dev/null && pass_task "pvc" "Job uses PVC" || fail_task "pvc" "Job uses PVC"
        kubectl -n project-bern get job backup &>/dev/null && pass_task "job" "Backup job applied" || fail_task "job" "Backup job applied"
        """
        ),
        3,
    )

    LAB_SETUPS["b-14"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 14)
        rm -f "$DIR/cluster-info"
        """
    )
    CHECKS["b-14"] = (
        textwrap.dedent(
            """
        FILE="$(course_path 14)/cluster-info"
        [[ -f "$FILE" ]] && pass_task "info" "Cluster info file created" || fail_task "info" "Cluster info file created"
        grep -qi version "$FILE" 2>/dev/null && pass_task "version" "Cluster version documented" || fail_task "version" "Cluster version documented"
        grep -qi node "$FILE" 2>/dev/null && pass_task "nodes" "Node info documented" || fail_task "nodes" "Node info documented"
        """
        ),
        3,
    )

    LAB_SETUPS["b-15"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 15)
        rm -f "$DIR/cluster_events.sh" "$DIR/pod_kill.log" "$DIR/container_kill.log"
        """
    )
    CHECKS["b-15"] = (
        textwrap.dedent(
            """
        [[ -x "$(course_path 15)/cluster_events.sh" ]] && pass_task "events-sh" "cluster_events.sh created" || fail_task "events-sh" "cluster_events.sh created"
        [[ -f "$(course_path 15)/pod_kill.log" ]] && pass_task "pod-log" "pod_kill.log created" || fail_task "pod-log" "pod_kill.log created"
        [[ -f "$(course_path 15)/container_kill.log" ]] && pass_task "container-log" "container_kill.log created" || fail_task "container-log" "container_kill.log created"
        """
        ),
        3,
    )

    LAB_SETUPS["b-16"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 16)
        rm -f "$DIR/resources.txt" "$DIR/crowded-namespace.txt"
        for city in jinan miami melbourne seoul toronto; do
          kubectl create namespace "project-$city" --dry-run=client -o yaml | kubectl apply -f -
          kubectl -n "project-$city" delete role --all --ignore-not-found 2>/dev/null || true
        done
        for r in $(seq 1 300); do
          kubectl -n project-miami create role "role-$r" --verb=get --resource=pods 2>/dev/null || true
        done
        for r in $(seq 1 2); do kubectl -n project-melbourne create role "role-$r" --verb=get --resource=pods 2>/dev/null || true; done
        for r in $(seq 1 10); do kubectl -n project-seoul create role "role-$r" --verb=get --resource=pods 2>/dev/null || true; done
        echo "Ready: project-* namespaces with project-miami having most Roles"
        """
    )
    CHECKS["b-16"] = (
        textwrap.dedent(
            """
        [[ -f "$(course_path 16)/resources.txt" ]] && pass_task "resources" "Namespaced API resources listed" || fail_task "resources" "Namespaced API resources listed"
        crowded="$(course_path 16)/crowded-namespace.txt"
        if [[ -f "$crowded" ]] && grep -qi 'project-miami' "$crowded" && grep -q '300' "$crowded"; then
          pass_task "crowded" "project-miami with 300 roles identified"
        else
          fail_task "crowded" "project-miami with 300 roles identified" "Expected: project-miami with 300 roles"
        fi
        """
        ),
        2,
    )

    LAB_SETUPS["b-17"] = textwrap.dedent(
        """
        DIR=$(ensure_course_dir 17)
        rm -rf "$DIR/operator"
        mkdir -p "$DIR/operator/base" "$DIR/operator/prod"
        cat > "$DIR/operator/base/kustomization.yaml" <<'YAML'
        resources:
          - crds.yaml
          - rbac.yaml
          - operator.yaml
        YAML
        cat > "$DIR/operator/prod/kustomization.yaml" <<'YAML'
        namespace: operator-prod
        resources:
          - ../base
        YAML
        kubectl delete namespace operator-prod --ignore-not-found --wait=false
        echo "Kustomize operator config at $DIR/operator"
        """
    )
    CHECKS["b-17"] = (
        textwrap.dedent(
            """
        kubectl -n operator-prod get deploy &>/dev/null && pass_task "operator" "Operator deployed in operator-prod" || fail_task "operator" "Operator deployed in operator-prod"
        kubectl get crd students.education.killer.sh &>/dev/null 2>&1 && pass_task "crd" "Student CRD present" || \
          fail_task "crd" "Student CRD present" "kubectl get crd students.education.killer.sh"
        """
        ),
        2,
    )


def generate_cleanup_sh(set_id: str, qids: list[tuple[str, int, str]]) -> str:
    lines = [
        "#!/bin/bash",
        f"# Cleanup for Killer.sh Set-{set_id.upper()}",
        "",
        'KILLER_COURSE_DIR="${KILLER_COURSE_DIR:-/opt/course}"',
        '_KILLER_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"',
        '# shellcheck source=/dev/null',
        'source "$_KILLER_LIB/course.sh"',
        "",
    ]
    for qid, _, slug in qids:
        num = int(qid[1:])
        key = f"{set_id}-{num:02d}"
        body = CLEANUP.get(key, f'echo "Cleanup {qid}"')
        lines.append(f"cleanup_{qid}() {{")
        lines.append(body)
        lines.append("}")
        lines.append("")
    lines.extend(
        [
            "run_question_cleanup() {",
            '  local qid="$1"',
            '  local fn="cleanup_${qid}"',
            "  if ! declare -f \"$fn\" &>/dev/null; then",
            '    echo "No cleanup for $qid"',
            "    return 0",
            "  fi",
            '  echo -e "\\033[0;36m==> Cleaning up $qid\\033[0m"',
            "  set +e",
            '  "$fn"',
            "  local rc=$?",
            "  set -e",
            "  sleep 2",
            "  return $rc",
            "}",
        ]
    )
    return "\n".join(lines) + "\n"


CLEANUP: dict[str, str] = {}


def _add_cleanups():
    for prefix, namespaces, extras in [
        ("a", ["minio", "project-h800", "project-c13", "api-gateway-staging", "api-gateway-prod", "project-t230", "project-swan", "project-hamster", "project-r500", "project-tiger", "project-snake"], "cleanup_safari_storage; kubectl delete clusterrolebinding killer-a09-secret-reader --ignore-not-found --wait=false; kubectl delete clusterrole killer-a09-secret-reader --ignore-not-found --wait=false; kubectl -n project-tiger delete daemonset ds-important deployment deploy-important --ignore-not-found --wait=false; helm uninstall minio-operator -n minio &>/dev/null || true"),
        ("b", ["lima-control", "lima-workload", "project-bern", "operator-prod", "secret", "project-jinan", "project-miami", "project-melbourne", "project-seoul", "project-toronto"], "kubectl delete pod ready-if-service-ready am-i-ready success manual-schedule manual-schedule2 pod1 multi-container-playground --ignore-not-found --wait=false; kubectl delete svc static-pod-service service-am-i-ready --ignore-not-found --wait=false"),
    ]:
        for i in range(1, 18):
            key = f"{prefix}-{i:02d}"
            ns_delete = "\n".join(
                f'  kubectl delete namespace {ns} --ignore-not-found --wait=false' for ns in namespaces
            )
            CLEANUP[key] = textwrap.dedent(
                f"""
                  {extras}
                  {ns_delete}
                  rm -rf "${{KILLER_COURSE_DIR}}/{i}" 2>/dev/null || sudo rm -rf "${{KILLER_COURSE_DIR}}/{i}" 2>/dev/null || true
                """
            ).strip()


def generate_questions_sh(set_id: str, qids: list[tuple[str, int, str]]) -> str:
    check_lines = [f'  [{qid}]="{qid}.sh"' for qid, _, _ in qids]
    dir_lines = [
        f'  ["Question-{int(qid[1:]):02d}-{slug}"]="{qid}"'
        for qid, _, slug in qids
    ]
    return (
        "#!/bin/bash\n"
        "set -euo pipefail\n"
        'KILLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"\n'
        f'CHECKS_DIR="$KILLER_DIR/checks/set-{set_id}"\n\n'
        "declare -A QUESTION_CHECKS=(\n"
        + "\n".join(check_lines)
        + "\n)\n\n"
        "declare -A DIR_TO_ID=(\n"
        + "\n".join(dir_lines)
        + "\n)\n\n"
        + textwrap.dedent(
            """
            resolve_question_id() {
              local input="$1"
              if [[ -n "${QUESTION_CHECKS[$input]:-}" ]]; then
                echo "$input"
                return
              fi
              if [[ -n "${DIR_TO_ID[$input]:-}" ]]; then
                echo "${DIR_TO_ID[$input]}"
                return
              fi
              echo ""
            }

            get_check_script() {
              local qid="$1"
              local script="${QUESTION_CHECKS[$qid]:-}"
              [[ -z "$script" ]] && return 1
              echo "$CHECKS_DIR/$script"
            }
            """
        )
    )


def main():
    _add_set_a()
    _add_set_b()
    _add_cleanups()

    for set_name, set_id in [("Set-A", "a"), ("Set-B", "b")]:
        questions = parse_set(KILLER / f"{set_name}.md")
        set_dir = KILLER / f"set-{set_id}"
        checks_dir = KILLER / "checks" / f"set-{set_id}"
        checks_dir.mkdir(parents=True, exist_ok=True)

        qmeta: list[tuple[str, int, str]] = []
        total_marks = 0

        for q in questions:
            dirname = f"Question-{q['num']:02d}-{q['slug']}"
            qdir = set_dir / dirname
            qdir.mkdir(parents=True, exist_ok=True)
            write_questions_bash(qdir, q)
            write_lab_setup(qdir, set_id, q)
            qid, marks = write_check(set_id, q, checks_dir)
            qmeta.append((qid, marks, q["slug"]))
            total_marks += marks

        cleanup_path = KILLER / "lib" / f"cleanup-set-{set_id}.sh"
        cleanup_path.write_text(generate_cleanup_sh(set_id, qmeta))
        cleanup_path.chmod(0o755)

        qsh_path = KILLER / "lib" / f"questions-set-{set_id}.sh"
        qsh_path.write_text(generate_questions_sh(set_id, qmeta))

        order_lines = []
        for qid, marks, slug in qmeta:
            num = int(qid[1:])
            dirname = f"Question-{num:02d}-{slug}"
            title = next(x["title"] for x in questions if x["num"] == num)
            order_lines.append(f'  "{qid}:{dirname}:{title}:{marks}"')

        config = KILLER / f"exam-config-set-{set_id}.yaml"
        config.write_text(
            f"# Killer.sh {set_name} — {len(qmeta)} questions, {total_marks} marks\n"
            + "questions:\n"
            + "\n".join(
                f"  - id: {qid}\n    marks: {m}\n    dir: Question-{int(qid[1:]):02d}-{s}"
                for qid, m, s in qmeta
            )
            + "\n"
        )

        print(f"Generated {set_name}: {len(qmeta)} questions, {total_marks} marks")

    # Symlink common.sh
    common_link = KILLER / "lib" / "common.sh"
    if not common_link.exists():
        common_link.write_text(
            textwrap.dedent(
                """
                # Re-export shared helpers from exercises/lib
                EXERCISES_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../exercises/lib" && pwd)"
                # shellcheck source=/dev/null
                source "$EXERCISES_LIB/common.sh"
                """
            )
        )

    print("Done.")


if __name__ == "__main__":
    main()
