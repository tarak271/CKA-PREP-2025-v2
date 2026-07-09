#!/bin/bash
cat <<'EOF'
Solution notes — Question 10 | PV PVC Dynamic Provisioning

The *StorageClass* should use provider rancher.io/local-path, which is of the project [Local Path Provisioner](https://github.com/rancher/local-path-provisioner). This project works with Dynamic Volume Provisioning, but instead of creating actual volumes it uses local storage on the node where the *Pod* runs, by default at path /opt/local-path-provisioner.

Cloud companies like AWS or GCP provide their own *StorageClasses* and providers, which if used for *PVCs* create *PVs* backed by actual volumes in the cloud account.

 

###### **Create *StorageClass***

First we can have a look at existing ones:

NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE       ...

local-path   rancher.io/local-path   Delete          WaitForFirstConsumer    ...

The local-path is the default one available if the Local Path Provisioner is installed. But we can see it has a reclaimPolicy of Delete. Still we could use this one as template for the one we need to create:

apiVersion: storage.k8s.io/v1

kind: StorageClass

metadata:

 name: local-backup

provisioner: rancher.io/local-path

reclaimPolicy: Retain

volumeBindingMode: WaitForFirstConsumer

We need to use reclaimPolicy: Retain because this will cause the *PV* to not get deleted even after the associated *PVC* is deleted. It's very easy to delete resources in Kubernetes which can lead to quick data loss. Especially in this case where important data, like from a backup, is in play.

storageclass.storage.k8s.io/local-backup created

NAME           PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ...

local-backup   rancher.io/local-path   Retain          WaitForFirstConsumer   ...

local-path     rancher.io/local-path   Delete          WaitForFirstConsumer   ...

This looks like what we want. Now we have the choice between two *StorageClasses*.

 

###### **Check existing *Job***

Let's have a look at the existing *Job*:

\# cka6016:/opt/course/10/backup.yaml

apiVersion: batch/v1

kind: Job

metadata:

 name: backup

 namespace: project-bern

spec:

 backoffLimit: 0

 template:

   spec:

     volumes:

       - name: backup

         emptyDir: {}

     containers:

       - name: bash

         image: bash:5

         command:

           - bash

           - -c

           - |

             set -x

             touch /backup/backup-$(date \+%Y-%m-%d-%H-%M-%S).tar.gz

             sleep 15

         volumeMounts:

           - name: backup

             mountPath: /backup

     restartPolicy: Never

Currently it uses an emptyDir volume which means in only stores data in the temporary filesystem of the *Pod*. This means once the *Pod* is deleted the data is deleted as well.

We could go ahead and create it now to see if everything else works:

job.batch/backup created

NAME               STATUS     COMPLETIONS   DURATION   AGE

job.batch/backup   Complete   1/1           5s         11s

NAME               READY   STATUS      RESTARTS   AGE

pod/backup-pll27   0/1     Completed   0          21s

Looks like it completed without errors.

 

###### **Adjust *Job* template**

For this we first need to create a *PVC* and then use in the *Job* template:

\# cka6016:/opt/course/10/backup.yaml

apiVersion: v1

kind: PersistentVolumeClaim

metadata:

 name: backup-pvc

 namespace: project-bern            \# use same Namespace

spec:

 accessModes:

   - ReadWriteOnce

 resources:

   requests:

     storage: 50Mi                  \# request the required size

 storageClassName: local-backup     \# use the new StorageClass

---

apiVersion: batch/v1

kind: Job

metadata:

 name: backup

 namespace: project-bern

spec:

 backoffLimit: 0

 template:

   spec:

     volumes:

       - name: backup

         persistentVolumeClaim:     \# CHANGE

           claimName: backup-pvc    \# CHANGE

     containers:

       - name: bash

         image: bash:5

         command:

           - bash

           - -c

           - |

             set -x

             touch /backup/backup-$(date \+%Y-%m-%d-%H-%M-%S).tar.gz

             sleep 15

         volumeMounts:

           - name: backup

             mountPath: /backup

     restartPolicy: Never

We first made a backup of the provided file, which is always a good idea. Then we added the new *PVC* and referenced the *PVC* in the *Pod* volumes: section.

 

###### **Deploy changes and verify**

First we delete the existing *Job* because we did create it once before without any changes. And then we deploy:

job.batch "backup" deleted

persistentvolumeclaim/backup-pvc created

job.batch/backup created

Then we should see the *Job* execution created a *Pod* which used the *PVC* which created a *PV*:

NAME               STATUS    COMPLETIONS   DURATION   AGE

job.batch/backup   Running   0/1           13s        13s

NAME               READY   STATUS    RESTARTS   AGE

pod/backup-q7dgx   1/1     Running   0          13s

NAME         STATUS   VOLUME                                     CAPACITY   ...

backup-pvc   Bound    pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a   50Mi       ...

NAME          CAPACITY   ...  RECLAIM POLICY  STATUS  CLAIM                     ...

pvc-dbcce...  50Mi       ...  Retain          Bound   project-bern/backup-pvc   ...

 

###### **Optional investigation**

Because the Local Path Provisioner is used we can actually see the volume represented on the filesystem. And because this cluster only has one node, and we're already on it, we can simply do:

/opt/local-path-provisioner/

/opt/local-path-provisioner/pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a_project-bern_backup-pvc

/opt/local-path-provisioner/pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a_project-bern_backup-pvc/backup-2024-12-30-17-27-51.tar.gz

If we run the *Job* again we should see another backup file:

job.batch "backup" deleted

persistentvolumeclaim/backup-pvc unchanged

job.batch/backup created

NAME               STATUS     COMPLETIONS   DURATION   AGE

job.batch/backup   Complete   1/1           18s        20s

NAME               READY   STATUS      RESTARTS   AGE

pod/backup-jpq2t   0/1     Completed   0          20s

/opt/local-path-provisioner/

/opt/local-path-provisioner/pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a_project-bern_backup-pvc

/opt/local-path-provisioner/pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a_project-bern_backup-pvc/backup-2024-12-30-17-27-51.tar.gz

/opt/local-path-provisioner/pvc-dbccec94-cc31-4e30-b5fe-7cb42a85fe7a_project-bern_backup-pvc/backup-2024-12-30-17-34-26.tar.gz

And if we delete the *PVC* we should still see the *PV* and the files in the volume (filesystem in this case):

ℹ️ Removing the *PVC* and *Job* might affect your scoring for this question, so best create them again after testing deletion

persistentvolumeclaim "backup-pvc" deleted

NAME          CAPACITY   ...  RECLAIM POLICY   STATUS     CLAIM                     ...

pvc-dbcce...  50Mi       ...  Retain           Released   project-bern/backup-pvc   ...

We can no longer see the *PVC*, but the *PV* is in status Released. This is because we set the reclaimPolicy: Retain in the *StorageClass*. Now we could manually export/rescue the data in the volume and afterwards delete the *PV* manually.
EOF
