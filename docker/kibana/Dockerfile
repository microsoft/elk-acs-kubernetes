FROM java:8u111-jre

# Download & Configure kibana
EXPOSE 80

ENV KIBANA_VERSION 5.4.0
ENV PLATFORM linux-x86_64
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-${PLATFORM}.tar.gz"

RUN apt-get -y install software-properties-common\
  && wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add - \
  && add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" \

RUN cd /tmp \
  && echo "Install Kibana..." \
  && wget -O kibana.tar.gz "$DOWNLOAD_URL" \
  && tar -xf kibana.tar.gz \
  && mv kibana-$KIBANA_VERSION-$PLATFORM /kibana

RUN apt-get update && apt-get install -y openresty apache2-utils

RUN opm get pintsized/lua-resty-http bungle/lua-resty-session
COPY cp config/openidc.lua /usr/local/openresty/lualib/resty/openidc.lua

ENV SERVER_PORT 5601
ENV SERVER_HOST "localhost"
ENV ELASTICSEARCH_URL "http://elasticsearch:9200"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]