# AKS_Challenge

## Task 1: 
https://github.com/JulianOrganization/AKS_Challenge/actions/runs/11482897829/job/31957062717
```
az aks get-credentials --resource-group rg-knowing-monkey --name cluster-touched-gorilla

kubectl get nodes
```
## Task 2: 
### confimap.yaml erstellen:
```
echo '
apiVersion: v1
kind: ConfigMap
metadata:
  name: html-config
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>Hello World</title>
    </head>
    <body>
        <h1>Hello World</h1>
    </body>
    </html>
' > configmap.yaml
```

### deployment.yaml erstellen:
```
echo '
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: web
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: html-config
' > deployment.yaml
```

### service.yaml erstellen:
```
echo '
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: hello-world
' > service.yaml
```

### Cloud Shell Commands ausführen:
```
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl get service hello-world-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

### Ergebnis:
```
4.209.76.52
```

## Task3:
