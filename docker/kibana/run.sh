#!/bin/sh

${PASSWORD:=azureuser}
${USERNAME:=azureuser}
${SERVER_HOST:=0.0.0.0}
${SERVER_PORT:=5601}
${ELASTICSEARCH_URL:=http://elasticsearch:9200}

echo ${PASSWORD} | htpasswd -c -i /etc/nginx/.htpasswd ${USERNAME}

service nginx start
service nginx reload
/kibana/bin/kibana --server.host=${SERVER_HOST} --server.port=${SERVER_PORT} --elasticsearch.url=${ELASTICSEARCH_URL}