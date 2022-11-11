# Creating Cluster with `kubeadm`

<https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/>

# Step 1 - Configure all nodes

Make sure that the br_netfilter module is loaded before this step. This can be done by running `lsmod | grep br_netfilter`.

To load it explicitly call

```
sudo modprobe br_netfilter

# Login as Root
sudo -i

# Update 
echo 1 > /proc/sys/net/ipv4/ip_forward

exit

cat /proc/sys/net/ipv4/ip_forward
```

Create new kernel parameters, Letting iptables see bridged traffic, you should ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config e.g.

```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

cat /etc/sysctl.d/k8s.conf

sudo sysctl --system
```


# Check Required Ports

<https://kubernetes.io/docs/reference/ports-and-protocols/>


Master Node 

```
sudo firewall-cmd --add-port=6443/tcp --permanent
sudo firewall-cmd --add-port=2379-2380/tcp --permanent
sudo firewall-cmd --add-port=10250/tcp --permanent
sudo firewall-cmd --add-port=10259/tcp --permanent
sudo firewall-cmd --add-port=10257/tcp --permanent
```


Worker Node
```
sudo firewall-cmd --add-port=10250/tcp --permanent
sudo firewall-cmd --add-port=30000-32767/tcp --permanent
```

# Step 2 - Install Contianer Runtime `containerd` on all nodes

<https://github.com/containerd/containerd/blob/main/docs/getting-started.md>

```
# download contianerd
wget https://github.com/containerd/containerd/releases/download/v1.6.9/containerd-1.6.9-linux-amd64.tar.gz

# download runc
wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64

# download cni plugins
wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz

# extract containerd
sudo tar Cxzvf /usr/local containerd-1.6.9-linux-amd64.tar.gz

# start containerd
# download the containerd.service unit file 
sudo wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -P /usr/local/lib/systemd/system/
sudo cat /usr/local/lib/systemd/system/containerd.service

sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# install runc 
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# install CNI plugins
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
```

## Configuring the `systemd` cgroup driver

```
# Create config file 
sudo mkdir -p /etc/containerd/
sudo touch /etc/containerd/config.toml
containerd config default > config.toml
sudo cp config.toml /etc/containerd/config.toml

cat /etc/containerd/config.toml
```

To use the systemd cgroup driver in /etc/containerd/config.toml with `runc`, set

```
sudo vi /etc/containerd/config.toml
```

```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
...
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

The systemd cgroup driver is recommended if you use cgroup v2.

If you apply this change, make sure to restart containerd:

```
cat /etc/containerd/config.toml
sudo systemctl restart containerd
```

# Step 3 - Installing `kubeadm`, `kubelet` and `kubectl` on all nodes

```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
```

# Step 4 - Initialize `controlplane` on kubemaster

Single master - without HA

Initialize Kubeadm

```
# check ip
ifconfig

# initialize k8s master
sudo kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=10.0.1.4
```

To start using your cluster, you need to run the following as a regular user:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

cat $HOME/.kube/config
```

```
kubectl get nodes
kubectl describe node kubemaster
```

# Step 5: Choose Pod network add-on

You must deploy a Container Network Interface (CNI) based Pod network add-on so that your Pods can communicate with each other. Cluster DNS (CoreDNS) will not start up before a network is installed.

See a list of add-ons that implement the Kubernetes networking model.

<https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy>

Weavenet - Pod Network solution

Before installing Weave Net, you should make sure the following ports are not blocked by your firewall: TCP `6783` and UDP `6783/6784`. For more details, see the FAQ.

```
sudo firewall-cmd --add-port=6783/tcp --permanent
sudo firewall-cmd --add-port=6783/udp --permanent
sudo firewall-cmd --add-port=6784/udp --permanent
```

Install Weavenet Pod Network solution

```
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

Wait for node to become ready
```
kubectl get nodes -w
```


# Step 6 - Join Worker Node

Open Ports on Worker nodes

```
# Worker Nodes
# Kubelet API
sudo firewall-cmd --add-port=10250/tcp --permanent

# Default port range for NodePort Services.
sudo firewall-cmd --add-port=30000-32767/tcp --permanent

# Weavenet 
sudo firewall-cmd --add-port=6783/tcp --permanent
sudo firewall-cmd --add-port=6783/udp --permanent
sudo firewall-cmd --add-port=6784/udp --permanent
```

On Kubemaster Generate Join Token
```
kubeadm token create --print-join-command
```

Join Worker Node
```
sudo kubeadm join 10.0.0.4:6443 --token ggv6hp.6j2nzkffpnrlvpke --discovery-token-ca-cert-hash sha256:1ddf6801a38f60d4c92e2e33aec9b2c98be4c991c968c7f3a4ce1d9110b539da
```