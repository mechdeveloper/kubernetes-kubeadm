# Step 1: Create Infrastructure in Azure using Terraform


Create a service principal using Azure CLI
```
az login 
az account list
az account set --subscription="SUBSCRIPTION_ID"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"


{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}

```

- `appId` is `client_id`
- `password` is `client_secret`
- `tenant` is `tenant_id`

Login with az cli using service principal
```
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
```

Configure Service Principal in Terraform 

Add workspace env variables in terraform cloud
```
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

Initialize terraform 
```
terraform init
```

Plan changes
```
terraform plan -out main.tfplan
```

Apply Changes
```
terraform apply main.tfplan
```

Check Output - Resource Group Name
```
echo "$(terraform output)"
```

Azure CLI to check Resource Group
```
az group show --name <resource_group_name>
```

Remove/destroy infra resources
```
terraform plan -destroy -out main.destroy.tfplan
```

Destroy infra
```
terraform apply main.destroy.tfplan
```