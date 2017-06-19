FROM java:8u111-jre

# Download & Configure kibana
EXPOSE 5601

ENV KIBANA_VERSION 5.4.0
ENV PLATFORM linux-x86_64
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-${PLATFORM}.tar.gz"

RUN cd /tmp \
  && echo "Install Kibana..." \
  && wget -O kibana.tar.gz "$DOWNLOAD_URL" \
  && tar -xf kibana.tar.gz \
  && mv kibana-$KIBANA_VERSION-$PLATFORM /kibana


WORKDIR /kibana
#COPY config /kibana/config

ENV SERVER_PORT 5601
ENV SERVER_HOST "0.0.0.0"
ENV ELASTICSEARCH_URL "http://elasticsearch:9200"

CMD /kibana/bin/kibana --server.host=$SERVER_HOST --server.port=$SERVER_PORT --elasticsearch.url=$ELASTICSEARCH_URL
