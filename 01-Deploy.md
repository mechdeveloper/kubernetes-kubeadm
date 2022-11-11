
```
kubectl create deployment httpd-frontend --image=httpd:2.4-alpine --replicas=3 
kubectl expose deployment httpd-frontend --type="NodePort" --port 80
```