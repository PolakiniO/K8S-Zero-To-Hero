# EKS Three-Tier Security Lab (Anonymized Interview Exercise)

> This lab is adapted from a past interview home assignment and intentionally anonymized.
> It contains no company-identifying names, no real account IDs, no real IP addresses, and no unique environment identifiers.

## Objective

Build and validate a production-style three-tier deployment on AWS while intentionally introducing controlled security misconfigurations for risk analysis.

## Anonymization and public-repo safety rules

Use these rules before publishing any update to this lab:

- Never include company names, recruiter/interviewer names, or internal project names.
- Never include real public IPs, real DNS names, real account IDs, real bucket names, or real cluster names.
- Replace all sensitive values with placeholders (for example: `<cluster-name>`, `<region>`, `<bucket-name>`, `<admin-ip-cidr>`).
- Keep only reusable technical logic and troubleshooting methodology.

## Three-tier architecture

### Tier 1 — Application (EKS)
- Public-facing application served through Kubernetes `Service` type `LoadBalancer`.
- Workloads run as Deployments in a dedicated namespace.
- Secrets are injected from Kubernetes `Secret` objects.

### Tier 2 — Database (EC2 + MongoDB)
- MongoDB runs on a dedicated EC2 instance.
- Authentication is enabled, with scoped DB users.
- Database ingress is restricted to the EKS worker-node security group.

### Tier 3 — Storage (S3 backups)
- Periodic `mongodump` backups are archived and uploaded to S3.
- In this lab, bucket readability is intentionally permissive to model a data-exposure risk.

## Build plan (detailed)

### Phase A — Foundation

1. Validate VPC/subnets and tagging for EKS + load balancer compatibility.
2. Create EKS cluster and node group in target subnets.
3. Validate cluster health:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
kubectl get nodes -o wide
kubectl get ns
```

### Phase B — Application deployment

1. Build and push the app image to ECR.
2. Create namespace + Secret with MongoDB URI.
3. Deploy application and service.
4. Validate app readiness and service exposure:

```bash
kubectl -n <app-namespace> get deploy,pods,svc
kubectl -n <app-namespace> describe deploy <app-deployment>
kubectl -n <app-namespace> logs deploy/<app-deployment> --tail=100
```

### Phase C — Database deployment

1. Launch EC2 and install MongoDB.
2. Enable MongoDB auth and create scoped users.
3. Bind network controls via Security Groups:
   - allow TCP/27017 only from EKS node SG,
   - allow SSH/22 only from trusted admin CIDR.
4. Validate connectivity from a temporary in-cluster pod:

```bash
kubectl -n <app-namespace> run netcheck --rm -it --image=busybox -- sh
# from inside pod:
# nc -zv <mongo-private-ip> 27017
```

### Phase D — Backups and IAM validation

1. Create backup script (`mongodump` + archive + upload).
2. Schedule with cron and verify logs/timestamps.
3. Validate IAM identity from compute plane:

```bash
aws sts get-caller-identity
aws s3 ls s3://<bucket-name>/
```

## Troubleshooting log (issue -> detection -> fix)

### 1) MongoDB package/version mismatch
- **Detection**: install process failed with dependency errors.
- **What I checked**: package manager output and OS library compatibility.
- **Fix**: moved to a MongoDB version/repo compatible with the selected AMI family.

### 2) `kubectl` download returned redirect/error payload
- **Detection**: downloaded binary was invalid (XML/error content).
- **What I checked**: endpoint path, region, and version URL.
- **Fix**: used version-specific and region-correct download source.

### 3) App `CrashLoopBackOff` after deployment
- **Detection**: pod restart loop and readiness failures.
- **What I checked**:
  - `kubectl describe pod` events,
  - container logs (`--previous`),
  - Secret key names and URI encoding.
- **Fix**: corrected encoded credentials and aligned env var names expected by the app.

### 4) MongoDB `Unauthorized` while network was reachable
- **Detection**: connectivity succeeded but app auth failed.
- **What I checked**: DB name, user roles, and `authSource` alignment.
- **Fix**: updated role mapping and corrected connection-string parameters.

### 5) DB EC2 landed in public subnet during initial build
- **Detection**: subnet review showed unintended placement.
- **What I checked**: route table exposure and SG ingress scope.
- **Fix**: enforced strict SG controls (DB only from node SG, SSH only from admin CIDR) and removed broad ingress.

## Intentional misconfigurations (for security analysis)

- Over-privileged EC2 IAM role.
- Over-privileged Kubernetes service account (`cluster-admin`).
- Publicly readable backup bucket.
- Broad MongoDB bind address with SG-based restriction.

These are intentionally chained to model realistic multi-layer risk, where small permission issues compound across identity, compute, Kubernetes, and storage.

## Attack-path simulation (high level)

1. Initial foothold in exposed web workload.
2. Privilege expansion in cluster due to excessive RBAC.
3. Cloud pivot using node/instance IAM credentials.
4. Data access/exfiltration through misconfigured storage path.
5. Increased blast radius if privileged compute role is abused.

## Validation checklist (anonymized commands)

```bash
kubectl -n <app-namespace> get pods
kubectl -n <app-namespace> get svc <app-service> -o wide
kubectl auth can-i get nodes --as=system:serviceaccount:<app-namespace>:<service-account>
aws sts get-caller-identity
curl https://<bucket-name>.s3.<region>.amazonaws.com/<backup-object> -o /tmp/backup.tgz
```

## Production-style learning outcomes

- Separate functional validation from security validation.
- Explain incidents with evidence: detection -> investigation -> root cause -> fix -> prevention.
- Present mitigations transparently when rebuild/re-architecture is deferred.

## Dual-use value (learning + recruiter showcase)

- **For learners**: this lab provides an end-to-end cloud scenario that combines deployment, troubleshooting, and security analysis.
- **For recruiters**: this showcases practical EKS + EC2 + S3 implementation skills, structured debugging, and mature risk modeling in a public-safe format.
