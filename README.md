# AKS_Challenge

## Task 1: 
https://github.com/JulianOrganization/AKS_Challenge/actions/runs/11482897829/job/31957062717
```
az aks get-credentials --resource-group rg-knowing-monkey --name cluster-touched-gorilla

kubectl get nodes
```
## Task 2: 
### confimap.yaml erstellen:
Enthält die Webseite mit der Ausgabe "Hello World" an sich, die der NGINX-Webserver anzeigt.
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
Diese Datei legt fest, wie der Webserver bereitgestellt wird und die Verwendung der ConfigMap für den Inhalt.
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
Macht den Webserver über eine externe IP-Adresse zugänglich, sodass "Hello World" im Browser angezeigt wird.
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
Anwenden der YAML-Dateien und Abruf der IP-Adresse.
```
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### Ergebnis:
```
kubectl get svc hello-world-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Task3:
### Bereitstellung unter mehreren Knoten:
In Cluster gehen, Workloads, Create, YAML Datei, Code einfügen:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3  # Drei Replikate des NGINX Container werden erstellt.
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```
Damit stellt AKS automatisch sicher, dass eine hohe Verfügbarkeit und Ausfallsicherheit gewährleistet wird.

Link:
```
https://portal.azure.com/#view/Microsoft_Azure_ContainerService/AksK8ResourceMenuBlade/~/overview-Deployment/aksClusterId/%2Fsubscriptions%2F2fc0173e-cada-4000-82db-566c79d396db%2FresourceGroups%2Frg-knowing-monkey%2Fproviders%2FMicrosoft.ContainerService%2FmanagedClusters%2Fcluster-touched-gorilla/resource~/%7B%22kind%22%3A%22Deployment%22%2C%22metadata%22%3A%7B%22name%22%3A%22nginx-deployment%22%2C%22namespace%22%3A%22default%22%2C%22uid%22%3A%22921187a1-a63c-4f33-90dc-7ccfe61e5aef%22%7D%2C%22spec%22%3A%7B%22selector%22%3A%7B%22matchLabels%22%3A%7B%22app%22%3A%22nginx%22%7D%7D%7D%7D
```

### Instanzen sollen eine Round-Robin-Verteilung des Datenverkehrs erhalten
Dies wurde bereits in der service.yaml Datei sichergestell, welche einen LoadBalancer verwendet.
Dadurch wird der Datenverkehr autoamtisch im Round-Robin-Verfahren auf die verfügbaren Replikas verteilt.

### Container-Instanzen sollen je nach CPU-Last automatisch skalieren
Cloud-Shell öffnen, hpa.yaml Datei erstellen:
```
echo '
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 1 # Mindestens 1 Repikat
  maxReplicas: 10 # Maximal 10 Replikate
  targetCPUUtilizationPercentage: 50
' > hpa.yaml
```
Diese YAML-Datei sorgt dafür, dass die Anzahl der NGINX Replikate automatisch basierend auf der CPU-Last skaliert wird. Min: 1, Max: 10.

hpa.yaml anwenden:
```
kubectl apply -f hpa.yaml
```

hpa.yaml verifizieren:
```
kubectl get hpa
```

## Task 4
Installation des Ingress-Controller (NGINX) mit Helm in der Cloud Shell:
```
# Hinzufügen des Helm-Repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Installation des Ingress-Controllers
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace --namespace ingress-nginx
```

Erstellung des Selbstsigniertes Zertifikat:
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=IP_ADDRESS" # IP-Adresse eingefügt
kubectl create secret tls tls-secret --key tls.key --cert tls.crt
```

Öffentliche IP-Adresse des LoadBalancer-Service rausfinden:
```
kubectl get svc hello-world-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

IP-Adresse einfügen im folgenden Befehl und ausführen:
```
az network public-ip list --query "[?ipAddress=='IP_ADDRESS'].[name,id]" --output table
```
Aus der Tabelle vom Schritt davor die PUBLIC_IP_RESOURCE_ID eintragen:
```
az network public-ip update --ids PUBLIC_IP_RESOURCE_ID --dns-name helloworlddns
```

ingress.yaml erstellen in der Cloud Shell:
```
echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - helloworlddns.northeurope.cloudapp.azure.com
    secretName: tls-secret
  rules:
  - host: helloworlddns.northeurope.cloudapp.azure.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-world-service
            port:
              number: 80
' > ingress-tls.yaml
```

ingress.yaml anwenden:
```
kubectl apply -f ingress-tls.yaml
```

Ingress-Ressource überprüfen:
```
kubectl get ingress
```
