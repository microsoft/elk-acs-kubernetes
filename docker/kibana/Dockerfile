FROM java:8u111-jre

# Download & Configure kibana
EXPOSE 80

ENV KIBANA_VERSION 5.4.0
ENV PLATFORM linux-x86_64
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-${PLATFORM}.tar.gz"

RUN cd /tmp \
  && echo "Install Kibana..." \
  && wget -O kibana.tar.gz "$DOWNLOAD_URL" \
  && tar -xf kibana.tar.gz \
  && mv kibana-$KIBANA_VERSION-$PLATFORM /kibana

RUN apt-get update && apt-get install -y nginx apache2-utils

COPY nginx-site.conf /etc/nginx/sites-available/default

ENV SERVER_PORT 5601
ENV SERVER_HOST "localhost"
ENV ELASTICSEARCH_URL "http://elasticsearch:9200"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]