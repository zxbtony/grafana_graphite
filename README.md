# Grafana with Graphite Datasource

Graphite was installed in the container of Grafana

##Environment Variable
####CARBON_CACHE_ENABLED
  -Default=true
####ENABLE_LOGROTATION
  -Default = True
####RETENTIONS
  -Default = 5s:90d,30s:180d,1m:1y

##Volumes
* Graphite Data: /var/lib/graphite
* Grafana Data: /var/lib/grafana
* Graphite log: /var/log/grafana

##Ports
* Grafana Web: 3000
* Graphite Web: 80
* Graphite Data Receiver: 2003

## Usage
* Run Grafana & Graphite Server
```sh
$ docker run -rm -p 3000:3000 \
                 -p 80:80 \
                 -p 2003:2003 \
                 -v grafana_web:/var/lib/grafana \
                 -v graphite_data:/var/lib/graphite \
                 -v graphite_plugin:/var/log/grafana \
                 zxbtony/shadowsocks_server
```
##Docker Compose
[Example of Docker compose](https://github.com/shadowsocks/)

### Acknowledgement
[Shadowsocks](https://github.com/shadowsocks/shadowsocks/tree/master)
