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

# No EH provided
echo "input {" > /logstash/config/logstash.conf
echo "  beats { host => \"0.0.0.0\" port => 5043 tags => ['beats']}" >> /logstash/config/logstash.conf
# Remove spaces in $EVT_HUB_ENT_PATH
log "EVT_HUB_ENT_PATH: " $EVT_HUB_ENT_PATH
eventHubs="${EVT_HUB_ENT_PATH//[[:space:]]/}"
log "eventHubs: " $eventHubs
for eventHub in $(echo $eventHubs | sed "s/,/ /g")
do
    echo "  azurewadeventhub {key => '$EVT_HUB_ACC_KEY' username => '$EVT_HUB_KEY_NAME' eventhub => '$eventHub'  namespace => '$EVT_HUB_NS' partitions => $EVT_HUB_PART tags => ['wad']}" >> /logstash/config/logstash.conf
done
echo "}" >> /logstash/config/logstash.conf
echo "output {" >> /logstash/config/logstash.conf
echo "  if [tags][0] == 'beats' {" >> /logstash/config/logstash.conf
echo "    elasticsearch {hosts => ['$ELASTICSEARCH_URL']}" >> /logstash/config/logstash.conf
echo "  } else if [tags][0] == 'wad' {" >> /logstash/config/logstash.conf
echo "    elasticsearch {hosts => ['$ELASTICSEARCH_URL'] index => 'wad'}" >> /logstash/config/logstash.conf
echo "  } else {" >> /logstash/config/logstash.conf
echo "    file {" >> /logstash/config/logstash.conf
echo "      path => '/var/log/logstash/other.log'" >> /logstash/config/logstash.conf
echo "    }" >> /logstash/config/logstash.conf
echo "  }" >> /logstash/config/logstash.conf
echo "}" >> /logstash/config/logstash.conf

log "Output logstash.conf"
cat /logstash/config/logstash.conf

# Configure Start
log "Configure start up service"
/logstash/bin/logstash -r -f /logstash/config/logstash.conf
