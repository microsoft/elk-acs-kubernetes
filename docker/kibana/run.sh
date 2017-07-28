#!/bin/sh

${PASSWORD:=azureuser}
${USERNAME:=azureuser}

echo ${PASSWORD} | htpasswd -c -i /etc/nginx/.htpasswd ${USERNAME}

service nginx start
service nginx reload
/kibana/bin/kibana --server.host=$SERVER_HOST --server.port=$SERVER_PORT --elasticsearch.url=$ELASTICSEARCH_URL