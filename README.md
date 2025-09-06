# Boomi Runtime Template

A simplified Kubernetes deployment template for Boomi Molecule runtime environments.

## Overview

This template provides a clean, minimal deployment solution for Boomi Molecule runtime environments on Kubernetes with basic monitoring and automation capabilities.

### Key Features

- **Multi-Environment Support**: Separate configurations for dev, staging, and production
- **Kubernetes Native**: Standard Kubernetes resources with minimal complexity
- **JMX Monitoring**: Built-in Prometheus JMX exporter
- **Automated CI/CD**: GitLab CI pipeline ready
- **Performance Testing**: K6 performance testing included
- **Node Cleanup**: Automated node offboarding on container termination

## Architecture

The following diagram illustrates the overall architecture and deployment flow of the Boomi Runtime Template:

```mermaid
graph TB
    subgraph "CI/CD Pipeline"
        A[GitLab Repository] --> B[Build Stage]
        B --> C[Test & Validate]
        C --> D[Deploy Dev]
        D --> E[Deploy Staging]
        E --> F[Deploy Production]
    end

    subgraph "Kubernetes Cluster"
        subgraph "Development Environment"
            G[boomi-dev namespace]
            H[Deployment: boomi-molecule-dev<br/>CPU: 250m/500m<br/>Memory: 2Gi/4Gi]
            I[Service: ClusterIP<br/>Ports: 80, 8080, 1099]
            J[PVC: boomi-storage<br/>10Gi]
            K[ServiceAccount]
            G --> H
            G --> I
            G --> J
            G --> K
        end

        subgraph "Staging Environment"
            L[boomi-staging namespace]
            M[Deployment: boomi-molecule-staging<br/>Replicas: 2<br/>Production-like resources]
            N[Service: ClusterIP]
            O[PVC: boomi-storage]
            L --> M
            L --> N
            L --> O
        end

        subgraph "Production Environment"
            P[boomi-production namespace]
            Q[Deployment: boomi-molecule-production<br/>Replicas: 3<br/>Full resources]
            R[Service: ClusterIP]
            S[PVC: boomi-storage]
            P --> Q
            P --> R
            P --> S
        end
    end

    subgraph "Container Components"
        T[Boomi Molecule Container<br/>Port 9090: HTTP API<br/>Port 8080: Web UI<br/>Port 1099: JMX Metrics]
        U[JMX Prometheus Agent<br/>Metrics Export]
        V[Health Checks<br/>Liveness & Readiness]
        W[Node Offboard Script<br/>Cleanup on termination]
        T --> U
        T --> V
        T --> W
    end

    subgraph "External Dependencies"
        X[Boomi Platform API<br/>api.boomi.com]
        Y[Container Registry<br/>Docker Hub / Private]
        Z[Monitoring System<br/>Prometheus/Grafana]
        AA[Performance Testing<br/>K6 Framework]
    end

    subgraph "Configuration & Secrets"
        BB[Kubernetes Secrets<br/>BOOMI_ACCOUNTID<br/>BOOMI_ATOMNAME<br/>INSTALL_TOKEN<br/>API Credentials]
        CC[ConfigMaps<br/>JMX Configuration<br/>Template Values]
        DD[Environment Specs<br/>Jsonnet Configuration]
    end

    H --> T
    M --> T
    Q --> T
    T --> X
    B --> Y
    U --> Z
    AA --> H
    BB --> H
    BB --> M
    BB --> Q
    CC --> H
    CC --> M
    CC --> Q
    DD --> H
    DD --> M
    DD --> Q
```

### Architecture Components

- **CI/CD Pipeline**: Automated GitLab-based build, test, and deployment pipeline
- **Multi-Environment**: Isolated namespaces for dev, staging, and production deployments
- **Container Runtime**: Boomi Molecule containers with integrated monitoring and health checks
- **Storage**: Persistent volumes for Boomi runtime data and configurations
- **Monitoring**: JMX metrics export to Prometheus with Grafana visualization ready
- **Security**: Service accounts and secrets management for secure operations

## Quick Start

1. **Clone the template**:
   ```bash
   # Copy the template to your project
   cp -r boomi-runtime-template/ my-boomi-project/
   cd my-boomi-project/
   ```

2. **Configure your deployment**:
   ```bash
   # Edit the basic configuration
   vim config/template-values.yml
   ```

3. **Create Kubernetes secrets**:
   ```bash
   kubectl create namespace boomi-runtime
   kubectl create secret generic boomi-secrets \
     --from-literal=BOOMI_ACCOUNTID="your-account-id" \
     --from-literal=BOOMI_ATOMNAME="your-atom-name" \
     --from-literal=INSTALL_TOKEN="your-install-token" \
     --from-literal=BOOMI_PASSWORD="your-password" \
     --from-literal=BOOMI_ATOM_ID="your-atom-id" \
     --from-literal=BOOMI_USERNAME="your-username" \
     --from-literal=BOOMI_BASE_URL="https://api.boomi.com" \
     -n boomi-runtime
   ```

4. **Deploy to development**:
   ```bash
   kubectl apply -f deployment/environments/dev/
   ```

## Project Structure

```
boomi-runtime-template/
├── README.md
├── .gitlab-ci.yml                  # GitLab CI/CD pipeline
├── config/
│   ├── jmx-config.yaml             # JMX monitoring config
│   └── template-values.yml         # Basic configuration
├── deployment/
│   ├── environments/               # Environment-specific configs
│   │   ├── default/               # Base configuration
│   │   ├── dev/                   # Development environment
│   │   ├── staging/               # Staging environment
│   │   └── production/            # Production environment
│   ├── jsonnetfile.json           # Jsonnet dependencies
│   └── k6-performance-test.yml    # Performance testing
├── docker/
│   └── Dockerfile                 # Container image
├── scripts/
│   ├── node_offboard.sh           # Cleanup script
│   └── performance_test.js        # K6 performance test
└── docs/
    └── deployment-guide.md        # Detailed guide
```

## Configuration

### Basic Settings

Edit `config/template-values.yml`:

```yaml
project:
  name: boomi-molecule          # Your project name
  namespace: boomi-runtime      # Kubernetes namespace

image:
  repository: boomi/molecule    # Container image
  tag: latest                   # Image tag

resources:
  requests:
    cpu: 500m                   # CPU request
    memory: 4Gi                 # Memory request
  limits:
    cpu: 1000m                  # CPU limit
    memory: 6Gi                 # Memory limit
```

### Environment Overrides

Each environment can override the base configuration:

- **Dev**: Lower resource limits for development
- **Staging**: Production-like with 2 replicas
- **Production**: Full resources with 3 replicas

## Deployment

### Prerequisites

- Kubernetes cluster access
- kubectl configured
- Docker registry access
- Boomi account credentials

### Deploy Steps

1. **Build container** (optional):
   ```bash
   docker build -f docker/Dockerfile -t your-registry/boomi-molecule:latest .
   docker push your-registry/boomi-molecule:latest
   ```

2. **Create namespace and secrets**:
   ```bash
   kubectl create namespace boomi-runtime
   # Create secrets as shown in Quick Start
   ```

3. **Deploy environment**:
   ```bash
   # Development
   kubectl apply -f deployment/environments/dev/

   # Staging
   kubectl apply -f deployment/environments/staging/

   # Production
   kubectl apply -f deployment/environments/production/
   ```

### Verification

```bash
# Check deployment status
kubectl get all -n boomi-runtime

# Check logs
kubectl logs deployment/boomi-molecule-dev -n boomi-dev

# Test connectivity
kubectl port-forward service/boomi-molecule-dev 9090:80 -n boomi-dev
curl http://localhost:9090/_admin/readiness
```

## Performance Testing

Run K6 performance tests:

```bash
kubectl apply -f deployment/k6-performance-test.yml -n boomi-dev
kubectl logs -f job/boomi-performance-test -n boomi-dev
```

## Monitoring

The deployment includes:

- **JMX Metrics**: Exposed on port 1099
- **Health Checks**: Liveness and readiness probes
- **Prometheus Integration**: Ready for scraping

Access JMX metrics:
```bash
kubectl port-forward service/boomi-molecule-dev 1099:1099 -n boomi-dev
curl http://localhost:1099/metrics
```

## CI/CD Pipeline

The included `.gitlab-ci.yml` provides:

- **Build**: Docker image building and pushing
- **Test**: Kubernetes manifest validation and performance testing
- **Deploy**: Environment-specific deployments (manual approval required)

Configure these GitLab CI variables:
- `CI_REGISTRY_*`: Container registry credentials
- Kubernetes cluster access for deployments

## Troubleshooting

### Common Issues

1. **Pod won't start**: Check secrets are created and mounted correctly
2. **Performance issues**: Adjust resource limits in environment configs
3. **Connectivity problems**: Verify service and ingress configurations

### Debug Commands

```bash
# Pod status and events
kubectl describe pod <pod-name> -n boomi-runtime

# Resource usage
kubectl top pods -n boomi-runtime

# Service endpoints
kubectl get endpoints -n boomi-runtime

# Check secrets
kubectl get secrets boomi-secrets -n boomi-runtime -o yaml
```

## Support

- **Documentation**: See `docs/deployment-guide.md` for detailed instructions
- **Issues**: Check pod logs and Kubernetes events first
- **Configuration**: All settings are in standard Kubernetes manifests
