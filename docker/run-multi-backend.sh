#!/bin/bash

rm -rf /tmp/* /opt/instana/agent/etc/org.ops4j.pax.logging.cfg \
  /opt/instana/agent/etc/org.ops4j.pax.url.mvn.cfg  \
  /opt/instana/agent/etc/instana/configuration.yaml \
  /opt/instana/agent/etc/instana/com.instana.agent.main.config.Agent.cfg

cp /opt/instana/agent/etc/org.ops4j.pax.url.mvn.cfg.template /opt/instana/agent/etc/org.ops4j.pax.url.mvn.cfg
cp /root/configuration.yaml /opt/instana/agent/etc/instana
cp /root/org.ops4j.pax.logging.cfg /opt/instana/agent/etc
cp /root/configuration-header.yaml /opt/instana/agent/etc/instana/configuration-header.yaml


for file in /root/templates/backends/*.tmpl; do
    
  if [ -f "${file}" ]; then
    base_filename=$(basename -- "${file}")
    base_filename_extension="${base_filename##*.}"
    target_filename=${base_filename%.tmpl}
    # echo ${file}
    # echo ${base_filename}
    # echo ${base_filename_extension}
    echo "outputing template file "${file}" to "${target_filename}""
    cat "${file}" | gomplate > \
      /opt/instana/agent/etc/instana/${target_filename}
  fi
done


if [[ "${INSTANA_AGENT_HTTP_LISTEN}" != "" ]]; then
  echo -e "\nhttp.listen = ${INSTANA_AGENT_HTTP_LISTEN}" >> /opt/instana/agent/etc/instana/com.instana.agent.main.config.Agent.cfg
fi

if [ -d /host/proc ]; then
  export INSTANA_AGENT_PROC_PATH=/host/proc
fi

echo "Starting Instana Agent ..."
#exec /opt/instana/agent/bin/karaf daemon
