FROM ubuntu:18.04

#
# Handle the env info
#
ARG BUILD_COMMIT_SHA1
ARG BUILD_COMMIT_DATE
ARG BUILD_BRANCH
ARG BUILD_DATE
ARG BUILD_REPO_ORIGIN
 
LABEL BUILD_COMMIT_SHA1=$BUILD_COMMIT_SHA1 \
      BUILD_COMMIT_DATE=$BUILD_COMMIT_DATE \
      BUILD_BRANCH=$BUILD_BRANCH \
      BUILD_DATE=$BUILD_DATE \
      BUILD_REPO_ORIGIN=$BUILD_REPO_ORIGIN

ENV BUILD_COMMIT_SHA1=$BUILD_COMMIT_SHA1 \
    BUILD_COMMIT_DATE=$BUILD_COMMIT_DATE \
    BUILD_BRANCH=$BUILD_BRANCH \
    BUILD_DATE=$BUILD_DATE \
    BUILD_REPO_ORIGIN=$BUILD_REPO_ORIGIN

ENV LANG=C.UTF-8 \
    INSTANA_AGENT_KEY="" \
    INSTANA_AGENT_ENDPOINT="" \
    INSTANA_AGENT_ENDPOINT_PORT="" \
    INSTANA_AGENT_ZONE="" \
    INSTANA_AGENT_TAGS="" \
    INSTANA_AGENT_HTTP_LISTEN="" \
    INSTANA_AGENT_PROXY_HOST="" \
    INSTANA_AGENT_PROXY_PORT="" \
    INSTANA_AGENT_PROXY_PROTOCOL="" \
    INSTANA_AGENT_PROXY_USER="" \
    INSTANA_AGENT_PROXY_PASSWORD="" \
    INSTANA_AGENT_PROXY_USE_DNS=""

RUN apt-get update && \
    apt-get install -y gnupg2 ca-certificates && \
    echo "deb [arch=amd64] https://_:${FTP_PROXY}@packages.instana.io/agent/deb generic main" > /etc/apt/sources.list.d/instana-agent.list && \
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" > /etc/apt/sources.list.d/docker.list && \
    apt-key adv --fetch-keys "https://packages.instana.io/Instana.gpg" && \
    apt-key adv --fetch-keys "https://download.docker.com/linux/ubuntu/gpg" && \
    apt-get update && \
    apt-get install -y instana-agent-static inotify-tools gomplate docker-ce-cli containerd python-pip && \
    apt-get purge -y gnupg2 && \
    apt-get autoremove -y && \
    rm -rf /etc/apt/sources.list.d/instana-agent.list && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    fgrep -R 'description="Instana Agent"' /opt/instana/agent/system/com/instana/agent-feature/ | \
          grep -Po '\<feature name\=\"instana-agent\" description\=\"Instana\ Agent\" version\=\"(.+)\"\>' | \
          sed -rn 's/.*version="([^"]*)".*/\1/p' > /instana-static-agent.version && \
    find /opt/instana/agent/system -name *.jar | sed "s/.*\///" | sed "s/.jar//" > /instana-sensors.version

ADD org.ops4j.pax.logging.cfg /root/
ADD configuration.yaml /root/
ADD com.instana.agent.main.sender.Backend.cfg.tmpl /root/
ADD com.instana.agent.bootstrap.AgentBootstrap.cfg.tmpl /root/
ADD com.instana.agent.main.config.Agent.cfg.tmpl /root/
ADD configuration-header.yaml /root/
ADD run.sh /opt/instana/agent/bin

WORKDIR /opt/instana/agent

ENTRYPOINT ["./bin/run.sh"]
