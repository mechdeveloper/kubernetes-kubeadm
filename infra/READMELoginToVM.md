
Save SSH private key and save it to a file

```
terraform output -raw tls_private_key > id_rsa
```

Restrict read/write access to the key file
```
chmod 600 id_rsa
```

Get the virtual machine public IP address
```
terraform output public_ip_address
```

Use SSH to connect to the virutal machine
```
ssh -i id_rsa azureuser@<public_ip_address>
```

Check Linux Version
```
hostnamectl
```