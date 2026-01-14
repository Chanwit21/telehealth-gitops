# Quick Reference - ConfigMap & ArgoCD Setup

## Repository Structure Overview

```
telehealth-gitops/
├── charts/telehealth-apps/       ← Single Helm chart (PostgreSQL + Redis)
│   └── templates/
│       ├── postgres-*.yaml       ← PostgreSQL manifests
│       ├── redis-*.yaml          ← Redis manifests
│       ├── configmap-dev.yaml    ← Dev ConfigMap template
│       └── configmap-prod.yaml   ← Prod ConfigMap template
├── examples/                      ← Configuration examples
│   ├── helm-values-*.yaml        ← Helm values approach
│   └── argocd-manual-setup.md    ← Complete setup guide
└── [documentation files]
```

**No separate `/environments` folder** - Keep repository clean, ConfigMaps in chart templates.

## Using ConfigMaps for Configuration

### Automatic ConfigMap Creation
The Helm chart automatically creates ConfigMaps based on your environment:

```bash
# After deployment, view the ConfigMap
kubectl get configmap -n telehealth-dev
kubectl describe configmap telehealth-apps-dev-values -n telehealth-dev

# For production
kubectl get configmap -n telehealth-prod
kubectl describe configmap telehealth-apps-prod-values -n telehealth-prod
```

### ConfigMap Contents
ConfigMaps expose key environment settings:
- `environment` - Dev or Production
- `postgresql-enabled` - Whether PostgreSQL is deployed
- `postgresql-storage` - Storage size
- `redis-enabled` - Whether Redis is deployed
- And other configuration values

### Use Cases
- Quick reference of current deployment configuration
- External monitoring/logging systems can read ConfigMap
- Environment validation and auditing
- Runtime updates (if needed)

## Manual ArgoCD Connection (3 Simple Steps)

### Step 1: Add Repository
```bash
argocd repo add https://github.com/your-org/telehealth-gitops \
  --username <your-github-user> \
  --password <your-github-token>
```

### Step 2: Create Application
```bash
# Development
argocd app create telehealth-apps-dev \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --helm-values-files examples/helm-values-dev.yaml \
  --dest-namespace telehealth-dev \
  --create-namespace

# Production (with manual sync for safety)
argocd app create telehealth-apps-prod \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --helm-values-files examples/helm-values-prod.yaml \
  --dest-namespace telehealth-prod \
  --create-namespace
```

### Step 3: Sync Application
```bash
argocd app sync telehealth-apps-dev
argocd app sync telehealth-apps-prod
```

## Configuration Methods (Choose One)

### Method 1: Helm Values Files (Recommended)
```bash
argocd app create telehealth-apps-dev \
  --helm-values-files examples/helm-values-dev.yaml
```
✅ Tracked in Git | ✅ Easy to version | ✅ Environment separation

### Method 2: Inline Helm Values
```bash
argocd app create telehealth-apps-dev \
  --helm-set global.environment=development \
  --helm-set postgresql.env.POSTGRES_PASSWORD=mypassword
```
✅ Quick setup | ⚠️ Not version controlled

### Method 3: ConfigMaps (Automatic)
ConfigMaps are automatically created by the Helm chart:
```bash
# View automatically created ConfigMap
kubectl describe configmap telehealth-apps-dev-values -n telehealth-dev
```
✅ Kubernetes native | ✅ Auto-created | ✅ Reference values

## Common Commands

### View Application Status
```bash
argocd app get telehealth-apps-dev
```

### Monitor Sync Progress
```bash
argocd app logs telehealth-apps-dev --follow
```

### Manual Sync
```bash
argocd app sync telehealth-apps-dev
```

### Enable Auto-Sync (For Development)
```bash
argocd app set telehealth-apps-dev \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### Disable Auto-Sync (For Production)
```bash
argocd app set telehealth-apps-prod --sync-policy none
```

## Verify Deployment

### Check Helm Release
```bash
helm list -n telehealth-dev
helm status telehealth-apps -n telehealth-dev
```

### Check Kubernetes Resources
```bash
kubectl get deployments,services,pvc -n telehealth-dev
kubectl get pods -n telehealth-dev
```

### Access Services
```bash
# PostgreSQL
kubectl port-forward -n telehealth-dev svc/postgres 5432:5432
psql -h localhost -U postgres

# Redis
kubectl port-forward -n telehealth-dev svc/redis 6379:6379
redis-cli ping
```

## Update Configuration

### Update via ConfigMap
```bash
# Edit ConfigMap
kubectl edit configmap telehealth-apps-dev-values -n telehealth-dev
# Redeploy if needed
argocd app sync telehealth-apps-dev
```

### Update via Git (Recommended)
```bash
# Edit examples/helm-values-dev.yaml
vi examples/helm-values-dev.yaml
git add examples/helm-values-dev.yaml
git commit -m "Update dev PostgreSQL memory limit"
git push
# ArgoCD automatically detects and shows OutOfSync
argocd app sync telehealth-apps-dev
```

## Environment-Specific Values

### Development (`examples/helm-values-dev.yaml`)
- Namespace: `telehealth-dev`
- PostgreSQL Storage: `5Gi`
- Resources: Lower (testing)
- Auto-sync: ✅ Yes (for rapid iteration)

### Production (`examples/helm-values-prod.yaml`)
- Namespace: `telehealth-prod`
- PostgreSQL Storage: `50Gi`
- Resources: Higher (production workloads)
- Auto-sync: ❌ No (manual control)

## Troubleshooting

### Application OutOfSync
```bash
argocd app diff telehealth-apps-dev  # See differences
argocd app sync telehealth-apps-dev   # Apply changes
```

### Pods Not Starting
```bash
kubectl describe pod <pod-name> -n telehealth-dev
kubectl logs <pod-name> -n telehealth-dev
```

### Cannot Connect to PostgreSQL
```bash
kubectl port-forward -n telehealth-dev svc/postgres 5432:5432
# Try connecting in another terminal
psql -h localhost -U postgres -d telehealth
```

## Key Files Reference

| File | Purpose | Use Case |
|------|---------|----------|
| `charts/telehealth-apps/values.yaml` | Default values | Fallback/reference |
| `charts/telehealth-apps/templates/configmap-dev.yaml` | Dev ConfigMap template | Auto-created during deployment |
| `charts/telehealth-apps/templates/configmap-prod.yaml` | Prod ConfigMap template | Auto-created during deployment |
| `examples/helm-values-dev.yaml` | Dev environment | ArgoCD dev app |
| `examples/helm-values-prod.yaml` | Prod environment | ArgoCD prod app |
| `examples/argocd-manual-setup.md` | Complete guide | Detailed instructions |

## More Information

For detailed instructions and advanced configurations, see:
- **[README.md](README.md)** - Complete reference
- **[examples/argocd-manual-setup.md](examples/argocd-manual-setup.md)** - Full ArgoCD setup guide
- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute quick start
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute

---

**Last Updated:** January 15, 2026
