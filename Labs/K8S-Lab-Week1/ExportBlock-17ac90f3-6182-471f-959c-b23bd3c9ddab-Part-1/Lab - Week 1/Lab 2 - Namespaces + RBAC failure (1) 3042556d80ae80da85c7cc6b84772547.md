# Lab 2 - Namespaces + RBAC failure (1)

Setup namespace and service account

```bash
kubectl create ns development
kubectl -n development create sa dev-sa
```

Terminal Log :

```bash
polakinio@Polakinio:~$ kubectl create ns development
namespace/development created
polakinio@Polakinio:~$ kubectl -n development create sa dev-sa
serviceaccount/dev-sa created
```

Trigger forbidden (no rights yet)

```bash
kubectl auth can-i get pods --as=system:serviceaccount:development:dev-sa -n development
kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
```

Terminal Log :

```bash
polakinio@Polakinio:~$ kubectl auth can-i get pods --as=system:serviceaccount:development:dev-sa -n development
no
polakinio@Polakinio:~$ kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:development:dev-sa" cannot list resource "pods" in API group "" in the namespace "development"
```

Remediate with Role + RoleBinding (pods read-only)

```bash
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: development
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-sa-pod-reader
  namespace: development
subjects:
- kind: ServiceAccount
  name: dev-sa
  namespace: development
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
YAML
```

Terminal Log: 

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ touch lab2-rbac-fix.yaml
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: development
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-sa-pod-reader
  namespace: development
subjects:
  - kind: ServiceAccount
    name: dev-sa
    namespace: development
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Terminal Log: 

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ touch lab2-rbac-fix.yaml
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab2-rbac-fix.yaml
role.rbac.authorization.k8s.io/pod-reader created
rolebinding.rbac.authorization.k8s.io/dev-sa-pod-reader created
```

Validate : 

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl auth can-i list pods --as=system:serviceaccount:development:dev-sa -n development
yes
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
No resources found in development namespace. 
```

What to notice

- can-i is your fast preflight check before you debug for 20 minutes