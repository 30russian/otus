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
Run
```bash
docker run -p 8000:8000 --rm -it otustask_1.2
```

## Linters
Run
```bash
hadolint Dockerfile
```

## Test
Run
```bash
curl http://localhost:8000/health/
```