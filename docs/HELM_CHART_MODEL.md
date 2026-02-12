# Helm Chart Model (AKS Bravo / Dev)

This repo includes a generic Helm chart template copied from the patterns used in `solver-sandbox/deploy/chart`, then made reusable.

Template location:

- `templates/helm/generic-app/`

## What This Model Supports

- A single app workload (Deployment by default, StatefulSet when `debug: true` for stable pod names)
- Optional Kafka (KRaft)
  - Kafka as a sidecar (`kafka.sidecar: true`)
  - Kafka as a separate StatefulSet + Service (`kafka.sidecar: false`)
- AKS scheduling knobs in values (node affinity + tolerations), matching the “bravo” style dedicated node pool pattern

## How To Use In Another Repo

1. Copy `templates/helm/generic-app/` into your service repo as `deploy/chart/`.
2. Update `deploy/chart/Chart.yaml`:
   - `name`
   - `description`
   - `appVersion`
3. Create an environment values file (for bravo/dev, start from):
   - `templates/helm/generic-app/examples/values-aks-bravo.yaml`
4. Deploy (example):
   - `helm upgrade --install <release> ./deploy/chart -f deploy/values-aks.yaml -n <namespace> --create-namespace`

## Bravo/Dev AKS Example

Example values file:

- `templates/helm/generic-app/examples/values-aks-bravo.yaml`

It demonstrates:

- Node affinity for a dedicated agentpool (example: `d4asv5` / `Standard_D4as_v5`)
- Toleration for a taint like `dedicated=<service>:NoSchedule`
- `automountServiceAccountToken: false` (common Kyverno policy)
- Kafka sidecar mode for a self-contained dev deploy

