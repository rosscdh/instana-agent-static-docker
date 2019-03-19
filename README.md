# Instana Agent Static Docker

[![pipeline status](https://gitlab.tmecosys.net/nwot/platform-engineering/instana-agent-static-docker/badges/master/pipeline.svg)](https://gitlab.tmecosys.net/nwot/platform-engineering/instana-agent-static-docker/commits/master)

This build of the Instana agent includes all sensors. It requires proxy settings only for egress access to the ${INSTANA_AGENT_ENDPOINT}, which may either be for your self hosted Instana installation or for the Instana SaaS.


## Building

You can get your INSTANA_AGENT_KEY from `https://$YOUR_INSTANA_NAME.instana.io/ump/$YOUR_INSTANA_CUSTOMER/$YOUR_INSTANA_ENVIRONMENT/agentkeys/`

ensure that the INSTANA_AGENT_KEY is the right agent for the INSTANA_AGENT_ENVIRONMENT you are building for

## Setup your backend(s)

Setup the backends/backends.yml

The yaml file supports multiple backends by default

If you have a specific setup for a new region simply make a new backends-XXX.yml and set BUILD_BACKENDS=backends-XXX.yml at build time

Usually the /root/templates/backends.yml shoudl be setup as a configmap in kubernetes and this gets used to generate teh Backends-X.cfg at runtime

### Build for your agent environmnet

The following command will push to a repo specified in the makefile `metrics/instana-agent-static-infra-$INSTANA_AGENT_ENVIRONMENT`

```sh
REGISTRY=docker.io PREFIX=metrics/instana-agent-static-infra-special INSTANA_AGENT_KEY=123456 make build
```

## Environment Variables

```
INSTANA_AGENT_SCHEDULER_THREADS *default 4*
INSTANA_AGENT_HTTP_THREADS *default 4*
INSTANA_AGENT_USE_CLOUD-PROVIDER_ID *default true*
INSTANA_AGENT_MODE *default INFRASTRUCTURE* options: APM | INFRASTRUCTURE | OFF
INSTANA_AGENT_ENDPOINT
INSTANA_AGENT_ENDPOINT_PORT
INSTANA_AGENT_PROXY_HOST
INSTANA_AGENT_PROXY_PORT
INSTANA_AGENT_PROXY_PROTOCOL
INSTANA_AGENT_PROXY_USE_DNS
INSTANA_AGENT_PROXY_USER
INSTANA_AGENT_PROXY_PASSWORD
INSTANA_AGENT_KEY *provided in build*
INSTANA_AGENT_ORIGIN
```

*Note*

FTP_PROXY is being abused to pass in the agent key for the package download during docker build, we are doing this until docker build time secrets issue is resolved: [issue GH33343](https://github.com/moby/moby/issues/33343)

Download Prebuilt Image
=======================

The static image can be found on containers.instana.io and can be downloaded using the following commands:

docker login containers.instana.io -u _ -p <agent_key>

docker pull containers.instana.io/instana/release/agent/static:latest
