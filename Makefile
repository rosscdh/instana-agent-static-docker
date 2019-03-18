.PHONY: all build login push run tag run-single-backend run-multi-backend

default: build

PREFIX   := metrics/instana-agent-static
TAG      := $(shell git describe --tags --always)
REGISTRY := artifactory-docker.edge.tmecosys.com

BUILD_REPO_ORIGIN := $(shell git config --get remote.origin.url)
BUILD_COMMIT_SHA1 := $(shell git rev-parse --short HEAD)
BUILD_COMMIT_DATE := $(shell git log -1 --date=short --pretty=format:%ct)
BUILD_BRANCH := $(shell git symbolic-ref --short HEAD)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

all: tag login push

build:
	docker build -t ${PREFIX}:latest -t ${REGISTRY}/${PREFIX}:latest -t ${REGISTRY}/${PREFIX}:${TAG} \
		--build-arg BUILD_COMMIT_SHA1=${BUILD_COMMIT_SHA1} \
		--build-arg BUILD_COMMIT_DATE=${BUILD_COMMIT_DATE} \
		--build-arg BUILD_BRANCH=${BUILD_BRANCH} \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg BUILD_REPO_ORIGIN=${BUILD_REPO_ORIGIN} \
		--build-arg FTP_PROXY=${INSTANA_AGENT_KEY} \
		.

tag: build
	docker tag ${PREFIX}:latest ${REGISTRY}/${PREFIX}:$(shell docker run --rm --entrypoint cat ${PREFIX}:latest /instana-static-agent.version)

login:
	docker login ${REGISTRY}

push: tag
	docker push ${REGISTRY}/${PREFIX}:latest
	docker push ${REGISTRY}/${PREFIX}:${TAG}
	docker push ${REGISTRY}/${PREFIX}:$(shell docker run --rm --entrypoint cat ${PREFIX}:latest /instana-static-agent.version)

run-single-backend:
	docker run --rm -it \
		-e INSTANA_MULTI_BACKEND=false \
		-e INSTANA_INCLUDE_CONFIGURATION_HEADERS=true \
		-e INSTANA_AGENT_KEY=${INSTANA_AGENT_KEY} \
        -e INSTANA_AGENT_ENDPOINT=saas-eu-west-1.instana.io \
    	-e INSTANA_AGENT_ENDPOINT_PORT=443 \
		-v ${PWD}/docker/templates:/root/templates \
		-v ${PWD}/docker/run-multi-backend.sh:/opt/instana/agent/bin/run-multi-backend.sh \
		-v ${PWD}/docker/run-single-backend.sh:/opt/instana/agent/bin/run-single-backend.sh \
		-v ${PWD}/docker/run.sh:/opt/instana/agent/bin/run.sh \
		--entrypoint bash \
		${PREFIX}:latest

run-multi-backend:
	docker run --rm -it \
		-e INSTANA_MULTI_BACKEND=true \
		-e INSTANA_INCLUDE_CONFIGURATION_HEADERS=true \
		-e INSTANA_AGENT_KEY=${INSTANA_AGENT_KEY} \
        -e INSTANA_AGENT_ENDPOINT=saas-eu-west-1.instana.io \
    	-e INSTANA_AGENT_ENDPOINT_PORT=443 \
		-v ${PWD}/docker/templates:/root/templates \
		-v ${PWD}/docker/run-multi-backend.sh:/opt/instana/agent/bin/run-multi-backend.sh \
		-v ${PWD}/docker/run-single-backend.sh:/opt/instana/agent/bin/run-single-backend.sh \
		-v ${PWD}/docker/run.sh:/opt/instana/agent/bin/run.sh \
		--entrypoint bash \
		${PREFIX}:latest


shell:
	docker run --rm -it \
		-e INSTANA_MULTI_BACKEND=true \
		-e INSTANA_INCLUDE_CONFIGURATION_HEADERS=true \
		-e INSTANA_AGENT_KEY=${INSTANA_AGENT_KEY} \
		--entrypoint bash \
		${PREFIX}:latest
