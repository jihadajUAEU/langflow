# Azure Resource Setup Script for Langflow

param(
    [string]$resourceGroupName = "langflow-resources",
    [string]$location = "eastus",
    [string]$acrName = "langflow",
    [string]$aksClusterName = "langflow-aks",
    [int]$aksNodeCount = 2,
    [string]$aksVMSize = "Standard_D2s_v3"
)

# Check if Azure CLI is installed
$azCheck = Get-Command az -ErrorAction SilentlyContinue
if (!$azCheck) {
    Write-Host "Azure CLI is not installed. Installing now..."
    
    # Download the MSI installer
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
    
    # Install Azure CLI
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
    
    # Remove the installer
    Remove-Item .\AzureCLI.msi
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "Azure CLI installed successfully. Please restart your PowerShell session and run this script again."
    exit
}

# Login check
try {
    $account = az account show --query name -o tsv 2>$null
    if (!$account) {
        Write-Host "Please login to Azure first."
        Write-Host "Run: az login"
        exit 1
    }
} catch {
    Write-Host "Please login to Azure first."
    Write-Host "Run: az login"
    exit 1
}

# Create Resource Group
Write-Host "Creating Resource Group..."
az group create --name $resourceGroupName --location $location

# Create Azure Container Registry
Write-Host "Creating Azure Container Registry..."
az acr create `
    --resource-group $resourceGroupName `
    --name $acrName `
    --sku Standard `
    --admin-enabled true

# Get ACR credentials
$acrUsername = az acr credential show --name $acrName --query "username" -o tsv
$acrPassword = az acr credential show --name $acrName --query "passwords[0].value" -o tsv

# Create AKS Cluster
Write-Host "Creating AKS Cluster..."
az aks create `
    --resource-group $resourceGroupName `
    --name $aksClusterName `
    --node-count $aksNodeCount `
    --node-vm-size $aksVMSize `
    --generate-ssh-keys `
    --attach-acr $acrName `
    --enable-managed-identity

# Install kubectl if not present
if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "Installing kubectl..."
    az aks install-cli
}

# Get AKS credentials
Write-Host "Getting AKS credentials..."
az aks get-credentials --resource-group $resourceGroupName --name $aksClusterName

# Create namespace
Write-Host "Creating Kubernetes namespace..."
kubectl create namespace langflow

# Create secret for ACR
Write-Host "Creating ACR pull secret..."
kubectl create secret docker-registry acr-secret `
    --namespace langflow `
    --docker-server="$acrName.azurecr.io" `
    --docker-username=$acrUsername `
    --docker-password=$acrPassword

# Enable HTTP application routing
Write-Host "Enabling HTTP application routing..."
az aks enable-addons `
    --resource-group $resourceGroupName `
    --name $aksClusterName `
    --addons http_application_routing

# Output important information
Write-Host "`nSetup Complete! Important Information:"
Write-Host "Resource Group: $resourceGroupName"
Write-Host "ACR Name: $acrName.azurecr.io"
Write-Host "AKS Cluster: $aksClusterName"
Write-Host "`nNext Steps:"
Write-Host "1. Configure your Azure DevOps pipeline using the azure-pipelines.yml file"
Write-Host "2. Add the following secrets to your Azure DevOps variable group 'langflow-production':"
Write-Host "   - AZURE_SUBSCRIPTION"
Write-Host "   - AZURE_ACR_NAME"
Write-Host "   - AZURE_AKS_CLUSTER"
Write-Host "   - AZURE_RESOURCE_GROUP"