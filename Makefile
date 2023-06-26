WHL ?= otus-0.1.0-py3-none-any.whl

IMAGE ?= 30russian/otus:1.0.0

all : whl docker
.PHONY : all

.ONESHELL:
whl :
	poetry build
.PHONY : whl

docker : whl
	docker build -t ${IMAGE} ./
.PHONY : docker