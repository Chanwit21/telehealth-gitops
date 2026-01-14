# ArgoCD Applications for TeleThai Backend

This directory contains ArgoCD Application manifests for deploying the telethai-master-data-api service.

## Structure

- `argocd-application-dev.yaml` - Development environment (auto-sync enabled)
- `argocd-application-staging.yaml` - Staging environment (auto-sync enabled)
- `argocd-application-prod.yaml` - Production environment (manual sync)

## Deployment

### Prerequisites

1. ArgoCD installed in your cluster
2. GitHub repository with appropriate access

### Setup

1. Update the `repoURL` in each application manifest with your actual repository URL:
   ```bash
   sed -i 's|https://github.com/your-org/telehealth-gitops|YOUR_REPO_URL|g' argocd-application-*.yaml
   ```

2. Apply the ArgoCD applications:
   ```bash
   kubectl apply -f argocd-application-dev.yaml
   kubectl apply -f argocd-application-staging.yaml
   kubectl apply -f argocd-application-prod.yaml
   ```

3. Verify the applications:
   ```bash
   kubectl get applications -n argocd
   ```

## Environments

### Dev (telethai-dev)
- Replicas: 1
- Image Tag: dev-latest
- Resources: 128Mi/256Mi memory, 50m/250m CPU
- Auto-sync: Enabled

### Staging (telethai-staging)
- Replicas: 2
- Image Tag: staging-latest
- Resources: 256Mi/512Mi memory, 100m/500m CPU
- Auto-sync: Enabled

### Prod (telethai-prod)
- Replicas: 3
- Image Tag: v1.0.0
- Resources: 512Mi/1024Mi memory, 200m/1000m CPU
- Auto-sync: Disabled (manual review required)

## Customization

To customize the configurations:

1. Edit the kustomization.yaml files in each overlay directory
2. Push changes to the repository
3. ArgoCD will detect and sync the changes

## Troubleshooting

Check ArgoCD application status:
```bash
kubectl describe application telethai-master-data-api-dev -n argocd
```

View application logs:
```bash
kubectl logs -n telethai-dev deployment/dev-telethai-master-data-api
```

Manual sync:
```bash
argocd app sync telethai-master-data-api-dev
```
