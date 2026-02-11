# Lab 2 - Namespaces + RBAC Failure

## Tasks

1. Create namespace `development` and service account `dev-sa`.
2. Reproduce forbidden behavior.
3. Fix with Role + RoleBinding.
4. Validate with `kubectl auth can-i`.

## Validation Commands

```bash
kubectl auth can-i get pods --as=system:serviceaccount:development:dev-sa -n development
kubectl auth can-i list pods --as=system:serviceaccount:development:dev-sa -n development
kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
```

## Step 0 - clean slate

```bash
kubectl delete rolebinding dev-sa-pod-reader -n development --ignore-not-found
kubectl delete role pod-reader -n development --ignore-not-found
kubectl delete sa dev-sa -n development --ignore-not-found
kubectl delete ns development --ignore-not-found
```

Terminal log:

```bash
TODO: No clean-slate command/output was captured in the Notion export for Lab 2.
```

## Step 1 - Setup namespace and service account

```bash
kubectl create ns development
kubectl -n development create sa dev-sa
```

Terminal log:

```bash
polakinio@Polakinio:~$ kubectl create ns development
namespace/development created
polakinio@Polakinio:~$ kubectl -n development create sa dev-sa
serviceaccount/dev-sa created
```

## Step 2 - Trigger forbidden

```bash
kubectl auth can-i get pods --as=system:serviceaccount:development:dev-sa -n development
kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
```

Terminal log:

```bash
polakinio@Polakinio:~$ kubectl auth can-i get pods --as=system:serviceaccount:development:dev-sa -n development
no
polakinio@Polakinio:~$ kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:development:dev-sa" cannot list resource "pods" in API group "" in the namespace "development"
```

## Step 3 - Apply Role + RoleBinding fix

```bash
kubectl apply -f lab2-rbac-fix.yaml
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ touch lab2-rbac-fix.yaml
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl apply -f lab2-rbac-fix.yaml
role.rbac.authorization.k8s.io/pod-reader created
rolebinding.rbac.authorization.k8s.io/dev-sa-pod-reader created
```

## Step 4 - Validate authorization

```bash
kubectl auth can-i list pods --as=system:serviceaccount:development:dev-sa -n development
kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
```

Terminal log:

```bash
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl auth can-i list pods --as=system:serviceaccount:development:dev-sa -n development
yes
polakinio@Polakinio:~/Projects/k8s/week1$ kubectl get pods --as=system:serviceaccount:development:dev-sa -n development
No resources found in development namespace.
```

## Reflection

- Failure symptom: `Forbidden` error when `dev-sa` tried listing pods.
- First command used and why: `kubectl auth can-i ...` to quickly verify RBAC permissions.
- Root cause: `dev-sa` had no Role/RoleBinding granting pod read permissions.
- Fix: Bind `dev-sa` to Role `pod-reader` in `development` namespace.
- Prevention step: Use `kubectl auth can-i` as preflight when validating least-privilege access.
