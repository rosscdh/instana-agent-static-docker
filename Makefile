.PHONY: all build login push run
default: build

PREFIX   := 'metrics/instana-agent-static'
TAG      := $(shell git describe --tags --always)
REGISTRY := 'artifactory-docker.edge.tmecosys.com/metrics'

BUILD_REPO_ORIGIN := $(shell git config --get remote.origin.url)
BUILD_COMMIT_SHA1 := $(shell git rev-parse --short HEAD)
BUILD_COMMIT_DATE := $(shell git log -1 --date=short --pretty=format:%ct)
BUILD_BRANCH := $(shell git symbolic-ref --short HEAD)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

INSTANA_AGENT_KEY := 'Y5lnlZq9QAKph1MTDVhEKw'



all: build login push


build:
	docker build -t ${PREFIX}:latest -t ${REGISTRY}/${PREFIX}:latest -t ${REGISTRY}/${PREFIX}-infra:${TAG} \
		--build-arg BUILD_COMMIT_SHA1=${BUILD_COMMIT_SHA1} \
		--build-arg BUILD_COMMIT_DATE=${BUILD_COMMIT_DATE} \
		--build-arg BUILD_BRANCH=${BUILD_BRANCH} \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg BUILD_REPO_ORIGIN=${BUILD_REPO_ORIGIN} \
		--build-arg FTP_PROXY=${INSTANA_AGENT_KEY} \
		./docker

login:
	docker login ${REGISTRY}

push:
	docker push ${REGISTRY}/${LATEST}
	docker push ${REGISTRY}/${VERSION}

