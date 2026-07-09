#!/bin/bash
cat <<'EOF'
Solution notes — Question 6 | Storage, PV, PVC, Pod volume

Find an example from [https://kubernetes.io/docs](https://kubernetes.io/docs) and alter it:

\# cka7968:/home/candidate/6_pv.yaml

kind: PersistentVolume

apiVersion: v1

metadata:

name: safari-pv

spec:

capacity:

 storage: 2Gi

accessModes:

 - ReadWriteOnce

hostPath:

 path: "/Volumes/Data"

ℹ️ Using the hostPath volume type presents many security risks, avoid if possible. Be aware that data stored in the hostPath directory will not be shared across nodes. The data available for a *Pod* depends on which node the *Pod* is scheduled.

Then create it:

persistentvolume/safari-pv created

Next the *PersistentVolumeClaim*:

Find an example from the K8s Docs and alter it:

\# cka7968:/home/candidate/6_pvc.yaml

kind: PersistentVolumeClaim

apiVersion: v1

metadata:

 name: safari-pvc

 namespace: project-t230

spec:

 accessModes:

   - ReadWriteOnce

 resources:

   requests:

    storage: 2Gi

Then create:

persistentvolumeclaim/safari-pvc created

And check that both have the status Bound:

NAME                         CAPACITY  ... STATUS   CLAIM                    ...

persistentvolume/safari-pv   2Gi       ... Bound    project-t230/safari-pvc ...

NAME                               STATUS   VOLUME      CAPACITY ...

persistentvolumeclaim/safari-pvc   Bound    safari-pv   2Gi      ...

Next we create a *Deployment* and mount that volume:

Alter the yaml to mount the volume:

\# cka7968:/home/candidate/6_dep.yaml

apiVersion: apps/v1

kind: Deployment

metadata:

 creationTimestamp: null

 labels:

   app: safari

 name: safari

 namespace: project-t230

spec:

 replicas: 1

 selector:

   matchLabels:

     app: safari

 strategy: {}

 template:

   metadata:

     creationTimestamp: null

     labels:

       app: safari

   spec:

     volumes:                      \# add

     - name: data                    \# add

       persistentVolumeClaim:              \# add

         claimName: safari-pvc                     \# add

     containers:

     - image: httpd:2-alpine

       name: container

       volumeMounts:                  \# add

       - name: data                   \# add

         mountPath: /tmp/safari-data          \# add

deployment.apps/safari created

We can confirm it's mounting correctly:

   Mounts:

     /tmp/safari-data from data (rw)

     /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-xght8 (ro)
EOF
