#!/bin/bash
# Killer.sh Question 14: Check how long certificates are valid

cat <<'EOF'
Question 14 | Check how long certificates are valid

Solve this question on the local cluster.

Perform some tasks on cluster certificates:

1. Check how long the kube-apiserver server certificate is valid using openssl or cfssl. Write the expiration date into /opt/course/14/expiration. Run the kubeadm command to list the expiration dates and confirm both methods show the same one  
2. Write the kubeadm command that would renew the kube-apiserver certificate into /opt/course/14/kubeadm-renew-certs.sh

Course files are under /opt/course/14/
EOF
