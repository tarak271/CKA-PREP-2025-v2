#!/bin/bash
cat <<'EOF'
Solution notes — Question 13 | Multi Containers and Pod shared Volume

First we create the *Pod* template:

And add the other containers and the commands they should execute:

\# cka3200:/home/candidate/13.yaml

apiVersion: v1

kind: Pod

metadata:

 creationTimestamp: null

 labels:

   run: multi-container-playground

 name: multi-container-playground

spec:

 containers:

 - image: nginx:1-alpine

   name: c1                                                                      \# change

   resources: {}

   env:                                                                          \# add

   - name: MY_NODE_NAME                                                          \# add

     valueFrom:                                                                  \# add

       fieldRef:                                                                 \# add

         fieldPath: spec.nodeName                                                \# add

   volumeMounts:                                                                 \# add

   - name: vol                                                                   \# add

     mountPath: /vol                                                             \# add

 - image: busybox:1                                                              \# add

   name: c2                                                                      \# add

   command: \["sh", "-c", "while true; do date \>\> /vol/date.log; sleep 1; done"\]  \# add

   volumeMounts:                                                                 \# add

   - name: vol                                                                   \# add

     mountPath: /vol                                                             \# add

 - image: busybox:1                                                              \# add

   name: c3                                                                      \# add

   command: \["sh", "-c", "tail -f /vol/date.log"\]                                \# add

   volumeMounts:                                                                 \# add

   - name: vol                                                                   \# add

     mountPath: /vol                                                             \# add

 dnsPolicy: ClusterFirst

 restartPolicy: Always

 volumes:                                                                        \# add

   - name: vol                                                                   \# add

     emptyDir: {}                                                                \# add

status: {}

Well, there was a lot requested here\! We check if everything is good with the *Pod*:

pod/multi-container-playground created

NAME                         READY   STATUS    RESTARTS   AGE

multi-container-playground   3/3     Running   0          47s

Not a bad start. Now we check if container c1 has the requested node name as env variable:

MY_NODE_NAME=cka3200

And finally we check the logging, which means that c2 correctly writes and c3 correctly reads and outputs to stdout:

Tue Nov  5 13:41:33 UTC 2024

Tue Nov  5 13:41:34 UTC 2024

Tue Nov  5 13:41:35 UTC 2024

Tue Nov  5 13:41:36 UTC 2024

Tue Nov  5 13:41:37 UTC 2024

Tue Nov  5 13:41:38 UTC 2024
EOF
