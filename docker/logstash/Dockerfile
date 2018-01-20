FROM ubuntu:16.04

# Download & Configure logstash
# beats input on 5043
EXPOSE 5043

# Install Utilities
RUN echo "Installing utilities."
RUN apt-get update \
  && apt-get -y --force-yes install software-properties-common python-software-properties debconf-utils wget

# Install Java
RUN echo "Installing Java."
RUN add-apt-repository -y ppa:openjdk-r/ppa \
  && apt-get update \
  && apt-get install -y openjdk-8-jre

ENV VERSION 5.4.0
ENV PLATFORM linux-x86_64
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/logstash/logstash-${VERSION}.tar.gz"

RUN cd /tmp \
  && echo "Install Logstash..." \
  && wget -O logstash.tar.gz "$DOWNLOAD_URL" \
  && tar -xf logstash.tar.gz \
  && mv logstash-$VERSION /logstash

RUN echo "Installing Azure WAD Event Hub Plugin..." \
  && /logstash/bin/logstash-plugin  install logstash-input-azurewadeventhub

COPY run.sh /run.sh
RUN chmod +x /run.sh

ARG DIAG_EVT_HUB_NS=undefined
ARG DIAG_EVT_HUB_KEY_NAME=undefined
ARG DIAG_EVT_HUB_ACC_KEY=undefined
ARG DIAG_EVT_HUB_ENT_PATH=undefined
ARG DIAG_EVT_HUB_PART=4
ARG DIAG_EVT_HUB_THR_WAIT=1

ENV EVT_HUB_NS ${DIAG_EVT_HUB_NS}
ENV EVT_HUB_KEY_NAME ${DIAG_EVT_HUB_KEY_NAME}
ENV EVT_HUB_ACC_KEY ${DIAG_EVT_HUB_ACC_KEY}
ENV EVT_HUB_ENT_PATH ${DIAG_EVT_HUB_ENT_PATH}
ENV EVT_HUB_PART ${DIAG_EVT_HUB_PART}
ENV EVT_HUB_THR_WAIT ${DIAG_EVT_HUB_THR_WAIT}

ENV ELASTICSEARCH_URL "http://elasticsearch:9200"

CMD ["/run.sh"]
