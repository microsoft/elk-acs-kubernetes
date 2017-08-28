FROM ubuntu:16.04

# Download & Configure logstash
# beats input on 5043
EXPOSE 5043

# Install Utilities
RUN echo "Installing utilities."
RUN apt-get update \
  && apt-get -y --force-yes install software-properties-common python-software-properties debconf-utils

# Install Java
RUN echo "Installing Java."
RUN add-apt-repository -y ppa:webupd8team/java \
  && apt-get update \
  && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections \
  && apt-get install -y --force-yes oracle-java8-installer

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
ARG DIAG_EVT_HUB_PART=undefined
ENV ELASTICSEARCH_URL "http://elasticsearch:9200"

RUN /run.sh -n ${DIAG_EVT_HUB_NS} -a ${DIAG_EVT_HUB_KEY_NAME} -k ${DIAG_EVT_HUB_ACC_KEY} -e ${DIAG_EVT_HUB_ENT_PATH} -p ${DIAG_EVT_HUB_PART} -i ${ELASTICSEARCH_URL}
