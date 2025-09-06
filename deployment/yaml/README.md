# Kubernetes YAML Manifests

This directory contains Kubernetes YAML manifests converted from the Jsonnet configurations, providing a direct alternative to using Jsonnet for deployments.

## Directory Structure

```
yaml/
├── default/        # Base configuration (boomi-runtime namespace)
├── dev/           # Development environment (boomi-dev namespace)
├── staging/       # Staging environment (boomi-staging namespace)
└── production/    # Production environment (boomi-production namespace)
```

Each environment directory contains:
- `01-namespace.yaml` - Kubernetes namespace
- `02-serviceaccount.yaml` - Service account for the deployment
- `03-pvc.yaml` - Persistent Volume Claim for data storage
- `04-deployment.yaml` - Main Boomi Molecule deployment
- `05-service.yaml` - Service to expose the deployment

## Environment Configurations

### Default Environment
- **Namespace**: `boomi-runtime`
- **Replicas**: 1
- **Resources**: 500m CPU / 4Gi RAM (request), 1000m CPU / 6Gi RAM (limit)

### Development Environment
- **Namespace**: `boomi-dev`
- **Replicas**: 1
- **Resources**: 250m CPU / 2Gi RAM (request), 500m CPU / 4Gi RAM (limit)
- Optimized for development with lower resource usage

### Staging Environment
- **Namespace**: `boomi-staging`
- **Replicas**: 2
- **Resources**: 500m CPU / 4Gi RAM (request), 1000m CPU / 6Gi RAM (limit)
- Production-like configuration for testing

### Production Environment
- **Namespace**: `boomi-production`
- **Replicas**: 3
- **Resources**: 1000m CPU / 8Gi RAM (request), 2000m CPU / 12Gi RAM (limit)
- High availability with 3 replicas and increased resources

## Deployment Instructions

### Prerequisites

1. Create the required secrets in each namespace:
```bash
kubectl create secret generic boomi-secrets \
  --from-literal=BOOMI_ACCOUNTID="your-account-id" \
  --from-literal=BOOMI_ATOMNAME="your-atom-name" \
  --from-literal=INSTALL_TOKEN="your-install-token" \
  --from-literal=BOOMI_PASSWORD="your-password" \
  --from-literal=BOOMI_ATOM_ID="your-atom-id" \
  --from-literal=BOOMI_USERNAME="your-username" \
  --from-literal=BOOMI_BASE_URL="https://api.boomi.com" \
  -n <namespace>
```

Replace `<namespace>` with the target environment namespace.

### Deploy to Specific Environment

```bash
# Deploy to development
kubectl apply -f deployment/yaml/dev/

# Deploy to staging
kubectl apply -f deployment/yaml/staging/

# Deploy to production
kubectl apply -f deployment/yaml/production/
```

### Verify Deployment

```bash
# Check deployment status
kubectl get all -n <namespace>

# Check logs
kubectl logs deployment/<deployment-name> -n <namespace>

# Port forward to test locally
kubectl port-forward service/<service-name> 9090:80 -n <namespace>
```

## File Order

Files are numbered to ensure proper deployment order:
1. **Namespace** - Creates the namespace first
2. **ServiceAccount** - Creates the service account
3. **PVC** - Creates storage resources
4. **Deployment** - Creates the main application deployment
5. **Service** - Exposes the deployment

## Customization

To customize these manifests for your environment:

1. **Image**: Update the `image` field in the deployment files
2. **Resources**: Adjust CPU/memory requests and limits as needed
3. **Replicas**: Modify the `replicas` field for scaling
4. **Storage**: Change PVC size in the storage files
5. **Environment Variables**: Add additional env vars to the deployment containers

## Monitoring

Each deployment includes:
- **Health Checks**: Liveness and readiness probes
- **JMX Metrics**: Exposed on port 1099 for Prometheus scraping
- **Graceful Shutdown**: 300-second termination grace period with cleanup script

## Troubleshooting

Common issues and solutions:

1. **Pods not starting**: Check if secrets exist in the namespace
2. **Storage issues**: Verify PVC is bound and storage class is available
3. **Network issues**: Check service endpoints and ingress configuration
4. **Resource constraints**: Monitor resource usage and adjust limits

For more detailed troubleshooting, see the main README.md file.
