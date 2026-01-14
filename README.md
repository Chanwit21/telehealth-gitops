# Telehealth GitOps Repository

This repository contains Kubernetes manifests for the Telehealth application managed by ArgoCD.

## 📋 Repository Configuration

Your application is configured to sync from:
- **Repository**: https://github.com/Chanwit21/telehealth-gitops
- **Branch**: main
- **Path**: . (root of repository)
- **Target Namespace**: default

### To Customize

Edit `telehealth-app.yaml`:

```yaml
source:
  repoURL: https://github.com/Chanwit21/telehealth-gitops
  targetRevision: main          # Change branch if needed
  path: .                        # Change to subdir if needed (e.g., ./k8s)

destination:
  namespace: default             # Change target namespace
```

Then apply changes:
```bash
kubectl apply -f telehealth-app.yaml -n argocd
```

## 📦 Repository Structure

This repository uses **Plain YAML** format with optional Kustomize support:

```
telehealth-gitops/
├── deployment.yaml          # Application deployment
├── service.yaml             # Service configuration
├── configmap.yaml           # Configuration data
├── argocd-namespace.yaml    # ArgoCD namespace
├── kustomization.yaml       # Kustomize configuration
├── telehealth-app.yaml      # ArgoCD Application resource
└── README.md                # This file
```

## 🚀 Quick Start

### 1. Install ArgoCD (if not already installed)
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Register the Application with ArgoCD
```bash
kubectl apply -f telehealth-app.yaml -n argocd
```

### 3. Check Sync Status
```bash
kubectl get application -n argocd
```

### 4. Access ArgoCD UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Access at https://localhost:8080
```

## 📝 File Descriptions

- **deployment.yaml**: Defines the Telehealth application deployment with 3 replicas, resource limits, and health probes
- **service.yaml**: Exposes the application as a LoadBalancer service on port 80
- **configmap.yaml**: Contains application configuration parameters
- **argocd-namespace.yaml**: Creates the argocd namespace for ArgoCD resources
- **kustomization.yaml**: Organizes all manifests with common labels
- **telehealth-app.yaml**: ArgoCD Application resource for automated sync

## 🔐 Security Notes

### Development/Testing (Current Setup)
⚠️ This setup is for **development/testing only**:
- Insecure flag enabled (self-signed certs)
- No HTTPS enforcement
- Default admin user active
- No authentication on services

### Production Recommendations
For **production deployment**, implement:
1. ✅ Enable RBAC and create proper service accounts
2. ✅ Set up proper TLS certificates
3. ✅ Change admin password
4. ✅ Disable/restrict default admin user
5. ✅ Use sealed secrets for sensitive data
6. ✅ Add authentication (OIDC, GitHub, etc.)
7. ✅ Enable network policies
8. ✅ Use private image registries with authentication
9. ✅ Implement resource quotas and limits
10. ✅ Set up monitoring and logging

## 🔄 Sync Strategy

ArgoCD is configured with:
- **Automated Sync**: Automatically syncs when repository changes
- **Prune**: Removes resources that are no longer in git
- **Self-Heal**: Automatically reverts manual changes in the cluster

To change sync policy, edit `telehealth-app.yaml` and update the `syncPolicy` section.

## 🛠️ Customization

### Change Target Namespace
Edit `telehealth-app.yaml`:
```yaml
destination:
  namespace: your-namespace
```

### Change Repository URL
Edit `telehealth-app.yaml`:
```yaml
source:
  repoURL: https://github.com/your-org/your-repo
```

### Change Branch
Edit `telehealth-app.yaml`:
```yaml
source:
  targetRevision: develop  # or any branch name
```

### Update Application Configuration
Edit `configmap.yaml` and commit:
```bash
git add configmap.yaml
git commit -m "Update application configuration"
git push
```

ArgoCD will automatically detect and apply the changes.

## 📊 Monitoring

View application status:
```bash
kubectl describe application telehealth-app -n argocd
```

View logs:
```bash
# Application pod logs
kubectl logs -f deployment/telehealth-app -n default

# ArgoCD controller logs
kubectl logs -f deployment/argocd-application-controller -n argocd
```

## ⚙️ Advanced Configuration

### Using Overlays with Kustomize
To use environment-specific overlays, create:
```
overlays/
├── dev/kustomization.yaml
├── staging/kustomization.yaml
└── prod/kustomization.yaml
```

Then update `telehealth-app.yaml`:
```yaml
source:
  path: overlays/prod
```

### Using Helm
If using Helm instead of plain YAML, add a `Chart.yaml` and structure manifests accordingly.

## 🐛 Troubleshooting

### Application stuck in OutOfSync
```bash
# Force sync
argocd app sync telehealth-app --force
```

### Check sync errors
```bash
kubectl describe application telehealth-app -n argocd
```

### View ArgoCD logs
```bash
kubectl logs -f deployment/argocd-application-controller -n argocd
```

## 📚 References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kustomize Documentation](https://kustomize.io/)

## 📝 License

This repository is part of the Telehealth project.
