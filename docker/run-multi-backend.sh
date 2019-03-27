#!/bin/bash

# Generate the *.Backend-*.cfg files
# /root/templates/backends.yml is setup as a configmap and mounted at that location
BACKENDS=/root/templates/backends.yml OUTPUT=/opt/instana/agent/etc/instana python /root/templates/backends.py
# Copy all of the generated backends to instana
#cp /root/templates/backends/*.cfg /opt/instana/agent/etc/instana/

echo "Starting Instana Agent ..."
exec /opt/instana/agent/bin/karaf daemon
