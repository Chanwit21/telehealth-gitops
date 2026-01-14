# TeleThai Master Data API - Kubernetes Manifests

This directory contains Kubernetes manifests for the TeleThai Master Data API NestJS backend application, organized using Kustomize.

## Directory Structure

```
master-data-api/
├── base/                    # Base configuration
│   ├── kustomization.yaml  # Kustomize base configuration
│   ├── deployment.yaml     # Kubernetes Deployment
│   ├── service.yaml        # Kubernetes Service
│   └── configmap.yaml      # ConfigMap for application settings
├── overlays/               # Environment-specific overlays
│   ├── dev/               # Development environment
│   ├── staging/           # Staging environment
│   └── prod/              # Production environment
└── README.md
```

## Base Configuration

The base directory contains the core Kubernetes manifests:

- **deployment.yaml**: NestJS application deployment with health checks, resource limits, and security settings
- **service.yaml**: ClusterIP service exposing port 3000
- **configmap.yaml**: Application configuration (log level, database pool size, etc.)

## Environment-Specific Overlays

### Development (dev/)
- Single replica
- Debug-level logging
- Lower resource limits
- Image tag: dev-latest

### Staging (staging/)
- Two replicas
- Info-level logging
- Medium resource limits
- Image tag: staging-latest

### Production (prod/)
- Three replicas
- Warning-level logging
- Higher resource limits
- Image tag: v1.0.0

## Building Manifests

### View generated manifests
```bash
kustomize build overlays/dev
kustomize build overlays/staging
kustomize build overlays/prod
```

### Apply directly with kubectl
```bash
kubectl apply -k overlays/dev
kubectl apply -k overlays/staging
kubectl apply -k overlays/prod
```

## Features

- **Health Checks**: Liveness and readiness probes configured
- **Resource Management**: CPU and memory requests/limits defined
- **Security**: Non-root user, restricted permissions
- **High Availability**: Pod anti-affinity for distribution
- **Observability**: Prometheus metrics endpoints configured
- **Rolling Updates**: Graceful deployment strategy

## Configuration

To modify environment-specific settings, edit the corresponding overlay's kustomization.yaml:

```yaml
configMapGenerator:
- name: telethai-master-data-api-config
  behavior: replace
  literals:
  - log-level=info
  - database-pool-size=10
  - request-timeout=30000
```

## ArgoCD Integration

These manifests are deployed via ArgoCD applications. See `/argocd/README.md` for deployment instructions.

## Troubleshooting

### Check deployment status
```bash
kubectl get deployments -n telethai-dev
kubectl describe deployment dev-telethai-master-data-api -n telethai-dev
```

### View pod logs
```bash
kubectl logs -n telethai-dev deployment/dev-telethai-master-data-api
```

### Check service connectivity
```bash
kubectl get svc -n telethai-dev
kubectl port-forward svc/dev-telethai-master-data-api 3000:3000 -n telethai-dev
```
