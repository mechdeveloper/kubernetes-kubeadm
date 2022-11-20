#!/bin/bash

inventoryfile="/workspaces/kubernetes-demo/ansible/inventory"
ipkubemaster=`terraform output -raw public_ip_address_kubemaster`
ipkubeworker=`terraform output -raw public_ip_address_kubeworker`

if test -f "$inventoryfile"; then
    rm $inventoryfile
    echo "Removing existing $inventoryfile"
fi 

echo "Creating new $inventoryfile"
echo "kubemaster ansible_host=$ipkubemaster ansible_user=azureuser" >> $inventoryfile
echo "kubeworker ansible_host=$ipkubeworker ansible_user=azureuser" >> $inventoryfile
cat $inventoryfile

echo "Update ansible directory permissions" && chmod 755 "/workspaces/kubernetes-demo/ansible/"