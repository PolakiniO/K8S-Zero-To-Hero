# Incident Report: Lab 2: Namespace + RBAC authorization failure (`Forbidden`)

**Lab source**: [`LabPack` reference](../../../LabPack/week1/lab2/README.md)

## 1) Detection + impact
- Operations failed with `Forbidden` while attempting namespace-scoped actions.
- Team could not deploy or inspect required objects.

## 2) Investigation timeline (sanitized)
- Checked current identity/context.
- Reviewed Role/RoleBinding and target namespace.
- Validated permissions using `kubectl auth can-i`.

## 3) Root cause + trigger
- Missing or incorrect RBAC binding for the intended subject in the target namespace.

## 4) Fixes
- Applied corrected RoleBinding and ensured subject/namespace alignment.

## 5) Verification + prevention
- `can-i` checks returned expected `yes` for required verbs/resources.
- Added RBAC validation step before running namespace tasks.

---

Template alignment:
- [`incident-scenarios/README.md`](../../../incident-scenarios/README.md)
- [`showcase/deliverable-template.md`](../../deliverable-template.md)
