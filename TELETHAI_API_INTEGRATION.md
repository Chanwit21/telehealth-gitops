# Telethai Master Data API Integration

## Overview
The **telethai-master-data-api** has been successfully integrated into the Helm chart. This is a NestJS application that provides bank and payment method master data APIs.

## Architecture

### Application Details
- **Container Image**: `ghcr.io/chanwit21/telethai-master-data-api:latest`
- **Runtime**: Node.js
- **Framework**: NestJS
- **Port**: 8001
- **Service Type**: ClusterIP

### Dependencies
- **PostgreSQL**: Connected via `DATABASE_HOST: postgres`
- **Redis**: Connected via `REDIS_HOST: redis`

## Environment Configuration

### ConfigMap-Based Environment Variables
The application uses Kubernetes ConfigMaps to manage all environment variables (`.env` concept):

```yaml
DATABASE_HOST: postgres
DATABASE_PORT: 5432
DATABASE_USER: postgres
DATABASE_PASSWORD: <from values.yaml>
DATABASE_NAME: <dev: telethai_dev | prod: telethai_master_data>
REDIS_HOST: redis
REDIS_PORT: 6379
REDIS_PASSWORD: ""
NODE_ENV: <dev: development | prod: production>
PORT: 8001
```

### Environment-Specific Values

**Development (telehealth-dev)**
```yaml
DATABASE_NAME: telethai_dev
DATABASE_PASSWORD: dev_password_change_me
NODE_ENV: development
Resources: 128Mi/50m CPU (requests) → 256Mi/200m (limits)
```

**Production (telehealth-prod)**
```yaml
DATABASE_NAME: telethai_master_data
DATABASE_PASSWORD: CHANGE_ME_IN_PRODUCTION
NODE_ENV: production
Resources: 256Mi/100m CPU (requests) → 512Mi/500m (limits)
```

## Health Checks

- **Readiness Probe**: HTTP GET `/` (10s initial delay, 5s period)
- **Liveness Probe**: HTTP GET `/` (30s initial delay, 10s period)

The app responds with 200 status code on the root path when healthy.

## Files Created/Modified

### New Templates
- `charts/telehealth-apps/templates/telethai-configmap.yaml` - ConfigMap template
- `charts/telehealth-apps/templates/telethai-deployment.yaml` - Deployment template  
- `charts/telehealth-apps/templates/telethai-service.yaml` - Service template

### Modified Files
- `charts/telehealth-apps/values.yaml` - Added `telethaiBapi` section
- `examples/helm-values-dev.yaml` - Added dev telethaiBapi config
- `examples/helm-values-prod.yaml` - Added prod telethaiBapi config

## Deployment Status

### Development Environment (telehealth-dev)
```
✅ PostgreSQL: 1/1 Running
✅ Redis: 1/1 Running
✅ Telethai API: 1/1 Running
✅ ConfigMap: telethai-api-env (10 data keys)
✅ Service: telethai-api (ClusterIP, port 8001)
```

### Production Environment (telehealth-prod)
```
✅ PostgreSQL: 1/1 Running
✅ Redis: 1/1 Running
✅ Telethai API: 1/1 Running
✅ ConfigMap: telethai-api-env (10 data keys)
✅ Service: telethai-api (ClusterIP, port 8001)
```

## Database Setup

### Databases Created
- **Dev**: `telethai_dev` - Created and ready
- **Prod**: `telethai_master_data` - Created and ready

The application auto-initializes schema on first startup via TypeORM.

## API Access

### From Within Cluster
- **Dev**: `http://telethai-api:8001` (from `telehealth-dev` namespace)
- **Prod**: `http://telethai-api:8001` (from `telehealth-prod` namespace)

### Swagger Documentation
- **Dev**: `http://localhost:8001/api/docs` (when port-forwarded)
- **Prod**: `http://localhost:8001/api/docs` (when port-forwarded)

## Available Endpoints

From logs, the following routes are available:
- `GET /` - Root endpoint (used for health checks)
- `POST /payment-methods` - Create payment method
- `GET /payment-methods` - List payment methods
- `GET /banks` - List banks
- `POST /banks` - Create bank
- `GET /banks/:code` - Get specific bank
- `PATCH /banks/:code` - Update bank
- `DELETE /banks/:code` - Delete bank

## Configuration Customization

To change environment variables, modify the respective Helm values file:

**For Dev**:
```bash
helm upgrade telehealth-apps ./charts/telehealth-apps \
  -n telehealth-dev \
  -f examples/helm-values-dev.yaml \
  --set telethaiBapi.env.DATABASE_PASSWORD=new_password
```

**For Prod**:
```bash
helm upgrade telehealth-apps ./charts/telehealth-apps \
  -n telehealth-prod \
  -f examples/helm-values-prod.yaml \
  --set telethaiBapi.env.DATABASE_PASSWORD=new_password
```

## Security Notes

1. **Database Passwords**: Change `DATABASE_PASSWORD` in production values file before deploying
2. **Redis Password**: Currently empty - update if Redis requires authentication
3. **Environment Variables**: All stored in ConfigMaps (not encrypted) - consider using Secrets for sensitive data in production

## Redis Connection Status

Both environments show:
```
✅ Redis connected
```

This confirms successful Redis integration via the configured `REDIS_HOST` and `REDIS_PORT`.

## Next Steps

1. ✅ Application deployed to both environments
2. ✅ Databases initialized
3. ✅ ConfigMaps created with all required environment variables
4. ⏭️ Update passwords in production (`DATABASE_PASSWORD`)
5. ⏭️ Configure ArgoCD to manage this application (optional)
6. ⏭️ Set up API access routes (Ingress) if needed

## Troubleshooting

### View Logs
```bash
# Dev
kubectl logs -f deployment/telethai-api -n telehealth-dev

# Prod
kubectl logs -f deployment/telethai-api -n telehealth-prod
```

### Check ConfigMap
```bash
kubectl get configmap telethai-api-env -n <namespace> -o yaml
```

### Port Forward to Test
```bash
kubectl port-forward svc/telethai-api 8001:8001 -n <namespace>
```

### Check Pod Events
```bash
kubectl describe pod <pod-name> -n <namespace>
```

