.PHONY: all build login push run

NAME     := 'metrics/instana-agent-static-infra'
REGISTRY := 'artifactory-docker.edge.tmecosys.com'
TAG      := $$(git log -1 --pretty=%h)
VERSION  := ${NAME}:${TAG}
LATEST   := ${NAME}:latest

BUILD_REPO_ORIGIN=$$(git config --get remote.origin.url)
BUILD_COMMIT_SHA1:=$$(git rev-parse --short HEAD)
BUILD_COMMIT_DATE:=$$(git log -1 --date=short --pretty=format:%ct)
BUILD_BRANCH:=$$(git symbolic-ref --short HEAD)
BUILD_DATE:=$$(date -u +"%Y-%m-%dT%H:%M:%SZ")


all: build login push


build:
	docker build -t ${LATEST} -t ${REGISTRY}/${LATEST} -t ${REGISTRY}/${VERSION} \
		--build-arg INSTANA_AGENT_ENVIRONMENT=${INSTANA_AGENT_ENVIRONMENT} \
		--build-arg BUILD_COMMIT_SHA1=${BUILD_COMMIT_SHA1} \
		--build-arg BUILD_COMMIT_DATE=${BUILD_COMMIT_DATE} \
		--build-arg BUILD_BRANCH=${BUILD_BRANCH} \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg BUILD_REPO_ORIGIN=${BUILD_REPO_ORIGIN} \
		--build-arg FTP_PROXY=${INSTANA_AGENT_KEY} \
		. --no-cache

login:
	docker login ${REGISTRY}

push:
	docker push ${REGISTRY}/${LATEST}
	docker push ${REGISTRY}/${VERSION}
