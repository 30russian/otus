# Настройка kubernetes

## Предварительная настройка k8s
```bash
minikube start
kubectl create namespace otus
kubectl config set-context --current --namespace=otus
````

## Установка и настройка Nginx ingress контроллера
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx/
helm repo update
helm install nginx ingress-nginx/ingress-nginx --namespace otus -f nginx_ingress.yaml
```

## Building
Run
```bash
docker build -t 30russian/otus ./
```
## Pushing
Run
```bash
docker push 30russian/otus
```

## Running
### Docker
Run
```bash
docker run -p 8000:8000 --rm -it 30russian/otus
```
### Minikube
Run
```bash
cd kubernetes && kubectl apply -f .
```

## Linters
Run
```bash
hadolint Dockerfile
```

## Test
### Docker
Run
```bash
curl http://localhost:8000/health/
```
### Kubernetes
Run
```bash
curl http://arch.homework/health
curl http://arch.homework/otusapp/studname/dfg
```