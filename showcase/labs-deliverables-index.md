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

- [ ] Image pull failure RCA
- [ ] RBAC authorization failure RCA
- [ ] OOM/resource pressure RCA
- [ ] Probe misconfiguration RCA
- [ ] Secret/Config injection failure RCA

Source: `Labs/K8S-Lab-Week1/README.md`

## Week 2 (Networking/rollout/storage)

- [ ] Service selector mismatch RCA
- [ ] Failed rolling update + rollback RCA
- [ ] PVC pending/storage RCA
- [ ] NetworkPolicy deny RCA
- [ ] End-to-end incident drill RCA

Source: `Labs/K8S-Lab-Week2/README.md`

## Week 3 (Production pressure)

- [ ] Node availability incident RCA
- [ ] Memory pressure + eviction RCA
- [ ] Certificate trust failure RCA
- [ ] CPU exhaustion RCA
- [ ] Multi-service chain failure RCA

Source: `Labs/K8S-Lab-Week3/README.md`

## Cloud lab showcase

- [ ] EKS three-tier deployment summary
- [ ] Security findings + attack-path narrative
- [ ] Troubleshooting log (issue → detection → fix)

Source: `docs/eks-anonymized-interview-lab.md`

## Priority path (if you only have limited time)

Start with these five deliverables first:

1. Service selector mismatch RCA (Week 2)
2. CrashLoop/Probe or Secret failure RCA (Week 1)
3. Failed rolling update + rollback RCA (Week 2)
4. Multi-service chain failure RCA (Week 3)
5. EKS security findings narrative (cloud lab)

This sequence creates a strong recruiter-ready signal quickly.
