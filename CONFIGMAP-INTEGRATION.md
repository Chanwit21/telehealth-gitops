# ConfigMap Integration Summary

## Changes Made

### ✅ ConfigMaps Moved to Chart Templates

**From:** `/examples/configmap-dev.yaml` and `/examples/configmap-prod.yaml`  
**To:** `/charts/telehealth-apps/templates/configmap-dev.yaml` and `/charts/telehealth-apps/templates/configmap-prod.yaml`

### What This Means

ConfigMaps are now **part of the Helm chart** and will be **automatically created** during deployment:

```bash
# When you deploy the chart, ConfigMaps are automatically created
helm install telehealth-apps ./charts/telehealth-apps \
  -n telehealth-dev \
  -f examples/helm-values-dev.yaml

# The ConfigMaps will automatically exist
kubectl get configmap -n telehealth-dev
  NAME                              DATA   AGE
  telehealth-apps-dev-values        12     5m
```

### ConfigMap Templates

The ConfigMaps are now **Helm templates** that use your values:

**Dev ConfigMap** (`templates/configmap-dev.yaml`)
- Only created when `global.environment=development`
- Exposes configuration key-value pairs
- Useful for monitoring and auditing

**Prod ConfigMap** (`templates/configmap-prod.yaml`)
- Only created when `global.environment=production`
- Includes additional production settings
- Useful for referencing prod configuration

### Updated Repository Structure

```
charts/telehealth-apps/templates/
├── postgres-deployment.yaml
├── postgres-service.yaml
├── postgres-pvc.yaml
├── postgres-secret.yaml
├── redis-deployment.yaml
├── redis-service.yaml
├── redis-pvc.yaml
├── configmap-dev.yaml          ← NEW (moved from examples)
└── configmap-prod.yaml         ← NEW (moved from examples)

examples/
├── helm-values-dev.yaml
├── helm-values-prod.yaml
└── argocd-manual-setup.md
```

## Benefits

✅ **Automatic Creation** - ConfigMaps are created with every Helm deployment  
✅ **Part of Chart** - Everything needed is in the chart  
✅ **Clean Examples** - Examples folder only has reference files  
✅ **Easier Maintenance** - One place to manage templates  
✅ **Kubernetes Native** - ConfigMaps are standard K8s resources  

## How to Use

### 1. Deploy the Chart
```bash
helm install telehealth-apps ./charts/telehealth-apps \
  -n telehealth-dev \
  -f examples/helm-values-dev.yaml \
  --create-namespace
```

### 2. View the Created ConfigMap
```bash
kubectl get configmap -n telehealth-dev
kubectl describe configmap telehealth-apps-dev-values -n telehealth-dev
```

### 3. Access ConfigMap Data
```bash
# Get specific value
kubectl get configmap telehealth-apps-dev-values -n telehealth-dev \
  -o jsonpath='{.data.postgresql-storage}'

# Get all values
kubectl get configmap telehealth-apps-dev-values -n telehealth-dev \
  -o yaml
```

## With ArgoCD

When deploying via ArgoCD, the ConfigMaps are automatically created:

```bash
argocd app create telehealth-apps-dev \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --helm-values-files examples/helm-values-dev.yaml \
  --dest-namespace telehealth-dev

# After sync, ConfigMap exists
argocd app sync telehealth-apps-dev
kubectl get configmap -n telehealth-dev
```

## ConfigMap Content

The ConfigMaps expose environment settings as key-value pairs:

**Development ConfigMap:**
- `environment: development`
- `postgresql-enabled: true`
- `postgresql-db: telehealth_dev`
- `postgresql-storage: 5Gi`
- `redis-enabled: true`
- And more...

**Production ConfigMap:**
- `environment: production`
- `postgresql-enabled: true`
- `postgresql-db: telehealth`
- `postgresql-storage: 50Gi`
- `postgresql-storage-class: fast`
- `redis-persistence: true`
- And more...

## Monitoring & Auditing

ConfigMaps can be used for:
- **Quick configuration reference** - See current settings
- **Automated monitoring** - Scripts can read ConfigMap
- **Audit trails** - History is tracked in Git
- **Configuration validation** - Verify expected values

```bash
# Monitor ConfigMap changes
kubectl get configmap -n telehealth-dev -w

# Export for auditing
kubectl get configmap telehealth-apps-dev-values -n telehealth-dev -o yaml > config-backup.yaml
```

## Documentation Updated

All documentation has been updated to reflect this change:
- ✅ README.md
- ✅ QUICKSTART.md
- ✅ QUICK-REFERENCE.md
- ✅ CHANGES.md

---

**Status:** ✅ ConfigMaps successfully integrated into Helm chart templates
