#!/bin/bash
# Killer.sh Question 06: Storage, PV, PVC, Pod volume

cat <<'EOF'
Question 6 | Storage, PV, PVC, Pod volume

Solve this question on the local cluster.

Create a new *PersistentVolume* named safari-pv. It should have a capacity of *2Gi*, accessMode *ReadWriteOnce*, hostPath /Volumes/Data and no storageClassName defined.

Next create a new *PersistentVolumeClaim* in *Namespace* project-t230 named safari-pvc . It should request *2Gi* storage, accessMode *ReadWriteOnce* and should not define a storageClassName. The *PVC* should bound to the *PV* correctly.

Finally create a new *Deployment* safari in *Namespace* project-t230 which mounts that volume at /tmp/safari-data. The *Pods* of that *Deployment* should be of image httpd:2-alpine.

Course files are under /opt/course/6/
EOF
