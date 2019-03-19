FROM ubuntu:18.04

#
# Handle the env info
#
ARG BUILD_COMMIT_SHA1
ARG BUILD_COMMIT_DATE
ARG BUILD_BRANCH
ARG BUILD_DATE
ARG BUILD_REPO_ORIGIN
ARG BUILD_BACKENDS
 
LABEL BUILD_COMMIT_SHA1=$BUILD_COMMIT_SHA1 \
      BUILD_COMMIT_DATE=$BUILD_COMMIT_DATE \
      BUILD_BRANCH=$BUILD_BRANCH \
      BUILD_DATE=$BUILD_DATE \
      BUILD_REPO_ORIGIN=$BUILD_REPO_ORIGIN

ENV BUILD_COMMIT_SHA1=$BUILD_COMMIT_SHA1 \
    BUILD_COMMIT_DATE=$BUILD_COMMIT_DATE \
    BUILD_BRANCH=$BUILD_BRANCH \
    BUILD_DATE=$BUILD_DATE \
    BUILD_REPO_ORIGIN=$BUILD_REPO_ORIGIN \
    BACKENDS=$BUILD_BACKENDS

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
    pip install pyyaml jproperties && \
    fgrep -R 'description="Instana Agent"' /opt/instana/agent/system/com/instana/agent-feature/ | \
          grep -Po '\<feature name\=\"instana-agent\" description\=\"Instana\ Agent\" version\=\"(.+)\"\>' | \
          sed -rn 's/.*version="([^"]*)".*/\1/p' > /instana-static-agent.version && \
    find /opt/instana/agent/system -name *.jar | sed "s/.*\///" | sed "s/.jar//" > /instana-sensors.version

COPY docker /root
COPY backends/*.yml /root/templates/


COPY docker/run.sh /opt/instana/agent/bin/run.sh
COPY docker/run-multi-backend.sh /opt/instana/agent/bin/run-multi-backend.sh

# generate the backends based on the specifid yml file
RUN rm /opt/instana/agent/etc/instana/*Backend*.cfg || true
RUN BACKENDS=/root/templates/${BACKENDS} OUTPUT=/root/templates/backends /usr/bin/python /root/templates/backends.py
RUN cp /root/templates/backends/*.cfg /opt/instana/agent/etc/instana/

WORKDIR /opt/instana/agent

ENTRYPOINT ["/opt/instana/agent/bin/run.sh"]
