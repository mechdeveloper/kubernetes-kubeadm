# Step 2: Login to Virtual Machines 


Run `terraform output` to get the SSH private key and save it to a file.

```
terraform output -raw tls_private_key > id_rsa
```

Restrict read/write access to the owner of key file
```
chmod 600 id_rsa
```

Get the Public IP address of kubemaster virtual machine 
```
terraform output public_ip_address_kubemaster
```

Get the Public IP address of kubeworker virtual machine
```
terraform output public_ip_address_kubeworker
```

Use SSH to connect to the virutal machine
```
ssh -i id_rsa azureuser@<public_ip_address>
```

Check Linux Version on virtual machine
```
hostnamectl
```