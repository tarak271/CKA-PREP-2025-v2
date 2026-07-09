#!/bin/bash
cat <<'EOF'
Solution notes — Question 4 | Find Pods first to be terminated

When available cpu or memory resources on the nodes reach their limit, Kubernetes will look for *Pods* that are using more resources than they requested. These will be the first candidates for termination. If some *Pods* containers have no resource requests/limits set, then by default those are considered to use more than requested. Kubernetes assigns Quality of Service classes to *Pods* based on the defined resources and limits.

Hence we should look for *Pods* without resource requests defined, we can do this with a manual approach:

Or we do something like:

k -n project-c13 describe pod | grep -A 3 -E 'Requests|^Name:'

We see that the *Pods* of *Deployment* c13-3cc-runner-heavy don't have any resource requests specified. Hence our answer would be:

\# /opt/course/4/pods-terminated-first.txt

c13-3cc-runner-heavy-65588d7d6-djtv9map

c13-3cc-runner-heavy-65588d7d6-v8kf5map

c13-3cc-runner-heavy-65588d7d6-wwpb4map

 

###### **Automatic way**

Not necessary and probably too slow for this task, but to automate this process you could use jsonpath:

c13-2x3-api-c848b775d-7nggw{"requests":{"cpu":"50m","memory":"20Mi"}}

c13-2x3-api-c848b775d-qrrlp{"requests":{"cpu":"50m","memory":"20Mi"}}

c13-2x3-api-c848b775d-qtrs7{"requests":{"cpu":"50m","memory":"20Mi"}}

c13-2x3-web-6989fb8dc6-4nc9z{"requests":{"cpu":"50m","memory":"10Mi"}}

c13-2x3-web-6989fb8dc6-7xfdx{"requests":{"cpu":"50m","memory":"10Mi"}}

c13-2x3-web-6989fb8dc6-98pr6{"requests":{"cpu":"50m","memory":"10Mi"}}

c13-2x3-web-6989fb8dc6-9zpkj{"requests":{"cpu":"50m","memory":"10Mi"}}

c13-2x3-web-6989fb8dc6-j2mgb{"requests":{"cpu":"50m","memory":"10Mi"}}

c13-2x3-web-6989fb8dc6-jcwk9{"requests":{"cpu":"50m","memory":"10Mi"}}

c13-3cc-data-96d47bf85-dc8d4{"requests":{"cpu":"30m","memory":"10Mi"}}

c13-3cc-data-96d47bf85-f9gd2{"requests":{"cpu":"30m","memory":"10Mi"}}

c13-3cc-data-96d47bf85-fd9lc{"requests":{"cpu":"30m","memory":"10Mi"}}

c13-3cc-runner-heavy-8687d66dbb-gnxjh{}

c13-3cc-runner-heavy-8687d66dbb-przdh{}

c13-3cc-runner-heavy-8687d66dbb-wqwfz{}

c13-3cc-web-767b98dd48-5b45q{"requests":{"cpu":"50m","memory":"10Mi"}}

c13-3cc-web-767b98dd48-5vldf{"requests":{"cpu":"50m","memory":"10Mi"}}

c13-3cc-web-767b98dd48-dd7mc{"requests":{"cpu":"50m","memory":"10Mi"}}

c13-3cc-web-767b98dd48-pb67p{"requests":{"cpu":"50m","memory":"10Mi"}}

This lists all *Pod* names and their requests/limits, hence we see the three *Pods* without those defined.

Or we look for the Quality of Service classes:

c13-2x3-api-c848b775d-7nggw Burstable

c13-2x3-api-c848b775d-qrrlp Burstable

c13-2x3-api-c848b775d-qtrs7 Burstable

c13-2x3-web-6989fb8dc6-4nc9z Burstable

c13-2x3-web-6989fb8dc6-7xfdx Burstable

c13-2x3-web-6989fb8dc6-98pr6 Burstable

c13-2x3-web-6989fb8dc6-9zpkj Burstable

c13-2x3-web-6989fb8dc6-j2mgb Burstable

c13-2x3-web-6989fb8dc6-jcwk9 Burstable

c13-3cc-data-96d47bf85-dc8d4 Burstable

c13-3cc-data-96d47bf85-f9gd2 Burstable

c13-3cc-data-96d47bf85-fd9lc Burstable

c13-3cc-runner-heavy-8687d66dbb-gnxjh BestEffort

c13-3cc-runner-heavy-8687d66dbb-przdh BestEffort

c13-3cc-runner-heavy-8687d66dbb-wqwfz BestEffort

c13-3cc-web-767b98dd48-5b45q Burstable

c13-3cc-web-767b98dd48-5vldf Burstable

c13-3cc-web-767b98dd48-dd7mc Burstable

c13-3cc-web-767b98dd48-pb67p Burstable

Here we see three with BestEffort, which *Pods* get that don't have any memory or cpu limits or requests defined.

A good practice is to always set resource requests and limits. If you don't know the values your containers should have you can find this out using metric tools like Prometheus. You can also use kubectl top pod or even kubectl exec into the container and use top and similar tools.
EOF
