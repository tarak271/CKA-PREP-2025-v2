#!/bin/bash
# Killer.sh Question 10: PV PVC Dynamic Provisioning

cat <<'EOF'
Question 10 | PV PVC Dynamic Provisioning

Solve this question on the local cluster.

There is a backup *Job* which needs to be adjusted to use a *PVC* to store backups.

Create a *StorageClass* named local-backup which uses provisioner: rancher.io/local-path and volumeBindingMode: WaitForFirstConsumer. To prevent possible data loss the *StorageClass* should keep a *PV* retained even if a bound *PVC* is deleted.

Adjust the *Job* at /opt/course/10/backup.yaml to use a *PVC* which request 50Mi storage and uses the new *StorageClass*.

Deploy your changes, verify the *Job* completed once and the *PVC* was bound to a newly created *PV*.

 

ℹ️ To re-run a *Job*, delete it and create it again

 

ℹ️ The abbreviation *PV* stands for *PersistentVolume* and *PVC* for *PersistentVolumeClaim*

Course files are under /opt/course/10/
EOF
