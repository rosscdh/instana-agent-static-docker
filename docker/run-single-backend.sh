#!/bin/bash

cat /root/com.instana.agent.main.sender.Backend.cfg.tmpl | gomplate > \
  /opt/instana/agent/etc/instana/com.instana.agent.main.sender.Backend.cfg

if [ -d /host/proc ]; then
  export INSTANA_AGENT_PROC_PATH=/host/proc
fi

echo "Starting Instana Agent ..."
exec /opt/instana/agent/bin/karaf daemon
