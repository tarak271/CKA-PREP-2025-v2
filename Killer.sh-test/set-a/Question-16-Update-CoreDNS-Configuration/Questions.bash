#!/bin/bash
# Killer.sh Question 16: Update CoreDNS Configuration

cat <<'EOF'
Question 16 | Update CoreDNS Configuration

Solve this question on the local cluster.

The CoreDNS configuration in the cluster needs to be updated:

1. Make a backup of the existing configuration Yaml and store it at /opt/course/16/coredns_backup.yaml. You should be able to fast recover from the backup  
2. Update the CoreDNS configuration in the cluster so that DNS resolution for SERVICE.NAMESPACE.custom-domain will work exactly like and in addition to SERVICE.NAMESPACE.cluster.local

Test your configuration for example from a *Pod* with busybox:1 image. These commands should result in an IP address:

nslookup kubernetes.default.svc.cluster.local

nslookup kubernetes.default.svc.custom-domain

Course files are under /opt/course/16/
EOF
