# Labs Deliverables Index

Use this page to organize proof of work as you complete labs.

## How to use this index for hiring visibility

For each checked item, add a short incident write-up that includes:
- symptom + impact,
- commands/evidence,
- root cause,
- mitigation + permanent fix,
- prevention,
- one-line role relevance (TAM/Support/Platform/Security).

## Week 1 (Core failures)

- [x] Image pull failure RCA
- [x] RBAC authorization failure RCA
- [x] OOM/resource pressure RCA
- [x] Probe misconfiguration RCA
- [x] Secret/Config injection failure RCA

Source: `Labs/K8S-Lab-Week1/README.md`

## Week 2 (Networking/rollout/storage)

- [x] Service selector mismatch RCA
- [x] Failed rolling update + rollback RCA
- [x] PVC pending/storage RCA
- [x] NetworkPolicy deny RCA
- [x] End-to-end incident drill RCA

Source: `Labs/K8S-Lab-Week2/README.md`

## Week 3 (Production pressure)

- [x] Node availability incident RCA
- [x] Memory pressure + eviction RCA
- [x] Certificate trust failure RCA
- [x] CPU exhaustion RCA
- [x] Multi-service chain failure RCA

Source: `Labs/K8S-Lab-Week3/README.md`

## Cloud lab showcase

- [ ] EKS three-tier deployment summary
- [ ] Security findings + attack-path narrative
- [ ] Troubleshooting log (issue → detection → fix)

Source: `docs/eks-anonymized-interview-lab.md`

## Full portfolio incident index

- ✅ Full incident coverage list across Lab 1 through Lab 15 is maintained in:
  - [`showcase/portfolio/all-labs-incident-index.md`](portfolio/all-labs-incident-index.md)
- ✅ Detailed incident reports (detection, timeline, RCA, remediation, prevention) are now documented for each completed lab incident in the same index.

## Priority path (if you only have limited time)

Start with these five deliverables first:

1. Service selector mismatch RCA (Week 2)
2. CrashLoop/Probe or Secret failure RCA (Week 1)
3. Failed rolling update + rollback RCA (Week 2)
4. Multi-service chain failure RCA (Week 3)
5. EKS security findings narrative (cloud lab)

This sequence creates a strong recruiter-ready signal quickly.
