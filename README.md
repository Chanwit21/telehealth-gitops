# Telehealth Apps - GitOps Repository

GitOps repository for managing Telehealth infrastructure using Helm charts with ArgoCD.

## Overview

This repository contains a single Helm chart (`telehealth-apps`) that manages:
- **PostgreSQL**: Database for telehealth application
- **Redis**: Cache and session store

The repository is designed to be used with your existing ArgoCD instance for continuous deployment and synchronization.

## Repository Structure

```
telehealth-gitops/
├── charts/
│   └── telehealth-apps/          # Main Helm chart
│       ├── Chart.yaml
│       ├── values.yaml           # Default values
│       └── templates/
│           ├── postgres-deployment.yaml
│           ├── postgres-service.yaml
│           ├── postgres-pvc.yaml
│           ├── postgres-secret.yaml
│           ├── redis-deployment.yaml
│           ├── redis-service.yaml
│           ├── redis-pvc.yaml
│           ├── configmap-dev.yaml          # Dev ConfigMap template
│           └── configmap-prod.yaml         # Prod ConfigMap template
├── examples/                     # Examples and configuration
│   ├── helm-values-dev.yaml      # Helm values for dev
│   ├── helm-values-prod.yaml     # Helm values for prod
│   └── argocd-manual-setup.md    # Manual ArgoCD setup guide
├── deploy.sh                     # Helper deployment script
├── README.md
├── QUICKSTART.md
└── CONTRIBUTING.md
```

## Prerequisites

- Kubernetes cluster (1.21+)
- Helm 3.x
- ArgoCD installed in the cluster

## Using with ArgoCD

This Helm chart is designed to work with your existing ArgoCD instance. You have multiple options for managing configurations:

### Option 1: Direct Helm Values (Recommended)
Use Helm inline values or reference the example values files in `examples/`:

```bash
argocd app create telehealth-apps-dev \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --dest-namespace telehealth-dev \
  --helm-set global.environment=development \
  --helm-set postgresql.env.POSTGRES_PASSWORD=your_password
```

### Option 2: ConfigMap for Configuration
Use Kubernetes ConfigMaps to manage environment configurations:

```bash
# Create ConfigMap with environment values
kubectl apply -f examples/configmap-dev.yaml
```

ConfigMaps are located in the `examples/` folder:
- `configmap-dev.yaml` - Development configuration
- `configmap-prod.yaml` - Production configuration

### Option 3: Values Files in Repository
Reference example values files directly:

```bash
argocd app create telehealth-apps-dev \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --helm-values-files examples/helm-values-dev.yaml \
  --dest-namespace telehealth-dev
```

### Complete Manual Setup Guide
For detailed instructions on connecting to your existing ArgoCD, see:
**[ArgoCD Manual Setup Guide](examples/argocd-manual-setup.md)**

This includes:
- Setting up applications via CLI
- Using the ArgoCD UI
- Configuring synchronization policies
- Managing secrets securely
- Troubleshooting common issues

## Configuration

### Default Values (values.yaml)
The base `values.yaml` contains default settings for both PostgreSQL and Redis.

### ConfigMaps (Part of Helm Chart)
The Helm chart includes ConfigMap templates that automatically generate configuration maps based on your environment:
- `templates/configmap-dev.yaml` - Created when `global.environment=development`
- `templates/configmap-prod.yaml` - Created when `global.environment=production`

These ConfigMaps are useful for:
- Externalizing configuration
- Quick reference of current values
- Environment-specific settings visibility

### Environment Configuration Options

You have multiple ways to manage environment-specific configurations:

#### 1. Helm Values Files (in `examples/`)
Use with `-f` flag or in ArgoCD:
- `helm-values-dev.yaml`
- `helm-values-prod.yaml`

#### 2. Inline Helm Arguments
Set values directly via CLI or ArgoCD UI:
```bash
--helm-set global.environment=development
--helm-set postgresql.env.POSTGRES_PASSWORD=mypassword
```

#### 3. ConfigMaps (Automatic)
Automatically created by the Helm chart based on values:
```bash
# After deployment, view the ConfigMap
kubectl get configmap -n telehealth-dev
kubectl describe configmap telehealth-apps-dev-values -n telehealth-dev
```

### Key Configuration Options

#### PostgreSQL
```yaml
postgresql:
  enabled: true                    # Enable/disable PostgreSQL
  image.tag: "16-alpine"           # PostgreSQL version
  replicaCount: 1                  # Number of replicas
  env:
    POSTGRES_DB: telehealth        # Database name
    POSTGRES_USER: postgres        # Admin username
    POSTGRES_PASSWORD: changeme    # Admin password (use secrets in prod!)
  persistence:
    enabled: true                  # Enable persistent storage
    size: 10Gi                      # Volume size
  service.port: 5432               # Service port
  resources:
    requests:                       # Minimum guaranteed resources
      memory: "256Mi"
      cpu: "100m"
    limits:                         # Maximum allowed resources
      memory: "512Mi"
      cpu: "500m"
```

#### Redis
```yaml
redis:
  enabled: true                    # Enable/disable Redis
  image.tag: "7-alpine"            # Redis version
  replicaCount: 1                  # Number of replicas
  persistence:
    enabled: true                  # Enable persistent storage
    size: 5Gi                       # Volume size
  service.port: 6379               # Service port
  resources:
    requests:
      memory: "128Mi"
      cpu: "50m"
    limits:
      memory: "256Mi"
      cpu: "250m"
```

## Managing Secrets

**⚠️ Never commit passwords to version control!**

### Option 1: Use ArgoCD Sealed Secrets
```bash
echo -n "your-secure-password" | kubectl create secret generic postgres-secret \
  --dry-run=client \
  --from-file=password=/dev/stdin \
  -o json | kubeseal -f - > environments/postgres-secret-sealed.yaml
```

### Option 2: Use External Secrets Operator
Configure External Secrets Operator to fetch from your secret management system (AWS Secrets Manager, HashiCorp Vault, etc.)

### Option 3: Use Kustomize with secretGenerator
```bash
kustomize build . | kubectl apply -f -
```

## Monitoring & Troubleshooting

### Check Deployment Status
```bash
kubectl get deployments -n telehealth-dev
kubectl get pods -n telehealth-dev
kubectl get svc -n telehealth-dev
```

### View Logs
```bash
# PostgreSQL logs
kubectl logs -n telehealth-dev deployment/postgres

# Redis logs
kubectl logs -n telehealth-dev deployment/redis
```

### Access Services

**PostgreSQL:**
```bash
kubectl port-forward -n telehealth-dev svc/postgres 5432:5432
psql -h localhost -U postgres -d telehealth
```

**Redis:**
```bash
kubectl port-forward -n telehealth-dev svc/redis 6379:6379
redis-cli -p 6379
```

## Updating the Chart

### Update PostgreSQL Version
Edit `charts/telehealth-apps/values.yaml`:
```yaml
postgresql:
  image:
    tag: "17-alpine"  # Update version
```

Then apply with ArgoCD:
```bash
argocd app sync telehealth-apps-dev
```

### Update Resource Limits
Edit the appropriate values file (`values-dev.yaml` or `values-prod.yaml`) and update the `resources` section.

## Helm Commands Reference

```bash
# Validate chart syntax
helm lint ./charts/telehealth-apps

# Preview generated manifests
helm template telehealth-apps ./charts/telehealth-apps \
  -f examples/helm-values-dev.yaml

# Install/update release with values file
helm upgrade --install telehealth-apps ./charts/telehealth-apps \
  -n telehealth-dev \
  -f examples/helm-values-dev.yaml \
  --create-namespace

# Install/update release with inline values
helm upgrade --install telehealth-apps ./charts/telehealth-apps \
  -n telehealth-dev \
  --set global.environment=development \
  --create-namespace

# Rollback to previous version
helm rollback telehealth-apps 1 -n telehealth-dev

# View release history
helm history telehealth-apps -n telehealth-dev

# Delete release
helm uninstall telehealth-apps -n telehealth-dev
```

## ArgoCD Synchronization

For detailed instructions on setting up ArgoCD with this chart, see the **[ArgoCD Manual Setup Guide](examples/argocd-manual-setup.md)**.

Quick reference:

### Using CLI
```bash
# Create application
argocd app create telehealth-apps-dev \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --helm-values-files examples/helm-values-dev.yaml \
  --dest-namespace telehealth-dev

# Sync application
argocd app sync telehealth-apps-dev

# Enable auto-sync
argocd app set telehealth-apps-dev --sync-policy automated
```

### Manual Sync (Safer for Production)
```bash
# Create without auto-sync
argocd app create telehealth-apps-prod \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --helm-values-files examples/helm-values-prod.yaml \
  --dest-namespace telehealth-prod

# Sync manually when ready
argocd app sync telehealth-apps-prod
```

## Best Practices

1. **Use sealed secrets** or external secret management for passwords
2. **Environment separation**: Always use different values files for dev/prod
3. **Version control**: Pin image tags (never use `latest`)
4. **Resource limits**: Always define requests and limits
5. **Persistence**: Enable for databases, disable for caches (unless needed)
6. **Probes**: Configure liveness and readiness probes for reliability
7. **Monitoring**: Integrate with your monitoring stack (Prometheus, Grafana)

## Contributing

To update the chart:
1. Make changes to `charts/telehealth-apps/`
2. Update `charts/telehealth-apps/Chart.yaml` version
3. Test with `helm lint` and `helm template`
4. Update example files if needed (`examples/configmap-*.yaml`, `examples/helm-values-*.yaml`)
5. Commit and push to your Git repository
6. ArgoCD will automatically detect changes and show "OutOfSync" status
7. Sync manually or enable auto-sync to apply changes

## Support

For issues or questions, please contact the Telehealth Platform Team.
