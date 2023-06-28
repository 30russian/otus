# Настройка

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
helm install nginx ingress-nginx/ingress-nginx --namespace otus -f cicd/helm/nginx_ingress.yaml
```

## Установка и настройка Postrges
```bash
helm install rdbms1 -f cicd/helm/postgres_values.yaml oci://registry-1.docker.io/bitnamicharts/postgresql
```

## Прописывание хостов
```bash
minikube node list
```
Полученный адрес узла необходимо прописать в файле `/etc/hosts` для хоста `arch.homework`

## Настройка Skaffold
```bash
skaffold init -k cicd/kubernetes/deployment.yaml -k cicd/kubernetes/service.yaml
```

## Настройка окружения разработчика
```bash
poetry install
poetry shell
```

# Подготовка артефактов

## Building
Для сборки проекта необходимо запустить
```bash
make all
```
В локальном репозитории docker образов появится образ `30russian/otus:1.0.0`
## Pushing
Run
```bash
docker push 30russian/otus:1.0.0
```

# Running
## Minikube
Запускаем всё вручную
```bash
cd cicd/kubernetes
kubectl apply -f otus-configmap.yaml,otus-secret.yaml,job.yaml
kubectl apply -f deployment.yaml,service.yaml,ingress.yaml
```
Или для редеплоя используем Skaffold
```bash
cd cicd/kubernetes
kubectl apply -f job.yaml
kubectl apply -f otus-configmap.yaml,otus-secret.yaml,ingress.yaml
cd -
skaffold dev --trigger='manual'
```

# QA

## Linters
Run
```bash
hadolint Dockerfile
```

## Test
### Kubernetes
Run
```bash
curl http://arch.homework/health
curl http://arch.homework/users
```

### API tests
Сначала устанавливаем newman:
```bash
npm install -g newman
```
Потом натравливаем его на нашу коллекцию
```bash
newman run -e minikube.postman_environment.json allinone.postman_collection.json
```