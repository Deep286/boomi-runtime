# Configuration Examples

This directory contains example configurations for the Boomi Runtime Template.

## Files

### `secrets-example.yaml`

Example Kubernetes secret configuration for Boomi deployment. This shows the required environment variables that need to be configured for the deployment to work.

**Important**: Never commit actual secrets to version control. Use this as a reference only.

## Required Secrets

The deployment requires these environment variables to be set via Kubernetes secrets:

### Boomi Platform Configuration
- `BOOMI_ACCOUNTID`: Your Boomi account ID
- `BOOMI_ATOMNAME`: Name for the Boomi Atom/Molecule
- `INSTALL_TOKEN`: Token for installing the Molecule

### Boomi API Configuration (for node offboarding)
- `BOOMI_USERNAME`: API username (usually in format TOKEN.user@domain.com)
- `BOOMI_PASSWORD`: API password
- `BOOMI_ATOM_ID`: UUID of the Atom in Boomi platform
- `BOOMI_BASE_URL`: Boomi API base URL (usually https://api.boomi.com)

## Creating Secrets

### Method 1: Command Line
```bash
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

### Method 2: From File (Not Recommended for Production)
```bash
# Copy the example and fill in your values
cp examples/secrets-example.yaml secrets.yaml
# Edit secrets.yaml with your actual values
vim secrets.yaml
# Apply (then delete the file!)
kubectl apply -f secrets.yaml
rm secrets.yaml
```

### Method 3: External Secret Management
For production environments, use external secret management tools like:
- HashiCorp Vault
- AWS Secrets Manager
- Azure Key Vault
- Google Secret Manager
- Sealed Secrets
- External Secrets Operator

## Configuration Validation

After creating secrets, verify they're correctly set:

```bash
# Check secret exists
kubectl get secret boomi-secrets -n boomi-runtime

# Verify secret data (will show base64 encoded values)
kubectl describe secret boomi-secrets -n boomi-runtime

# Test in a pod
kubectl run test-secrets --image=alpine --rm -it --restart=Never \
  --env-from=secretRef:boomi-secrets -n boomi-runtime -- sh
# Inside the pod, run: env | grep BOOMI
```

## Best Practices

1. **Never commit secrets**: Use `.gitignore` to exclude secret files
2. **Use proper RBAC**: Limit access to secrets via Kubernetes RBAC
3. **Rotate regularly**: Change API passwords and tokens periodically
4. **Monitor access**: Audit who accesses secrets
5. **External management**: Use dedicated secret management systems for production