#!/bin/bash
cat <<'EOF'
Solution notes — Question 5 | Kustomize configure HPA Autoscaler

Kustomize is a standalone tool to manage K8s Yaml files, but it also comes included with kubectl. The common idea is to have a base set of K8s Yaml and then override or extend it for different overlays, like here done for staging and prod:

base  prod  staging

 

###### **Investigate Base**

Let's investigate the base first for better understanding:

apiVersion: v1

kind: ServiceAccount

metadata:

 name: api-gateway

 namespace: NAMESPACE_REPLACE

---

apiVersion: v1

data:

 horizontal-scaling: "70"

kind: ConfigMap

metadata:

 name: horizontal-scaling-config

 namespace: NAMESPACE_REPLACE

---

apiVersion: apps/v1

kind: Deployment

metadata:

 name: api-gateway

 namespace: NAMESPACE_REPLACE

spec:

 replicas: 1

 selector:

   matchLabels:

     id: api-gateway

 template:

   metadata:

     labels:

       id: api-gateway

   spec:

     containers:

     - image: httpd:2-alpine

       name: httpd

     serviceAccountName: api-gateway

Running kubectl kustomize DIR will build the whole Yaml based on whatever is defined in the kustomization.yaml.

In the case above we did build for the base directory, which produces Yaml that is not expected to be deployed just like that. We can see for example that all resources contain namespace: NAMESPACE_REPLACE entries which won't be possible to apply because *Namespace* names need to be lowercase.

But for debugging it can be useful to build the base Yaml.

 

###### **Investigate Staging**

Now we look at the staging directory:

apiVersion: v1

kind: ServiceAccount

metadata:

 name: api-gateway

 namespace: api-gateway-staging

---

apiVersion: v1

data:

 horizontal-scaling: "60"

kind: ConfigMap

metadata:

 name: horizontal-scaling-config

 namespace: api-gateway-staging

---

apiVersion: apps/v1

kind: Deployment

metadata:

 labels:

   env: staging

 name: api-gateway

 namespace: api-gateway-staging

spec:

 replicas: 1

 selector:

   matchLabels:

     id: api-gateway

 template:

   metadata:

     labels:

       id: api-gateway

   spec:

     containers:

     - image: httpd:2-alpine

       name: httpd

     serviceAccountName: api-gateway

We can see that all resources now have namespace: api-gateway-staging. Also staging seems to change the *ConfigMap* value to horizontal-scaling: "60". And it adds the additional label env: staging to the *Deployment*. The rest is taken from base.

This all happens because of the kustomization.yaml:

\# cka5774:/opt/course/5/api-gateway/staging/kustomization.yaml

apiVersion: kustomize.config.k8s.io/v1beta1

kind: Kustomization

resources:

 - ../base

patches:

 - path: api-gateway.yaml

transformers:

 - |-

   apiVersion: builtin

   kind: NamespaceTransformer

   metadata:

     name: notImportantHere

     namespace: api-gateway-staging

* The resources: section is the directory on which everything will be based on  
* The patches: section specifies Yaml files with alterations or additions applied on the base files  
* The transformers: section in this case sets the *Namespace* for all resources

We should be able to build and deploy the staging Yaml:

serviceaccount/api-gateway unchanged

configmap/horizontal-scaling-config unchanged

deployment.apps/api-gateway unchanged

Actually we see that no changes were performed, because everything is already deployed:

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE

deployment.apps/api-gateway   1/1     1            1           20m

NAME                                  DATA   AGE

configmap/horizontal-scaling-config   1      20m

configmap/kube-root-ca.crt            1      21m

 

###### **Investigate Prod**

Everything said about staging is also true about prod, there are just different values of resources changed. Hence we should also see that there are no changes to be applied:

apiVersion: v1

kind: ServiceAccount

metadata:

 name: api-gateway

 namespace: api-gateway-prod

...

We can see that now *Namespace* api-gateway-prod is being used.

serviceaccount/api-gateway unchanged

configmap/horizontal-scaling-config unchanged

deployment.apps/api-gateway unchanged

And everything seems to be up to date for prod as well.

 

###### **Step 1**

We need to remove the *ConfigMap* from base, staging and prod because staging and prod both reference it as a patch. If we would only remove it from base we would run into an error when trying to build staging for example:

error: no resource matches strategic merge patch "ConfigMap.v1.\[noGrp\]/horizontal-scaling-config.\[noNs\]": no matches for Id ConfigMap.v1.\[noGrp\]/horizontal-scaling-config.\[noNs\]; failed to find unique target for patch ConfigMap.v1.\[noGrp\]/horizontal-scaling-config.\[noNs\]

So we edit files base/api-gateway.yaml, staging/api-gateway.yaml and prod/api-gateway.yaml and remove the *ConfigMap*. Afterwards we should get no errors and Yaml without that *ConfigMap*:

apiVersion: v1

kind: ServiceAccount

metadata:

 name: api-gateway

 namespace: api-gateway-staging

---

apiVersion: apps/v1

kind: Deployment

metadata:

 labels:

   env: staging

 name: api-gateway

 namespace: api-gateway-staging

spec:

 replicas: 1

 selector:

   matchLabels:

     id: api-gateway

 template:

   metadata:

     labels:

       id: api-gateway

   spec:

     containers:

     - image: httpd:2-alpine

       name: httpd

     serviceAccountName: api-gateway

apiVersion: v1

kind: ServiceAccount

metadata:

 name: api-gateway

 namespace: api-gateway-prod

---

apiVersion: apps/v1

kind: Deployment

metadata:

 labels:

   env: prod

 name: api-gateway

 namespace: api-gateway-prod

spec:

 replicas: 1

 selector:

   matchLabels:

     id: api-gateway

 template:

   metadata:

     labels:

       id: api-gateway

   spec:

     containers:

     - image: httpd:2-alpine

       name: httpd

     serviceAccountName: api-gateway

 

###### **Step 2**

We're going to add the requested *HPA* into the base config file:

\# cka5774:/opt/course/5/api-gateway/base/api-gateway.yaml

apiVersion: autoscaling/v2

kind: HorizontalPodAutoscaler

metadata:

 name: api-gateway

spec:

 scaleTargetRef:

   apiVersion: apps/v1

   kind: Deployment

   name: api-gateway

 minReplicas: 2

 maxReplicas: 4

 metrics:

   - type: Resource

     resource:

       name: cpu

       target:

         type: Utilization

         averageUtilization: 50

---

apiVersion: v1

kind: ServiceAccount

metadata:

 name: api-gateway

---

apiVersion: apps/v1

kind: Deployment

metadata:

 name: api-gateway

spec:

 replicas: 1

 selector:

   matchLabels:

     id: api-gateway

 template:

   metadata:

     labels:

       id: api-gateway

   spec:

     serviceAccountName: api-gateway

     containers:

       - image: httpd:2-alpine

         name: httpd

Notice that we don't specify a *Namespace* here as done also for the other resources. The *Namespace* will be set by staging and prod overlays automatically.

 

###### **Step 3**

In prod the *HPA* should have max replicas set to 6 so we add this to the prod patch:

\# cka5774:/opt/course/5/api-gateway/prod/api-gateway.yaml

apiVersion: autoscaling/v2

kind: HorizontalPodAutoscaler

metadata:

 name: api-gateway

spec:

 maxReplicas: 6

---

apiVersion: apps/v1

kind: Deployment

metadata:

 name: api-gateway

 labels:

   env: prod

With that change we should see that staging will have the *HPA* with maxReplicas: 4 from base, whereas prod will have maxReplicas: 6:

kind: HorizontalPodAutoscaler

metadata:

 name: api-gateway

 namespace: api-gateway-staging

spec:

 maxReplicas: 4

kind: HorizontalPodAutoscaler

metadata:

 name: api-gateway

 namespace: api-gateway-prod

spec:

 maxReplicas: 6

 

###### **Step 4**

Finally we apply the changes, first staging:

diff -u -N /tmp/LIVE-3038173353/autoscaling.v2.HorizontalPodAutoscaler.api-gateway-staging.api-gateway /tmp/MERGED-332240272/autoscaling.v2.HorizontalPodAutoscaler.api-gateway-staging.api-gateway

--- /tmp/LIVE-3038173353/autoscaling.v2.HorizontalP
EOF
