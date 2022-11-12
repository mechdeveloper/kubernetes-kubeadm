# Step 1: Create Infrastructure in Azure using Terraform

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