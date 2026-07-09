#!/bin/bash
cat <<'EOF'
Solution notes — Question 3 | Scale down StatefulSet

If we check the *Pods* we see two replicas:

o3db-0                                  1/1     Running   0          6d19h

o3db-1                                  1/1     Running   0          6d19h

From their name it looks like these are managed by a *StatefulSet*. But if we're unsure we could also check for the most common resources which manage *Pods*:

statefulset.apps/o3db   2/2     6d19h

Confirmed, we have to work with a *StatefulSet*. We could also look at the *Pod* labels to find this out:

o3db-0                                  1/1     Running   0          6d19h   app=nginx,apps.kubernetes.io/pod-index=0,controller-revision-hash=o3db-5fbd4bb9cc,statefulset.kubernetes.io/pod-name=o3db-0

o3db-1                                  1/1     Running   0          6d19h   app=nginx,apps.kubernetes.io/pod-index=1,controller-revision-hash=o3db-5fbd4bb9cc,statefulset.kubernetes.io/pod-name=o3db-1

To fulfil the task we simply run:

statefulset.apps/o3db scaled

NAME   READY   AGE

o3db   1/1     6d19h

The Project H800 management is happy again.
EOF
