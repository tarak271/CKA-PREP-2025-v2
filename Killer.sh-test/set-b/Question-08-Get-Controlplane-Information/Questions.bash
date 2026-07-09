#!/bin/bash
# Killer.sh Question 08: Get Controlplane Information

cat <<'EOF'
Question 8 | Get Controlplane Information

Solve this question on the local cluster.

Check how the controlplane components kubelet, kube-apiserver, kube-scheduler, kube-controller-manager and etcd are started/installed on the controlplane node.

Also find out the name of the DNS application and how it's started/installed in the cluster.

Write your findings into file /opt/course/8/controlplane-components.txt. The file should be structured like:

\# /opt/course/8/controlplane-components.txt

kubelet: \[TYPE\]

kube-apiserver: \[TYPE\]

kube-scheduler: \[TYPE\]

kube-controller-manager: \[TYPE\]

etcd: \[TYPE\]

dns: \[TYPE\] \[NAME\]

Choices of \[TYPE\] are: not-installed, process, static-pod, pod

Course files are under /opt/course/8/
EOF
