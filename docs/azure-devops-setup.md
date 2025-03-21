# Azure DevOps Pipeline Setup Guide

## Prerequisites
✅ Azure resources have been created:
- Resource Group: langflow-resources
- Azure Container Registry: langflow.azurecr.io
- AKS Cluster: langflow-aks

## Setup Steps

### 1. Create Azure DevOps Project
1. Go to https://dev.azure.com
2. Create a new project or use an existing one
3. Navigate to Project Settings > Service Connections

### 2. Create Service Connections
1. Create "Azure Resource Manager" service connection:
   - Select your subscription
   - Name it "Azure Subscription"
   - Grant access to all pipelines

2. Create "Docker Registry" service connection:
   - Registry type: Azure Container Registry
   - Select your subscription
   - Select "langflow" registry
   - Name it "Azure Container Registry"
   - Grant access to all pipelines

### 3. Create Variable Group
1. Go to Pipelines > Library
2. Create new variable group named "langflow-production"
3. Add the following variables:
   ```
   AZURE_SUBSCRIPTION=<your-subscription-id>
   AZURE_ACR_NAME=langflow
   AZURE_AKS_CLUSTER=langflow-aks
   AZURE_RESOURCE_GROUP=langflow-resources
   ```
4. Save the variable group
5. Allow access to all pipelines

### 4. Import Repository and Set Up Pipeline
1. Go to Repos > Files
2. Import your repository
3. Go to Pipelines > Pipelines
4. Create new pipeline:
   - Select "Azure Repos Git" as your code location
   - Select your repository
   - Select "Existing Azure Pipelines YAML file"
   - Select '/azure-pipelines.yml'
   - Review and run the pipeline

### 5. Verify Pipeline Configuration
1. Check that all stages complete successfully:
   - Build stage (frontend, backend, workers)
   - Test stage
   - Security scan stage
   - Deployment stage
   - Monitoring setup

2. Verify deployments:
   ```bash
   kubectl get pods -n langflow
   kubectl get services -n langflow
   kubectl get ingress -n langflow
   ```

### 6. Access the Application
1. Get the application URL:
   ```bash
   kubectl get ingress langflow-ingress -n langflow
   ```
2. Update your DNS or hosts file if needed
3. Access the application through your browser

## Troubleshooting
- Check pipeline logs for detailed error messages
- Verify service connections are working
- Ensure all required secrets are properly configured
- Check Kubernetes events: `kubectl get events -n langflow`
- Review pod logs: `kubectl logs -n langflow <pod-name>`

## Security Notes
- Keep your Azure credentials secure
- Regularly rotate service principal credentials
- Monitor Azure Security Center alerts
- Review Kubernetes RBAC permissions regularly
- Enable Azure Container Registry vulnerability scanning