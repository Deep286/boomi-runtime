# Boomi Runtime Template Deployment Guide

This guide provides detailed instructions for deploying the Boomi Runtime Template in your environment.

## Prerequisites

### Software Requirements

- **Kubernetes cluster** (v1.20+)
- **Docker** (v20.10+) 
- **kubectl** CLI tool
- **yq** YAML processor (v4.0+)
- **Jsonnet** (for Kubernetes config generation)
- **jq** JSON processor

### Access Requirements

- Kubernetes cluster access with appropriate permissions
- Container registry access for pulling Boomi images
- Boomi platform access with API credentials
- DNS management access (for ingress setup)

### Installation Commands

```bash
# Install yq (varies by OS)
# For Linux:
wget -qO- https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz | tar xz && sudo mv yq_linux_amd64 /usr/local/bin/yq

# For macOS:
brew install yq

# Install jsonnet
# For Linux:
wget https://github.com/google/jsonnet/releases/download/v0.19.1/jsonnet-bin-v0.19.1-linux.tar.gz
tar -xzf jsonnet-bin-v0.19.1-linux.tar.gz && sudo mv jsonnet* /usr/local/bin/

# For macOS:
brew install jsonnet
```

## Configuration Setup

### 1. Copy Configuration Template

```bash
cp config/template-values.yml.example config/template-values.yml
```

### 2. Edit Configuration

Edit `config/template-values.yml` with your organization's values:

```yaml
# Key sections to customize:

organization:
  name: "your-company"           # Your organization name
  domain: "your-domain.com"      # Your base domain
  container_registry: "registry.your-domain.com"

team:
  contact: "team@your-domain.com"
  # ... other team details

boomi:
  account_id: "your-boomi-account-id"
  username: "TOKEN.api-user@your-domain.com"

environments:
  dev:
    environment_id: "your-boomi-dev-environment-uuid"
    # ... other environment details
```

### 3. Validate Configuration

```bash
# Check YAML syntax
yq eval . config/template-values.yml

# Verify all required fields are set
./scripts/validate-config.sh config/template-values.yml
```

## Deployment Process

### Step 1: Generate Deployment Files

```bash
# Generate files using your configuration
./generate-deployment.sh config/template-values.yml generated

# Review generated files
find generated/ -type f | head -10
```

### Step 2: Prepare Kubernetes Environment

```bash
# Create namespace
kubectl create namespace your-project-namespace

# Create secrets for Boomi credentials
kubectl create secret generic boomi-credentials \
  --from-literal=BOOMI_PASSWORD="your-boomi-password" \
  --from-literal=BOOMI_ATOM_ID="your-atom-id" \
  -n your-project-namespace

# Create container registry secret (if using private registry)
kubectl create secret docker-registry container-pull-secret \
  --docker-server=registry.your-domain.com \
  --docker-username=your-username \
  --docker-password=your-password \
  --docker-email=your-email@your-domain.com \
  -n your-project-namespace
```

### Step 3: Deploy Infrastructure Components

```bash
# Deploy persistent volumes and RBAC
kubectl apply -f generated/deployment/environments/dev/
```

### Step 4: Build and Deploy Container

```bash
# Build container image
docker build -f generated/docker/Dockerfile -t your-registry/boomi-molecule:latest .

# Push to registry
docker push your-registry/boomi-molecule:latest

# Deploy application
kubectl apply -f generated/deployment/k6-performance-test.yml
```

### Step 5: Verify Deployment

```bash
# Check pod status
kubectl get pods -n your-project-namespace

# Check service status
kubectl get services -n your-project-namespace

# Check ingress status
kubectl get ingress -n your-project-namespace

# View logs
kubectl logs -l app=your-project-molecule -n your-project-namespace
```

## Environment-Specific Deployments

### Development Environment

```bash
# Deploy to dev
./generate-deployment.sh config/template-values.yml generated-dev
kubectl apply -f generated-dev/deployment/environments/dev/ -n your-project-dev
```

### Staging Environment

```bash
# Deploy to staging
./generate-deployment.sh config/template-values.yml generated-staging
kubectl apply -f generated-staging/deployment/environments/staging/ -n your-project-staging
```

### Production Environment

```bash
# Deploy to production (with extra validation)
./generate-deployment.sh config/template-values.yml generated-prod
kubectl diff -f generated-prod/deployment/environments/production/ -n your-project-prod
kubectl apply -f generated-prod/deployment/environments/production/ -n your-project-prod
```

## Monitoring and Troubleshooting

### Health Checks

```bash
# Check application health
curl -f https://your-app.your-domain.com/_admin/readiness

# Check JMX metrics
curl -f https://your-app.your-domain.com:1099/metrics
```

### Log Analysis

```bash
# View application logs
kubectl logs -f deployment/your-project-molecule -n your-project-namespace

# View node offboard logs
kubectl exec -it deployment/your-project-molecule -n your-project-namespace -- cat /mnt/boomi/offboard.log
```

### Common Issues

#### Issue: Container Won't Start

**Symptoms**: Pod stuck in `CrashLoopBackOff`

**Solutions**:
```bash
# Check pod events
kubectl describe pod your-pod-name -n your-project-namespace

# Check resource limits
kubectl top pod your-pod-name -n your-project-namespace

# Verify secrets are mounted
kubectl exec your-pod-name -n your-project-namespace -- env | grep BOOMI
```

#### Issue: Ingress Not Working

**Symptoms**: External URL not accessible

**Solutions**:
```bash
# Check ingress configuration
kubectl describe ingress your-project-molecule -n your-project-namespace

# Verify TLS certificates
kubectl get secrets cluster-wildcard-tls -n your-project-namespace

# Check DNS resolution
nslookup your-app.your-domain.com
```

#### Issue: Performance Problems

**Symptoms**: High response times or memory usage

**Solutions**:
```bash
# Check resource usage
kubectl top pods -n your-project-namespace

# Review JMX metrics
curl https://your-app.your-domain.com:1099/metrics | grep -i memory

# Scale up if needed
kubectl scale deployment your-project-molecule --replicas=3 -n your-project-namespace
```

## Performance Testing

### Run K6 Performance Tests

```bash
# Deploy performance test
kubectl apply -f generated/deployment/k6-performance-test.yml -n your-project-namespace

# Monitor test progress
kubectl logs -f job/your-project-k6-test -n your-project-namespace

# Get test results
kubectl get k6 your-project-k6-test -n your-project-namespace -o yaml
```

## Maintenance Operations

### Scaling Operations

```bash
# Scale up
kubectl scale deployment your-project-molecule --replicas=5 -n your-project-namespace

# Scale down
kubectl scale deployment your-project-molecule --replicas=1 -n your-project-namespace

# Auto-scaling (if HPA is configured)
kubectl get hpa -n your-project-namespace
```

### Updates and Rollbacks

```bash
# Update image
kubectl set image deployment/your-project-molecule container-name=new-image:tag -n your-project-namespace

# Check rollout status
kubectl rollout status deployment/your-project-molecule -n your-project-namespace

# Rollback if needed
kubectl rollout undo deployment/your-project-molecule -n your-project-namespace
```

### Backup and Recovery

```bash
# Backup persistent volume data
kubectl exec deployment/your-project-molecule -n your-project-namespace -- tar czf - /mnt/boomi > backup.tar.gz

# Backup configuration
kubectl get all,pvc,secrets,configmaps -n your-project-namespace -o yaml > namespace-backup.yaml
```

## Security Considerations

### RBAC Configuration

- Review and customize service account permissions
- Implement least-privilege access principles
- Regular audit of permissions

### Secrets Management

- Use external secret management systems (e.g., HashiCorp Vault)
- Rotate credentials regularly
- Never store secrets in configuration files

### Network Security

- Configure network policies to restrict pod communication
- Use TLS for all external communications
- Implement proper ingress security headers

## Support and Troubleshooting

For additional support:

1. **Documentation**: Check this deployment guide and README.md
2. **Logs**: Always check application and system logs first
3. **Community**: Consult Kubernetes and Boomi community resources
4. **Internal Support**: Contact your platform or infrastructure team

## Useful Commands Reference

```bash
# Quick status check
kubectl get all -n your-project-namespace

# Resource usage overview
kubectl top nodes && kubectl top pods -n your-project-namespace

# Full system overview
kubectl cluster-info && kubectl get nodes -o wide

# Debug networking
kubectl exec -it deployment/your-project-molecule -n your-project-namespace -- nslookup kubernetes.default

# Check storage
kubectl get pv,pvc -n your-project-namespace
```
