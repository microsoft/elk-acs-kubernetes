#!/bin/sh
help()
{
    echo ""
    echo ""
    echo "This script installs Logstash on Ubuntu, and configures it to be used with Event Hub plugin and user plugins/configurations."
    echo "Parameters:"
    echo "n - Event Hub namespace"
    echo "a - Event Hub shared access key name"
    echo "k - Event Hub shared access key"
    echo "e - Event Hub entity path"
    echo "p - Event Hub partitions"
    echo "i - Elasticsearch URL"
    echo ""
    echo ""
    echo ""
}

log()
{
    echo "$1" >> /var/lib/waagent/custom-script/download/0/stdout
}

#Loop through options passed
while getopts :hn:a:k:e:p:i: optname; do
    log "Option $optname set with value ${OPTARG}"
  case $optname in
    h)  #show help
      help
      exit 2
      ;;
    n) # eventhub plugin params
	  EH_NAMESPACE=${OPTARG}
      ;;
    a)
      EH_KEY_NAME=${OPTARG}
      ;;
    k)
      EH_KEY=${OPTARG}
      ;;
    e)
      EH_ENTITY=${OPTARG}
      ;;
    p)
      EH_PARTITIONS=${OPTARG}
      ;;
    i)
      ES_CLUSTER_URL=${OPTARG}
	  ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

log "EH_NAMESPACE="$EH_NAMESPACE
log "EH_KEY_NAME="$EH_KEY_NAME
log "EH_KEY="$EH_KEY
log "EH_ENTITY="$EH_ENTITY
log "EH_PARTITIONS="$EH_PARTITIONS
log "ES_CLUSTER_URL="$ES_CLUSTER_URL

# Install User Configuration from encoded string
if [ "$EH_NAMESPACE"="undefined" ]
then
  # No EH provided
  echo "input {" > /logstash/config/logstash.conf
  echo "  beats { host => \"0.0.0.0\" port => 5043 }" >> /logstash/config/logstash.conf
  echo "}" >> /logstash/config/logstash.conf
  echo "output {elasticsearch {hosts => ['$ES_CLUSTER_URL']}}" >> /logstash/config/logstash.conf
else
  # Install Logstash configuration
  log "Generating Logstash Config"
  log "Eventhub Plugin Input"
  echo "input {" > /logstash/config/logstash.conf
  echo "  azurewadeventhub {key => '$EH_KEY' username => '$EH_KEY_NAME' eventhub => '$EH_ENTITY'  namespace => '$EH_NAMESPACE' partitions => $EH_PARTITIONS}" >> /logstash/config/logstash.conf
  echo "}" >> /logstash/config/logstash.conf
  echo "output {elasticsearch {hosts => ['$ES_CLUSTER_URL'] index => 'wad'}}" >> /logstash/config/logstash.conf
fi

log "Output logstash.conf"
cat /logstash/config/logstash.conf

# Configure Start
log "Configure start up service"
/logstash/bin/logstash -f /logstash/config/logstash.conf


