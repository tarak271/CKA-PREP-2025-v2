#!/bin/bash
cat <<'EOF'
Solution notes — Question 2 | MinIO Operator, CRD Config, Helm Install

*Helm Chart*: Kubernetes YAML template-files combined into a single package, *Values* allow customisation

*Helm Release*: Installed instance of a *Chart*

*Helm Values*: Allow to customise the YAML template-files in a *Chart* when creating a *Release*

*Operator*: *Pod* that communicates with the Kubernetes API and might work with CRDs

*CRD*: Custom Resources are extensions of the Kubernetes API

 

###### **Step 1**

First we create the requested *Namespace* minio:

namespace/minio created

 

###### **Step 2**

Now we install the MinIO Helm chart into it and name the release minio-operator:

NAME    URL                  

minio   http://localhost:6000

NAME            CHART VERSION   APP VERSION     DESCRIPTION                    

minio/operator  6.0.4           v6.0.4          A Helm chart for MinIO Operator

NAME: minio-operator

LAST DEPLOYED: Sun Dec 22 17:04:37 2024

NAMESPACE: minio

STATUS: deployed

REVISION: 1

TEST SUITE: None

NAME            NAMESPACE   REVISION  ...  STATUS     CHART           APP VERSION

minio-operator  minio       1         ...  deployed   operator-6.0.4  v6.0.4

NAME                              READY   STATUS    RESTARTS   AGE

minio-operator-7b595f559d-5hrj5   1/1     Running   0          24s

minio-operator-7b595f559d-sl22g   1/1     Running   0          25s

Because we installed the Helm chart there are now some *CRDs* available:

NAME                        CREATED AT

miniojobs.job.min.io        2024-12-22T17:04:38Z

policybindings.sts.min.io   2024-12-22T17:04:38Z

tenants.minio.min.io        2024-12-22T17:04:38Z

Just like we can create a *Pod*, we can now create a *Tenant*, *MinIOJob* or *PolicyBinding*. We can also list all available fields for the *Tenant* *CRD* like this:

Name:         tenants.minio.min.io

Namespace:    

Labels:       app.kubernetes.io/managed-by=Helm

Annotations:  controller-gen.kubebuilder.io/version: v0.15.0

             meta.helm.sh/release-name: minio-operator

             meta.helm.sh/release-namespace: minio

             operator.min.io/version: v6.0.4

API Version:  apiextensions.k8s.io/v1

Kind:         CustomResourceDefinition

Metadata:

 Creation Timestamp:  2024-12-22T17:04:38Z

 Generation:          1

 Resource Version:    15190

 UID:                 3407533d-785c-49df-96f2-c03af9f40749

Spec:

 Conversion:

   Strategy:  None

 Group:       minio.min.io

 Names:

   Kind:       Tenant

...

 

###### **Step 3**

We need to update the Yaml in the file which creates a *Tenant* resource:

apiVersion: minio.min.io/v2

kind: Tenant

metadata:

 name: tenant

 namespace: minio

 labels:

   app: minio

spec:

 features:

   bucketDNS: false

   enableSFTP: true                     \# ADD

 image: quay.io/minio/minio:latest

 pools:

   - servers: 1

     name: pool-0

     volumesPerServer: 0

     volumeClaimTemplate:

       apiVersion: v1

       kind: persistentvolumeclaims

       metadata: { }

       spec:

         accessModes:

           - ReadWriteOnce

         resources:

           requests:

             storage: 10Mi

         storageClassName: standard

       status: { }

 requestAutoCert: true

We can see available fields for features like this:

             Features:

               Properties:

                 Bucket DNS:

                   Type:  boolean

                 Domains:

                   Properties:

                     Console:

                       Type:  string

                     Minio:

                       Items:

                         Type:  string

                       Type:    array

                   Type:        object

                 Enable SFTP:

                   Type:  boolean

               Type:      object

             Image:

               Type:  string

             Image Pull Policy:

               Type:  string

             Image Pull Secret:

 

###### **Step 4**

Finally we can create the *Tenant* resource:

tenant.minio.min.io/tenant created

NAME     STATE                      HEALTH   AGE

tenant   empty tenant credentials            21s

In this scenario we installed an operator using Helm and created a *CRD* with which that operator works. This is a common pattern in Kubernetes.
EOF
