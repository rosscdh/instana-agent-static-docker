#!/bin/bash

rm -rf /tmp/* /opt/instana/agent/etc/org.ops4j.pax.logging.cfg \
  /opt/instana/agent/etc/org.ops4j.pax.url.mvn.cfg  \
  /opt/instana/agent/etc/instana/configuration.yaml \
  /opt/instana/agent/etc/instana/com.instana.agent.main.config.Agent.cfg

cp /root/org.ops4j.pax.logging.cfg /opt/instana/agent/etc
cp /opt/instana/agent/etc/org.ops4j.pax.url.mvn.cfg.template /opt/instana/agent/etc/org.ops4j.pax.url.mvn.cfg

cp /root/configuration.yaml /opt/instana/agent/etc/instana
cp /root/configuration-header.yaml /opt/instana/agent/etc/instana/configuration-header.yaml


cp /root/templates/backends/*.cfg /opt/instana/agent/etc/instana/

echo "Starting Instana Agent ..."
exec /opt/instana/agent/bin/karaf daemon
