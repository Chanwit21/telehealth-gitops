# Manual ArgoCD Setup Guide

This guide shows how to manually connect this Helm chart repository to your existing ArgoCD instance.

## Prerequisites

- ArgoCD is installed and accessible
- This repository is pushed to Git
- ArgoCD has access to your Git repository

## Method 1: Using ArgoCD CLI

### 1. Add Git Repository to ArgoCD
```bash
argocd repo add https://github.com/your-org/telehealth-gitops \
  --username <github-user> \
  --password <github-token> \
  --name telehealth-gitops
```

### 2. Create Application for Development
```bash
argocd app create telehealth-apps-dev \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace telehealth-dev \
  --helm-set global.environment=development \
  --helm-set global.namespace=telehealth-dev \
  --helm-set postgresql.env.POSTGRES_PASSWORD=dev_password_change_me \
  --create-namespace
```

### 3. Create Application for Production
```bash
argocd app create telehealth-apps-prod \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace telehealth-prod \
  --helm-set global.environment=production \
  --helm-set global.namespace=telehealth-prod \
  --helm-set postgresql.persistence.size=50Gi \
  --helm-set redis.persistence.enabled=true \
  --create-namespace
```

### 4. Sync Applications
```bash
# Manual sync
argocd app sync telehealth-apps-dev
argocd app sync telehealth-apps-prod

# Or enable auto-sync
argocd app set telehealth-apps-dev --sync-policy automated --auto-prune --self-heal
argocd app set telehealth-apps-prod --sync-policy automated --auto-prune --self-heal
```

### 5. Monitor Status
```bash
argocd app get telehealth-apps-dev
argocd app get telehealth-apps-prod
```

## Method 2: Using ArgoCD UI

### 1. Login to ArgoCD
- Navigate to your ArgoCD UI
- Login with your credentials

### 2. Click "New App" Button

### 3. Fill in the Application Details

**Development:**
- Application Name: `telehealth-apps-dev`
- Project: `default` (or your project)
- Sync Policy: `Manual` or `Automated` (your choice)

**Source:**
- Repository URL: `https://github.com/your-org/telehealth-gitops`
- Revision: `main`
- Path: `charts/telehealth-apps`

**Destination:**
- Cluster: `https://kubernetes.default.svc` (in-cluster)
- Namespace: `telehealth-dev`

**Helm Settings:**
Click "Helm" in the source section and add values:
```yaml
global:
  environment: development
  namespace: telehealth-dev
postgresql:
  env:
    POSTGRES_PASSWORD: dev_password_change_me
```

### 4. Create the Application

Click "Create" to create the application.

### 5. Repeat for Production

Create another application with similar settings but:
- Name: `telehealth-apps-prod`
- Namespace: `telehealth-prod`
- Helm values for production

## Method 3: Using ConfigMap Values

Instead of inline Helm values, you can use ConfigMaps:

### 1. Create ConfigMap with Values
```bash
kubectl apply -f examples/configmap-dev.yaml
```

### 2. Reference in ArgoCD

You can still use the CLI or UI, but store the values in ConfigMap for easier management.

## Using Helm Values Files

If you prefer to manage values in files:

### 1. Store Values in Git
Keep your values files in the repository (in `examples/` folder):
- `helm-values-dev.yaml`
- `helm-values-prod.yaml`

### 2. Reference in ArgoCD

**Using CLI:**
```bash
argocd app create telehealth-apps-dev \
  --repo https://github.com/your-org/telehealth-gitops \
  --path charts/telehealth-apps \
  --helm-values-files examples/helm-values-dev.yaml \
  --dest-namespace telehealth-dev
```

**Using UI:**
In the Helm section, you can specify the values file path.

## Synchronization Options

### Manual Sync (Safer for Production)
```bash
argocd app set telehealth-apps-prod --sync-policy none
```
Then manually sync when ready:
```bash
argocd app sync telehealth-apps-prod
```

### Automatic Sync with Safety
```bash
argocd app set telehealth-apps-dev \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

## Managing Secrets

### Option 1: Use ArgoCD Sealed Secrets

1. Install Sealed Secrets controller
2. Create sealed secrets for sensitive values
3. Reference in application

### Option 2: External Secrets Operator

1. Install External Secrets Operator
2. Configure SecretStore pointing to your secret management system
3. Reference in Helm values

### Option 3: Kustomize with secretGenerator

Create a `kustomization.yaml`:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../charts/telehealth-apps

helmCharts:
  - name: telehealth-apps
    repo: local
    releaseName: telehealth-apps
    valuesFile: values-dev.yaml

secretGenerator:
  - name: postgres-secret
    envs:
      - secrets.env
```

## Viewing Logs

```bash
# Watch ArgoCD sync logs
argocd app logs telehealth-apps-dev --follow

# Check pod logs
kubectl logs -n telehealth-dev deployment/postgres
kubectl logs -n telehealth-dev deployment/redis

# Port forward to access services
kubectl port-forward -n telehealth-dev svc/postgres 5432:5432
kubectl port-forward -n telehealth-dev svc/redis 6379:6379
```

## Updating Applications

### Update Values
Change values in your Helm chart or values files, commit, and push.
ArgoCD will automatically detect the change and:
- Show "OutOfSync" status
- Auto-sync if enabled, or wait for manual sync

### Update Chart Version
Edit `charts/telehealth-apps/Chart.yaml` and increment version, then commit and push.

### Rollback
```bash
# View history
argocd app history telehealth-apps-dev

# Rollback to specific revision
argocd app rollback telehealth-apps-dev 1
```

## Cleanup

### Remove Application
```bash
argocd app delete telehealth-apps-dev
```

### Remove Repository
```bash
argocd repo rm https://github.com/your-org/telehealth-gitops
```

## Troubleshooting

### Application is OutOfSync
```bash
# Check what's different
argocd app diff telehealth-apps-dev

# Sync manually
argocd app sync telehealth-apps-dev
```

### Sync Failed
```bash
# Check error details
argocd app get telehealth-apps-dev

# Check pod status
kubectl get pods -n telehealth-dev
kubectl describe pod <pod-name> -n telehealth-dev
```

### Can't Access Git Repository
```bash
# Verify repo connection
argocd repo list

# Update repo credentials if needed
argocd repo update https://github.com/your-org/telehealth-gitops
```

## Best Practices

1. **Use separate applications** for dev and prod
2. **Enable auto-prune** to clean up deleted resources
3. **Use sealed secrets** for sensitive data
4. **Set resource limits** to prevent resource exhaustion
5. **Configure notifications** for sync failures
6. **Test changes** in dev before applying to prod
7. **Version your Helm charts** consistently
8. **Document your sync strategy** for your team

## Next Steps

1. Add this repository to ArgoCD
2. Create dev and prod applications
3. Configure synchronization policies
4. Set up monitoring and alerts
5. Document your deployment process
