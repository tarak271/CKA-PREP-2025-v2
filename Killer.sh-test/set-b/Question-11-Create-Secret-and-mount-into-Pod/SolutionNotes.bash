#!/bin/bash
cat <<'EOF'
Solution notes — Question 11 | Create Secret and mount into Pod

First we create the *Namespace*:

namespace/secret created

 

###### **Secret 1**

To create the existing *Secret* we need to adjust the *Namespace* for it:

\# cka2560:/home/candidate/11_secret1.yaml

apiVersion: v1

data:

 halt: IyEgL2Jpbi9zaAo...

kind: Secret

metadata:

 creationTimestamp: null

 name: secret1

 namespace: secret      \# UPDATE

secret/secret1 created

 

###### **Secret 2**

Next we create the second *Secret*:

secret/secret2 created

 

###### **Pod**

Now we create the *Pod* template:

Then make the necessary changes:

\# cka2560:/home/candidate/11.yaml

apiVersion: v1

kind: Pod

metadata:

 creationTimestamp: null

 labels:

   run: secret-pod

 name: secret-pod

 namespace: secret                 \# important if not automatically added

spec:

 containers:

 - args:

   - sh

   - -c

   - sleep 1d

   image: busybox:1

   name: secret-pod

   resources: {}

   env:                  \# add

   - name: APP_USER            \# add

     valueFrom:              \# add

       secretKeyRef:           \# add

         name: secret2          \# add

         key: user            \# add

   - name: APP_PASS            \# add

     valueFrom:              \# add

       secretKeyRef:           \# add

         name: secret2          \# add

         key: pass            \# add

   volumeMounts:             \# add

   - name: secret1            \# add

     mountPath: /tmp/secret1       \# add

     readOnly: true            \# add

 dnsPolicy: ClusterFirst

 restartPolicy: Always

 volumes:                 \# add

 - name: secret1             \# add

   secret:                \# add

     secretName: secret1         \# add

status: {}

And execute:

pod/secret-pod created

Finally we verify:

APP_PASS=1234

APP_USER=user1

/tmp/secret1

/tmp/secret1/..data

/tmp/secret1/halt

/tmp/secret1/..2019_12_08_12_15_39.463036797

/tmp/secret1/..2019_12_08_12_15_39.463036797/halt

\#\! /bin/sh

\#\#\# BEGIN INIT INFO

\# Provides:          halt

\# Required-Start:

\# Required-Stop:

\# Default-Start:

\# Default-Stop:      0

\# Short-Description: Execute the halt command.

\# Description:

...
EOF
