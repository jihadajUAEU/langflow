# Azure Prerequisites

Before running the CI/CD pipeline setup, ensure you have the following prerequisites in place:

## Required Azure RBAC Roles

You need the following Azure roles assigned to your account:

1. **Subscription Level Roles:**
   - `Contributor` or the following specific roles:
     - `Resource Group Contributor`
     - `Container Registry Contributor`
     - `AKS Cluster Admin`

2. **How to Check Your Roles:**
   ```powershell
   az role assignment list --assignee "<your-email>" --output table
   ```

3. **How to Get Roles Assigned:**
   - Contact your Azure Administrator to assign the required roles
   - They can use the following commands:
   ```powershell
   # Replace with your subscription ID
   $subscriptionId="d04fe7ab-c85a-4cbf-8acd-4363812fcea5"
   
   # Replace with your email/username
   $userPrincipalName="your-email@domain.com"
   
   # Assign Contributor role at subscription level
   az role assignment create \
       --role "Contributor" \
       --assignee-principal-type User \
       --assignee $userPrincipalName \
       --scope "/subscriptions/$subscriptionId"
   ```

## Installation Requirements

1. **PowerShell 7+**
   - Download from: https://github.com/PowerShell/PowerShell/releases
   - Verify installation:
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **Azure CLI**
   - The setup script will install this automatically if missing
   - Manual installation: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

3. **Azure Login**
   ```powershell
   az login
   ```
   - Verify you're using the correct subscription:
   ```powershell
   az account show
   ```
   - If needed, set the correct subscription:
   ```powershell
   az account set --subscription "<subscription-id>"
   ```

## Next Steps

Once you have confirmed you have the required roles and prerequisites:

1. Run the setup script:
   ```powershell
   .\scripts\setup-azure-resources.ps1
   ```

2. Follow the Azure DevOps setup guide in `docs/azure-devops-setup.md`

## Troubleshooting

If you see "AuthorizationFailed" errors:

1. Verify your Azure CLI login status:
   ```powershell
   az account show
   ```

2. Check your current role assignments:
   ```powershell
   az role assignment list --assignee "<your-email>" --output table
   ```

3. Request necessary permissions from your Azure Administrator

4. After receiving new roles, refresh your credentials:
   ```powershell
   az login
   ```

5. Clear Azure CLI token cache if needed:
   ```powershell
   az account clear
   az login