# Week 3 Labs: Advanced Production Thinking

> Objective: Move from Kubernetes user to Kubernetes operator mindset.

## Lab 11 — Node Failure Simulation
- Drain a node (or simulate unavailability in local cluster).
- Observe pod eviction/rescheduling behavior.
- Document disruption duration and recovery.

## Lab 12 — Certificate / TLS Incident
- Simulate certificate issue in a safe lab.
- Observe API or workload trust failures.
- Recover cert chain and validate trust path.

## Lab 13 — Cluster Resource Exhaustion
- Generate sustained CPU/memory pressure.
- Observe scheduling failures and evictions.
- Add requests/limits and discuss capacity planning outcomes.

## Lab 14 — Multi-service Dependency Failure
- Build simple frontend -> API -> data chain.
- Break one dependency and trace impact.
- Use evidence to isolate root cause quickly.

## Final Drill — Explain Your Debug Process Out Loud
Prompt: **"Walk me through debugging a failing Kubernetes deployment."**

Include:
1. First 3 commands you run
2. How you narrow blast radius
3. How you decide rollback vs fix-forward
4. How you prevent recurrence
