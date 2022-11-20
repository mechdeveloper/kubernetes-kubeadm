#!/bin/bash

keypath="/workspaces/kubernetes-demo/terraform/.key"
keyname="id_rsa"
keyfile="$keypath/$keyname"
echo "Key File: $keyfile"

if test -f "$keyfile"; then
    rm -r $keypath
    echo "Removing existing $keyfile "
fi 

echo "Creating new $keyfile"
mkdir -p $keypath  && touch $keyfile
terraform output -raw tls_private_key > $keyfile
echo "$keyfile created"
echo "Restrict read/write access" && chmod 600 $keyfile
