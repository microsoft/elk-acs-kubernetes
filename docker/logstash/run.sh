#!/bin/sh
log()
{
    echo "$1"
}

# The following environment variables have been set
# EVT_HUB_NS ${DIAG_EVT_HUB_NS}
# EVT_HUB_KEY_NAME ${DIAG_EVT_HUB_KEY_NAME}
# EVT_HUB_ACC_KEY ${DIAG_EVT_HUB_ACC_KEY}
# EVT_HUB_ENT_PATH ${DIAG_EVT_HUB_ENT_PATH}
# EVT_HUB_PART ${DIAG_EVT_HUB_PART}
# ELASTICSEARCH_URL "http://elasticsearch:9200"

# Install User Configuration from encoded string
#  echo "EVT_HUB_NS=$EVT_HUB_NS" > /logstash/config/logstash.conf
#  echo "EVT_HUB_KEY_NAME=$EVT_HUB_KEY_NAME" >> /logstash/config/logstash.conf
#  echo "EVT_HUB_ACC_KEY=$EVT_HUB_ACC_KEY" >> /logstash/config/logstash.conf
#  echo "EVT_HUB_ENT_PATH=$EVT_HUB_ENT_PATH" >> /logstash/config/logstash.conf
#  echo "EVT_HUB_PART=$EVT_HUB_PART" >> /logstash/config/logstash.conf
if [ "$EVT_HUB_NS" = "undefined" ]
then
  # No EH provided
  echo "input {" >> /logstash/config/logstash.conf
  echo "  beats { host => \"0.0.0.0\" port => 5043 }" >> /logstash/config/logstash.conf
  echo "}" >> /logstash/config/logstash.conf
  echo "output {elasticsearch {hosts => ['$ELASTICSEARCH_URL']}}" >> /logstash/config/logstash.conf
else
  # Install Logstash configuration
  log "Generating Logstash Config"
  log "Eventhub Plugin Input"
  echo "input {" >> /logstash/config/logstash.conf
  echo "  azurewadeventhub {key => '$EVT_HUB_ACC_KEY' username => '$EVT_HUB_KEY_NAME' eventhub => '$EVT_HUB_ENT_PATH'  namespace => '$EVT_HUB_NS' partitions => $EVT_HUB_PART}" >> /logstash/config/logstash.conf
  echo "}" >> /logstash/config/logstash.conf
  echo "output {elasticsearch {hosts => ['$ELASTICSEARCH_URL'] index => 'wad'}}" >> /logstash/config/logstash.conf
fi

log "Output logstash.conf"
cat /logstash/config/logstash.conf

# Configure Start
log "Configure start up service"
/logstash/bin/logstash -f /logstash/config/logstash.conf


