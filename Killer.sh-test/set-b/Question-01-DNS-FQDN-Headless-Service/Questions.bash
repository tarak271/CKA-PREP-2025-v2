#!/bin/bash
# Killer.sh Question 01: DNS / FQDN / Headless Service

cat <<'EOF'
Question 1 | DNS / FQDN / Headless Service

Solve this question on the local cluster.

The *Deployment* controller in *Namespace* lima-control communicates with various cluster internal endpoints by using their DNS FQDN values.

Update the *ConfigMap* used by the *Deployment* with the correct FQDN values for:

1. DNS_1: *Service* kubernetes in *Namespace* default  
2. DNS_2: Headless *Service* department in *Namespace* lima-workload  
3. DNS_3: *Pod* section100 in *Namespace* lima-workload. It should work even if the *Pod* IP changes  
4. DNS_4: A *Pod* with IP 1.2.3.4 in *Namespace* kube-system

Ensure the *Deployment* works with the updated values.

 

ℹ️ You can use nslookup or dig inside a *Pod* of the controller *Deployment*

Course files are under /opt/course/1/
EOF
