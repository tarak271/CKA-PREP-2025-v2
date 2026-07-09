#!/bin/bash
# Killer.sh Question 03: Kubelet client/server cert info

cat <<'EOF'
Question 3 | Kubelet client/server cert info

Solve this question on the local cluster.

Node cka5248-node1 has been added to the cluster using kubeadm and TLS bootstrapping.

Find the Issuer and Extended Key Usage values on this cluster for:

1. Kubelet Client Certificate, the one used for outgoing connections to the kube-apiserver  
2. Kubelet Server Certificate, the one used for incoming connections from the kube-apiserver

Write the information into file /opt/course/3/certificate-info.txt.

 

ℹ️ You can connect to the worker node using ssh cka5248-node1 from cka5248

Course files are under /opt/course/3/
EOF
