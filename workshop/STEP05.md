# Step 5: Remove Infrastructure on Azure to save cost

Run `terraform plan` and specify the destroy flag.
```
terraform plan -destroy -out main.destroy.tfplan
```

Run `terraform apply` to apply the execution plan.
```
terraform apply main.destroy.tfplan
```

