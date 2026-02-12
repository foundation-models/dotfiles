# IntApp AKS cluster reference

Reference details for working with IntApp AKS. Use this when running `az aks` commands, kubectl context, or deployment tooling.

## AKS cluster details

| Field | Value |
|-------|--------|
| **AKS name** | `aks-dev1-bravo-eastus` |
| **Subscription ID** | `11b16e25-0e5f-4e76-87bc-5f2e9adb26df` |
| **Resource group** | `aks-dev1-bravo-eastus` |

### Quick copy

```text
AKS name:         aks-dev1-bravo-eastus
Subscription ID:  11b16e25-0e5f-4e76-87bc-5f2e9adb26df
Resource group:   aks-dev1-bravo-eastus
```

### Example commands

```bash
# Set subscription
az account set --subscription 11b16e25-0e5f-4e76-87bc-5f2e9adb26df

# Get credentials for kubectl
az aks get-credentials --resource-group aks-dev1-bravo-eastus --name aks-dev1-bravo-eastus
```
