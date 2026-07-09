#!/bin/bash
# Killer.sh Question 17: Operator, CRDs, RBAC, Kustomize

cat <<'EOF'
Question 17 | Operator, CRDs, RBAC, Kustomize

Solve this question on the local cluster.

There is Kustomize config available at /opt/course/17/operator. It installs an operator which works with different *CRDs*. It has been deployed like this:

kubectl kustomize /opt/course/17/operator/prod | kubectl apply -f -

Perform the following changes in the Kustomize base config:

1. The operator needs to list certain *CRDs*. Check the logs to find out which ones and adjust the permissions for *Role* operator-role  
2. Add a new *Student* resource called student4 with any name and description

Deploy your Kustomize config changes to prod.

Course files are under /opt/course/17/
EOF
