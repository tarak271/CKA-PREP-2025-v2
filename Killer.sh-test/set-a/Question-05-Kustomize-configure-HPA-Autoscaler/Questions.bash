#!/bin/bash
# Killer.sh Question 05: Kustomize configure HPA Autoscaler

cat <<'EOF'
Question 5 | Kustomize configure HPA Autoscaler

Solve this question on the local cluster.

Previously the application api-gateway used some external autoscaler which should now be replaced with a *HorizontalPodAutoscaler* (*HPA*). The application has been deployed to *Namespaces* api-gateway-staging and api-gateway-prod like this:

kubectl kustomize /opt/course/5/api-gateway/staging | kubectl apply -f -

kubectl kustomize /opt/course/5/api-gateway/prod | kubectl apply -f -

Using the Kustomize config at /opt/course/5/api-gateway do the following:

1. Remove the *ConfigMap* horizontal-scaling-config completely  
2. Add *HPA* named api-gateway for the *Deployment* api-gateway with min 2 and max 4 replicas. It should scale at 50% average CPU utilisation  
3. In prod the *HPA* should have max 6 replicas  
4. Apply your changes for staging and prod so they're reflected in the cluster

Course files are under /opt/course/5/
EOF
