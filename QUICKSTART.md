# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Kubernetes cluster (minikube, kind, or cloud)
- Helm 3.x installed
- kubectl configured
- ArgoCD installed (optional, but recommended)

### Option 1: Deploy with Helm (Quick & Simple)

```bash
# Deploy to development environment
./deploy.sh -e dev

# Or manually:
helm install telehealth-apps charts/telehealth-apps/ \
  -n telehealth-dev \
  -f environments/values-dev.yaml \
  --create-namespace
```

### Option 2: Deploy with ArgoCD (GitOps Way) ⭐

For detailed setup instructions, see [ArgoCD Manual Setup Guide](examples/argocd-manual-setup.md).

Quick setup with CLI:

```bash
# Add your Git repository to ArgoCD
argocd repo add https://github.com/your-org/telehealth-gitops \
  --username <your-user> \
  --password <your-token>

# Create dev application
argocd app create telehealth-apps-dev \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --dest-namespace telehealth-dev \
  --helm-values-files examples/helm-values-dev.yaml \
  --create-namespace

# Create prod application
argocd app create telehealth-apps-prod \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --dest-namespace telehealth-prod \
  --helm-values-files examples/helm-values-prod.yaml \
  --create-namespace

# Sync applications
argocd app sync telehealth-apps-dev
argocd app sync telehealth-apps-prod
```

### Verify Deployment

```bash
# Check deployments
kubectl get deployments -n telehealth-dev
kubectl get pods -n telehealth-dev
kubectl get services -n telehealth-dev

# Check PostgreSQL
kubectl logs -n telehealth-dev deployment/postgres

# Check Redis
kubectl logs -n telehealth-dev deployment/redis
```

### Access Services

**PostgreSQL:**
```bash
kubectl port-forward -n telehealth-dev svc/postgres 5432:5432
psql -h localhost -U postgres -d telehealth
# Password: changeme123 (from values.yaml)
```

**Redis:**
```bash
kubectl port-forward -n telehealth-dev svc/redis 6379:6379
redis-cli -p 6379 PING
# Should return: PONG
```

## 📁 Repository Structure

```
telehealth-gitops/
├── charts/
│   └── telehealth-apps/              # Single Helm chart for all apps
│       ├── Chart.yaml                # Chart metadata
│       ├── values.yaml               # Default configuration
│       └── templates/                # Kubernetes manifests
│           ├── postgres-*            # PostgreSQL resources
│           ├── redis-*               # Redis resources
│           ├── configmap-dev.yaml    # Dev ConfigMap template
│           └── configmap-prod.yaml   # Prod ConfigMap template
├── examples/
│   ├── helm-values-dev.yaml         # Dev Helm values override
│   ├── helm-values-prod.yaml        # Prod Helm values override
│   └── argocd-manual-setup.md       # Complete ArgoCD setup guide
├── deploy.sh                         # Helper deployment script
├── README.md                         # Full documentation
└── CONTRIBUTING.md                   # Contribution guidelines
```

## ⚙️ Configuration

### Change PostgreSQL Password
Edit `charts/telehealth-apps/values.yaml`:
```yaml
postgresql:
  env:
    POSTGRES_PASSWORD: "your-new-password"
```

Or override per environment in `environments/values-{dev,prod}.yaml`

### Enable Redis Persistence
Edit `charts/telehealth-apps/values.yaml`:
```yaml
redis:
  persistence:
    enabled: true  # Changed from false
    size: 10Gi
```

### Adjust Resource Limits
Edit `environments/values-prod.yaml`:
```yaml
postgresql:
  resources:
    limits:
      memory: "4Gi"   # Increase for production
      cpu: "2000m"
```

## 🔐 Security Notes

1. **Change default passwords** before production use
2. **Use sealed secrets** or external secret management for sensitive data
3. **Enable persistence** for PostgreSQL in production
4. **Use restricted storage classes** (e.g., "fast" for SSD)
5. **Limit resource access** with RBAC and network policies

## 📚 Next Steps

1. **Read the Full Documentation**
   - [README.md](README.md) - Complete reference guide
   - [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute

2. **Set Up with ArgoCD**
   - Read [examples/argocd-manual-setup.md](examples/argocd-manual-setup.md) for detailed instructions
   - Add repository to your ArgoCD instance
   - Create applications for dev and prod environments

3. **Customize Configuration**
   - Use `examples/helm-values-*.yaml` files or ConfigMaps
   - Adjust resource limits, storage, passwords as needed
   - Commit changes to Git

4. **Monitor Deployments**
   - Check ArgoCD UI for sync status
   - Review pod logs and events
   - Test connections to PostgreSQL and Redis

## 🆘 Troubleshooting

### Pods not starting?
```bash
kubectl describe pod -n telehealth-dev <pod-name>
kubectl logs -n telehealth-dev <pod-name>
```

### Helm validation error?
```bash
helm lint charts/telehealth-apps/
```

### Can't connect to database?
```bash
kubectl get service -n telehealth-dev
kubectl port-forward -n telehealth-dev svc/postgres 5432:5432
```

## 📞 Support

For issues or questions, refer to the main [README.md](README.md) or contact your platform team.
