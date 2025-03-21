# Script to check Azure permissions before resource creation

param(
    [string]$subscriptionId = "d04fe7ab-c85a-4cbf-8acd-4363812fcea5",
    [string]$resourceGroupName = "langflow-resources"
)

# Check if Azure CLI is installed
$azCheck = Get-Command az -ErrorAction SilentlyContinue
if (!$azCheck) {
    Write-Host "Error: Azure CLI is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Function to check specific permission
function Test-AzurePermission {
    param (
        [string]$scope,
        [string]$action
    )
    
    try {
        $result = az role assignment list --include-groups --query "[?scope=='$scope'].{actions:roleDefinition.actions[]}" -o tsv
        if ($result -like "*$action*") {
            return $true
        }
        return $false
    } catch {
        Write-Host "Error checking permission: $action" -ForegroundColor Red
        return $false
    }
}

Write-Host "Checking Azure Permissions..." -ForegroundColor Cyan

# Check Azure login
try {
    $account = az account show --query name -o tsv
    Write-Host "Logged in as: $account" -ForegroundColor Green
} catch {
    Write-Host "Error: Not logged into Azure. Please run 'az login' first." -ForegroundColor Red
    exit 1
}

# Check subscription access
try {
    az account set --subscription $subscriptionId
    Write-Host "✓ Successfully accessed subscription" -ForegroundColor Green
} catch {
    Write-Host "✗ Cannot access subscription. Please verify your subscription ID and permissions." -ForegroundColor Red
    exit 1
}

# Array of required permissions to check
$requiredPermissions = @(
    @{
        scope = "/subscriptions/$subscriptionId"
        action = "Microsoft.Resources/subscriptions/resourcegroups/write"
        description = "Create Resource Groups"
    },
    @{
        scope = "/subscriptions/$subscriptionId"
        action = "Microsoft.ContainerRegistry/registries/write"
        description = "Create Container Registry"
    },
    @{
        scope = "/subscriptions/$subscriptionId"
        action = "Microsoft.ContainerService/managedClusters/write"
        description = "Create AKS Cluster"
    }
)

# Initialize missing permissions array
$missingPermissions = @()

# Check each permission
foreach ($permission in $requiredPermissions) {
    $hasPermission = Test-AzurePermission -scope $permission.scope -action $permission.action
    if ($hasPermission) {
        Write-Host "✓ Has permission: $($permission.description)" -ForegroundColor Green
    } else {
        Write-Host "✗ Missing permission: $($permission.description)" -ForegroundColor Red
        $missingPermissions += $permission
    }
}

# Summary
Write-Host "`nPermission Check Summary:" -ForegroundColor Cyan
if ($missingPermissions.Count -eq 0) {
    Write-Host "All required permissions are present. You can proceed with resource creation." -ForegroundColor Green
    Write-Host "Run: .\setup-azure-resources.ps1"
} else {
    Write-Host "Missing required permissions. Please have your Azure Administrator grant the following permissions:" -ForegroundColor Red
    foreach ($missing in $missingPermissions) {
        Write-Host "- $($missing.action) on scope $($missing.scope)" -ForegroundColor Yellow
    }
    Write-Host "`nExample command for Azure Administrator:"
    Write-Host "az role assignment create --role Contributor --assignee $account --scope /subscriptions/$subscriptionId"
    exit 1
}