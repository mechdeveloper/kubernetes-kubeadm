# Deploy on Kubernets 
<https://mechdeveloper.medium.com/basic-kubernetes-k8s-commands-minikube-pods-services-a7572e8cc796>

```
kubectl create deployment httpd-frontend --image=httpd:2.4-alpine --replicas=3 
kubectl expose deployment httpd-frontend --type="NodePort" --port 80
```

```
curl http://10.0.1.5:31900
```