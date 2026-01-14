# CONTRIBUTING.md

## Contributing to Telehealth GitOps

Thank you for contributing! Here's how to make changes to this repository.

## Making Changes

### 1. Update the Helm Chart

Edit files in `charts/telehealth-apps/`:
- `values.yaml` - Default configuration
- `templates/*.yaml` - Kubernetes manifests

### 2. Update Environment Values

Edit `environments/values-{dev,prod}.yaml` for environment-specific overrides.

### 3. Test Your Changes

```bash
# Validate the chart
helm lint charts/telehealth-apps/

# Preview the manifests
helm template telehealth-apps charts/telehealth-apps/ \
  -f environments/values-dev.yaml

# Install to a test cluster
helm install telehealth-apps charts/telehealth-apps/ \
  -n test-ns \
  -f environments/values-dev.yaml \
  --create-namespace
```

### 4. Update Chart Version

When making changes, bump the version in `charts/telehealth-apps/Chart.yaml`:
```yaml
version: 1.0.1  # Increment patch version
```

### 5. Commit and Push

```bash
git add .
git commit -m "feat: add Redis persistence configuration"
git push origin main
```

ArgoCD will automatically sync the changes to your cluster!

## Guidelines

- **Document changes**: Update README.md if you add new features
- **Use semantic versioning**: Major.Minor.Patch
- **Test before pushing**: Don't break the deployment
- **Follow Helm best practices**: Use templates, validate with lint
- **Security**: Never commit secrets or passwords
- **Environment separation**: Keep dev and prod configs separate

## Troubleshooting

If ArgoCD doesn't sync automatically:

```bash
# Check ArgoCD application status
argocd app get telehealth-apps-dev

# Force sync
argocd app sync telehealth-apps-dev

# View sync logs
argocd app logs telehealth-apps-dev
```

## Questions?

Contact the Telehealth Platform Team for support.
