#!/bin/bash
# Killer.sh Question 10: RBAC ServiceAccount Role RoleBinding

cat <<'EOF'
Question 10 | RBAC ServiceAccount Role RoleBinding

Solve this question on the local cluster.

Create a new *ServiceAccount* processor in *Namespace* project-hamster. Create a *Role* and *RoleBinding*, both named processor as well. These should allow the new *SA* to only create *Secrets* and *ConfigMaps* in that *Namespace*.

Course files are under /opt/course/10/
EOF
