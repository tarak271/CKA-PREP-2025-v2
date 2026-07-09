#!/bin/bash
cat <<'EOF'
Solution notes — Question 16 | Namespaces and Api Resources

###### **Namespace and Namespaces Resources**

We can get a list of all resources:

k api-resources      \# shows all

k api-resources -h   \# a bit of help is always good

So we write them into the requested location:

Which results in the file:

\# cka3200:/opt/course/16/resources.txt

bindings

configmaps

endpoints

events

limitranges

persistentvolumeclaims

pods

podtemplates

replicationcontrollers

resourcequotas

secrets

serviceaccounts

services

controllerrevisions.apps

daemonsets.apps

deployments.apps

replicasets.apps

statefulsets.apps

localsubjectaccessreviews.authorization.k8s.io

horizontalpodautoscalers.autoscaling

cronjobs.batch

jobs.batch

leases.coordination.k8s.io

endpointslices.discovery.k8s.io

events.events.k8s.io

ingresses.networking.k8s.io

networkpolicies.networking.k8s.io

poddisruptionbudgets.policy

rolebindings.rbac.authorization.k8s.io

roles.rbac.authorization.k8s.io

csistoragecapacities.storage.k8s.io

 

###### **Namespace with most Roles**

No resources found in project-jinan namespace.

0

300

2

10

No resources found in project-toronto namespace.

0

Finally we write the name and amount into the file:

\# cka3200:/opt/course/16/crowded-namespace.txt

project-miami with 300 roles
EOF
