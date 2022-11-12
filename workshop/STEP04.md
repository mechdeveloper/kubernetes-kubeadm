# Step 4: Deploy Application on Kubernetes cluster

Checkout following blog to learn about basic kubernetes commands
<https://medium.com/@mechdeveloper/basic-kubernetes-k8s-commands-minikube-pods-services-a7572e8cc796>

Deploy an app

```
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
```

List your deployment

```
kubectl get deployments
```

Check existing pods

```
kubectl get pods
```

List current services from your cluster

```
kubectl get services
```

Create a new service and expose it to external traffic with `NodePort` as paramter

```
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
```

Describe a service
```
kubectl describe services/kubernetes-bootcamp
```

Scale up the service

```
kubectl scale deployments/kubernetes-bootcamp --replicas=4
```

Scale down the service
```
kubectl scale deployments/kubernetes-bootcamp --replicas=2
```


Rolling update, Update the image of your application

```
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2
```

Confirm an update

```
kubectl rollout status deployments/kubernetes-bootcamp
```

Rollback an update

```
kubectl rollout undo deployments/kubernetes-bootcamp
```