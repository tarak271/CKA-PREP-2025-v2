#!/bin/bash
cat <<'EOF'
Solution notes — Question 10 | RBAC ServiceAccount Role RoleBinding

###### **Let's talk a little about RBAC resources**

A *ClusterRole*|*Role* defines a set of permissions and **where it is available**, in the whole cluster or just a single *Namespace*.

A *ClusterRoleBinding*|*RoleBinding* connects a set of permissions with an account and defines **where it is applied**, in the whole cluster or just a single *Namespace*.

Because of this there are 4 different RBAC combinations and 3 valid ones:

1. *Role* \+ *RoleBinding* (available in single *Namespace*, applied in single *Namespace*)  
2. *ClusterRole* \+ *ClusterRoleBinding* (available cluster-wide, applied cluster-wide)  
3. *ClusterRole* \+ *RoleBinding* (available cluster-wide, applied in single *Namespace*)  
4. *Role* \+ *ClusterRoleBinding* (**NOT POSSIBLE:** available in single *Namespace*, applied cluster-wide)

###### **To the solution**

We first create the *ServiceAccount*:

serviceaccount/processor created

For the *Role* we can first view examples:

k -n project-hamster create role -h

So we execute:

role.rbac.authorization.k8s.io/processor created

Which will create a *Role* like:

\# kubectl -n project-hamster create role processor --verb=create --resource=secret --resource=configmap

apiVersion: rbac.authorization.k8s.io/v1

kind: Role

metadata:

 name: processor

 namespace: project-hamster

rules:

- apiGroups:

 - ""

 resources:

 - secrets

 - configmaps

 verbs:

 - create

Now we bind the *Role* to the *ServiceAccount*, and for this we can also view examples:

k -n project-hamster create rolebinding -h \# examples

So we create it:

rolebinding.rbac.authorization.k8s.io/processor created

This will create a *RoleBinding* like:

\# kubectl -n project-hamster create rolebinding processor --role processor --serviceaccount project-hamster:processor

apiVersion: rbac.authorization.k8s.io/v1

kind: RoleBinding

metadata:

 name: processor

 namespace: project-hamster

roleRef:

 apiGroup: rbac.authorization.k8s.io

 kind: Role

 name: processor

subjects:

- kind: ServiceAccount

 name: processor

 namespace: project-hamster

To test our RBAC setup we can use kubectl auth can-i:

k auth can-i -h \# examples

Like this:

yes

yes

no

no

no

Done.
EOF
