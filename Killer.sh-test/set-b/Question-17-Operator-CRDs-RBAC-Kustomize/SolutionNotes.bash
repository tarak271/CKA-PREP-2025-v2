#!/bin/bash
cat <<'EOF'
Solution notes — Question 17 | Operator, CRDs, RBAC, Kustomize

Kustomize is a standalone tool to manage K8s Yaml files, but it also comes included with kubectl. The common idea is to have a base set of K8s Yaml and then override or extend it for different overlays, like done here for prod:

base  prod

 

###### **Investigate Base**

Let's investigate the base first for better understanding:

apiVersion: apiextensions.k8s.io/v1

kind: CustomResourceDefinition

metadata:

 name: classes.education.killer.sh

spec:

 group: education.killer.sh

...

---

apiVersion: apiextensions.k8s.io/v1

kind: CustomResourceDefinition

metadata:

 name: students.education.killer.sh

spec:

 group: education.killer.sh

...

---

apiVersion: v1

kind: ServiceAccount

metadata:

 name: operator

 namespace: NAMESPACE_REPLACE

...

Running kubectl kustomize DIR will build the whole Yaml based on whatever is defined in the kustomization.yaml.

In the case above we did build for the base directory, which produces Yaml that is not expected to be deployed just like that. We can see for example that all resources contain namespace: NAMESPACE_REPLACE entries which won't be possible to apply because *Namespace* names need to be lowercase.

But for debugging it can be useful to build the base Yaml.

 

###### **Investigate Prod**

apiVersion: apiextensions.k8s.io/v1

kind: CustomResourceDefinition

metadata:

 name: classes.education.killer.sh

spec:

 group: education.killer.sh

...

---

apiVersion: apiextensions.k8s.io/v1

kind: CustomResourceDefinition

metadata:

 name: students.education.killer.sh

spec:

 group: education.killer.sh

...

---

apiVersion: v1

kind: ServiceAccount

metadata:

 name: operator

 namespace: operator-prod

...

We can see that all resources now have namespace: operator-prod. Also prod adds the additional label project_id: prod_7768e94e-88da-4744-9135-f1e7fbb96daf to the *Deployment*. The rest is taken from base.

 

###### **Locate Issue**

The instructions tell us to check the logs:

NAME                        READY   STATUS    RESTARTS   AGE

operator-7f4f58d4d9-v6ftw   1/1     Running   0          6m9s

\+ true

\+ kubectl get students

Error from server (Forbidden): students.education.killer.sh is forbidden: User "system:serviceaccount:operator-prod:operator" cannot list resource "students" in API group "education.killer.sh" in the namespace "operator-prod"

\+ kubectl get classes

Error from server (Forbidden): classes.education.killer.sh is forbidden: User "system:serviceaccount:operator-prod:operator" cannot list resource "classes" in API group "education.killer.sh" in the namespace "operator-prod"

\+ sleep 10

\+ true

We can see that the operator tries to list resources students and classes. If we look at the *Deployment* we can see that it simply runs kubectl commands in a loop:

\# kubectl -n operator-prod edit deploy operator

apiVersion: apps/v1

kind: Deployment

metadata:

...

 name: operator

 namespace: operator-prod

spec:

...

 template:

...

   spec:

     containers:

     - command: \["/bin/sh","-c"\]

       args:

         - |

           set -x

           while true; do

             kubectl get students

             kubectl get classes

             sleep 60

           done

...

 

###### **Adjust RBAC**

Now we need to adjust the existing *Role* operator-role. In the Kustomize config directory we find file rbac.yaml which we need to edit. Instead of manually editing the Yaml we could also generate it via command line:

apiVersion: rbac.authorization.k8s.io/v1

kind: Role

metadata:

 creationTimestamp: null

 name: operator-role

 namespace: operator-prod

rules:

- apiGroups:

 - education.killer.sh

 resources:

 - students

 - classes

 verbs:

 - list

Now we copy\&paste it into rbac.yaml:

\# cka6016:/opt/course/17/operator/base/rbac.yaml

apiVersion: rbac.authorization.k8s.io/v1

kind: Role

metadata:

 name: operator-role

 namespace: default

rules:

- apiGroups:

 - education.killer.sh

 resources:

 - students

 - classes

 verbs:

 - list

---

apiVersion: rbac.authorization.k8s.io/v1

kind: RoleBinding

metadata:

 name: operator-rolebinding

 namespace: default

subjects:

 - kind: ServiceAccount

   name: operator

   namespace: default

roleRef:

 kind: Role

 name: operator-role

 apiGroup: rbac.authorization.k8s.io

And we deploy:

customresourcedefinition.apiextensions.k8s.io/classes.education.killer.sh unchanged

customresourcedefinition.apiextensions.k8s.io/students.education.killer.sh unchanged

serviceaccount/operator unchanged

role.rbac.authorization.k8s.io/operator-role configured

rolebinding.rbac.authorization.k8s.io/operator-rolebinding unchanged

deployment.apps/operator unchanged

class.education.killer.sh/advanced unchanged

student.education.killer.sh/student1 unchanged

student.education.killer.sh/student2 unchanged

student.education.killer.sh/student3 unchanged

We can see that only the *Role* was configured, which is what we want. And the logs are not throwing errors any more:

\+ kubectl get students

NAME       AGE

student1   22m

student2   22m

student3   22m

\+ kubectl get classes

NAME       AGE

advanced   20m

 

###### **Create new Student resource**

Finally we need to create a new *Student* resource. Here we can simply copy an existing one in students.yaml:

\# cka6016:/opt/course/17/operator/base/students.yaml

...

apiVersion: education.killer.sh/v1

kind: Student

metadata:

 name: student3

spec:

 name: Carol Williams

 description: A student excelling in container orchestration and management

---

apiVersion: education.killer.sh/v1

kind: Student

metadata:

 name: student4

spec:

 name: Some Name

 description: Some Description

And we deploy:

customresourcedefinition.apiextensions.k8s.io/classes.education.killer.sh unchanged

customresourcedefinition.apiextensions.k8s.io/students.education.killer.sh unchanged

serviceaccount/operator unchanged

role.rbac.authorization.k8s.io/operator-role unchanged

rolebinding.rbac.authorization.k8s.io/operator-rolebinding unchanged

deployment.apps/operator unchanged

class.education.killer.sh/advanced unchanged

student.education.killer.sh/student1 unchanged

student.education.killer.sh/student2 unchanged

student.education.killer.sh/student3 unchanged

student.education.killer.sh/student4 created

NAME       AGE

student1   28m

student2   28m

student3   27m

student4   43s

Only *Student* student4 got created, everything else stayed the same.

# **CKA Tips Kubernetes 1.34**

Passing the CKA is all about being a Kubernetes mechanic. Here’s how to make sure you're ready.

 

## **Knowledge**

**General**

* Study all topics as proposed in the curriculum until you feel comfortable with all  
* Do both test sessions with this CKA Simulator. Understand the solutions and maybe try out other ways to achieve the same thing  
* Be fast and breathe kubectl  
* The majority of tasks in the CKA will also be around creating Kubernetes resources, like it's tested in the CKAD. So preparing a bit for the CKAD can't hurt.  
* Learn and Study the in-browser scenarios on [https://killercoda.com/killer-shell-cka](https://killercoda.com/killer-shell-cka) (and maybe for CKAD [https://killercoda.com/killer-shell-ckad](https://killercoda.com/killer-shell-ckad))  
* Imagine and create your own scenarios to solve

 

**Components**

* Understanding Kubernetes components and being able to fix and investigate clusters: [https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster)  
* Know advanced scheduling: [https://kubernetes.io/docs/concepts/scheduling/kube-scheduler](https://kubernetes.io/docs/concepts/scheduling/kube-scheduler)  
* When you have to fix a component (like kubelet) in one cluster, just check how it's setup on another node in the same or even another cluster. You can copy config files over etc  
* If you like you can look at [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernete
EOF
