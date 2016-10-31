FROM debian:jessie
MAINTAINER Tony Zhang

ARG GRAFANA_VERSION

COPY ./run.sh /run.sh

RUN apt-get update && echo "no"|apt-get install --force-yes -y graphite-carbon
RUN apt-get -y --no-install-recommends install libfontconfig curl ca-certificates apache2 libapache2-mod-wsgi&& \
    apt-get -y install graphite-web && \
    apt-get clean && \
    curl https://grafanarel.s3.amazonaws.com/builds/grafana_3.1.1-1470047149_amd64.deb > /tmp/grafana.deb && \
    dpkg -i /tmp/grafana.deb && \
    rm /tmp/grafana.deb && \
    curl -L https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64 > /usr/sbin/gosu && \
    chmod +x /usr/sbin/gosu && \
    chmod +x /run.sh && \
    apt-get remove -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

#VOLUME ["/var/lib/grafana", "/var/lib/grafana/plugins", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000 80 2003

ENTRYPOINT ["/run.sh"]
