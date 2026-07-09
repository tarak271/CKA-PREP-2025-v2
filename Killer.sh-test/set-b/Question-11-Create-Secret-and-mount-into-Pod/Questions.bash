#!/bin/bash
# Killer.sh Question 11: Create Secret and mount into Pod

cat <<'EOF'
Question 11 | Create Secret and mount into Pod

Solve this question on the local cluster.

Create *Namespace* secret and implement the following in it:

* Create *Pod* secret-pod with image busybox:1. It should be kept running by executing sleep 1d or something similar  
* Create the existing *Secret* /opt/course/11/secret1.yaml and mount it readonly into the *Pod* at /tmp/secret1  
* Create a new *Secret* called secret2 which should contain user=user1 and pass=1234. These entries should be available inside the *Pod's* container as environment variables APP_USER and APP_PASS

Course files are under /opt/course/11/
EOF
