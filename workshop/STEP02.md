# Step 2: Login to Virtual Machines 


Run `terraform output` to get the SSH private key and save it to a file.

```
terraform output -raw tls_private_key > id_rsa
```

Restrict read/write access to the owner of key file
```
chmod 600 id_rsa
```

Get the virtual machine public IP address of master
```
terraform output public_ip_address_kubemaster
```

Get the virtual machine Public IP address of master
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