- [Настройка](#настройка)
  - [Предварительная настройка k8s](#предварительная-настройка-k8s)
  - [Установка и настройка Nginx ingress контроллера](#установка-и-настройка-nginx-ingress-контроллера)
  - [Установка и настройка Postrges](#установка-и-настройка-postrges)
  - [Прописывание хостов](#прописывание-хостов)
  - [Настройка Skaffold](#настройка-skaffold)
  - [Настройка окружения разработчика](#настройка-окружения-разработчика)
    - [Установка k9s:](#установка-k9s)
  - [Установка и настройка Prometheus](#установка-и-настройка-prometheus)
  - [Пробросы необходимых портов](#пробросы-необходимых-портов)
- [Подготовка артефактов](#подготовка-артефактов)
  - [Building](#building)
  - [Pushing](#pushing)
- [Running](#running)
  - [Minikube](#minikube)
- [QA](#qa)
  - [Linters](#linters)
  - [Test](#test)
    - [Kubernetes](#kubernetes)
    - [API testing](#api-testing)
    - [Load testing](#load-testing)


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

### Установка k9s:
Скачиваем бинарник [здесь](https://github.com/derailed/k9s/releases) и потом устанавливаем его в систему:
```bash
sudo install k9s /usr/local/bin/
```

## Установка и настройка Prometheus
```bash
helm install otus-promet prometheus-community/kube-prometheus-stack -f cicd/helm/prometheus_values.yaml

kubectl apply -f cicd/kubernetes/pod-monitor.yaml
```

## Пробросы необходимых портов
Prometheus
```bash
kubectl port-forward services/otus-promet-kube-prometheu-prometheus 9090
```

Grafana:
```bash
kubectl port-forward service/otus-promet-grafana 3000:80
```
Теперь Grafana доступна по адресу http://localhost:3000 Логин/пароль: `admin/prom-operator`

Nginx ingress:
```bash
kubectl port-forward pod/nginx-ingress-nginx-controller-jmxhb 10254
```
Теперь можно посмотреть метрики, которые отдаёт Ingress по адресу http://localhost:10254/metrics

Otus app:
```bash
kubectl port-forward otus-deployment-5f554687c9-5rrlw 8002
```
Теперь можно посмотреть метрики, которые отдаёт наше приложение по адресу http://localhost:8002/metrics

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
kubectl apply -f otus-configmap.yaml,otus-secret.yaml,job.yaml
kubectl apply -f ingress.yaml
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

### API testing
Сначала устанавливаем newman:
```bash
npm install -g newman
```
Потом натравливаем его на нашу коллекцию
```bash
newman run -e minikube.postman_environment.json allinone.postman_collection.json
```

### Load testing
Сначала скачиваем и устанавливаем Grafana K6 ([deb-пакет](https://github.com/grafana/k6/releases)) и утилиту для конвертации postman-коллекции в k6 скрипт:
```bash
npm install -D @apideck/postman-to-k6
```

Конвертируем нашу postman-коллекцию в k6 скрипт:
```bash
npx @apideck/postman-to-k6 allinone.postman_collection.json -e minikube.postman_environment.json -o k6-script.js
```

Натравливаем k6 на этот скрипт (10 виртуальных пользователей в течение 10 минут):
```bash
k6 run --vus 10 --duration 10m k6-script.js
```

Заставляем newman запускать нашу postman-коллекцию 2000 раз
```bash
newman run -e minikube.postman_environment.json -n 2000 allinone.postman_collection.json
```