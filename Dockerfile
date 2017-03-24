FROM debian:jessie
MAINTAINER Tony Zhang

ARG GRAFANA_VERSION

COPY ./run.sh /run.sh
COPY ./add_datasource.sh /add_datasource.sh

RUN apt-get update && echo "no"|apt-get install --force-yes -y graphite-carbon
RUN apt-get -y --no-install-recommends install libfontconfig curl ca-certificates apache2 libapache2-mod-wsgi&& \
    apt-get -y install graphite-web && \
    apt-get clean && \
    curl https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.2.0_amd64.deb > /tmp/grafana.deb && \
    dpkg -i /tmp/grafana.deb && \
    rm /tmp/grafana.deb && \
    curl -L https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64 > /usr/sbin/gosu && \
    chmod +x /usr/sbin/gosu && \
    chmod +x /run.sh && \
    rm -rf /var/lib/apt/lists/*

#VOLUME ["/var/lib/grafana", "/var/lib/grafana/plugins", "/var/log/grafana", "/etc/grafana"]

EXPOSE 3000 80 2003

ENTRYPOINT ["/run.sh"]
