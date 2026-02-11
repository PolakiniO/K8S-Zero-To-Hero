# kubectl Cheat Sheet (Zero to Hero)

## Context & Namespace
```bash
kubectl config get-contexts
kubectl config use-context <context>
kubectl config set-context --current --namespace=<ns>
kubectl get ns
```

## Apply, Get, Describe, Delete
```bash
kubectl apply -f <file-or-dir>
kubectl get pods -A
kubectl get deploy,svc,po -n <ns>
kubectl describe pod <pod> -n <ns>
kubectl delete -f <file>
```

## Logs & Exec
```bash
kubectl logs <pod> -n <ns>
kubectl logs -f <pod> -c <container> -n <ns>
kubectl exec -it <pod> -n <ns> -- sh
kubectl cp ./local.txt <ns>/<pod>:/tmp/remote.txt
```

## Debugging Events & Status
```bash
kubectl get events -A --sort-by=.metadata.creationTimestamp
kubectl get pod <pod> -n <ns> -o yaml
kubectl rollout status deployment/<name> -n <ns>
kubectl rollout undo deployment/<name> -n <ns>
```

## Scaling & Updates
```bash
kubectl scale deployment/<name> --replicas=5 -n <ns>
kubectl set image deployment/<name> <container>=nginx:1.27 -n <ns>
kubectl rollout history deployment/<name> -n <ns>
```

## Resources & Capacity
```bash
kubectl top nodes
kubectl top pods -A
kubectl describe node <node-name>
```

## Services & Network
```bash
kubectl get svc -A
kubectl port-forward svc/<service-name> 8080:80 -n <ns>
kubectl run netshoot --rm -it --image=nicolaka/netshoot -- sh
```

## Must-know Troubleshooting Sequence
1. `kubectl get pods -A`
2. `kubectl describe pod <pod> -n <ns>`
3. `kubectl logs <pod> -n <ns>`
4. `kubectl get events -A --sort-by=.metadata.creationTimestamp`
5. `kubectl exec -it <pod> -n <ns> -- sh`
