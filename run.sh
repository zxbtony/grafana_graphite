#!/bin/bash -e

if [ "$1" = 'start_server' ] || [ "$#" == 0 ]; then
  : "${GF_PATHS_DATA:=/var/lib/grafana}"
  : "${GF_PATHS_LOGS:=/var/log/grafana}"
  : "${GF_PATHS_PLUGINS:=/var/lib/grafana/plugins}"

  chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_LOGS"
  chown -R grafana:grafana /etc/grafana

  if [ ! -z ${GF_AWS_PROFILES+x} ]; then
      mkdir -p ~grafana/.aws/
      touch ~grafana/.aws/credentials

      for profile in ${GF_AWS_PROFILES}; do
          access_key_varname="GF_AWS_${profile}_ACCESS_KEY_ID"
          secret_key_varname="GF_AWS_${profile}_SECRET_ACCESS_KEY"
          region_varname="GF_AWS_${profile}_REGION"

          if [ ! -z "${!access_key_varname}" -a ! -z "${!secret_key_varname}" ]; then
              echo "[${profile}]" >> ~grafana/.aws/credentials
              echo "aws_access_key_id = ${!access_key_varname}" >> ~grafana/.aws/credentials
              echo "aws_secret_access_key = ${!secret_key_varname}" >> ~grafana/.aws/credentials
              if [ ! -z "${!region_varname}" ]; then
                  echo "region = ${!region_varname}" >> ~grafana/.aws/credentials
              fi
          fi
      done

      chown grafana:grafana -R ~grafana/.aws
      chmod 600 ~grafana/.aws/credentials
  fi

  if [ ! -z ${GF_INSTALL_PLUGINS} ]; then
    OLDIFS=$IFS
    IFS=','
    for plugin in ${GF_INSTALL_PLUGINS}; do
      grafana-cli plugins install ${plugin}
    done
    IFS=$OLDIFS
  fi


  if [ -z $CARBON_CACHE_ENABLED ];then
  	sed -i 's/CARBON_CACHE_ENABLED=false/CARBON_CACHE_ENABLED=true/g' /etc/default/graphite-carbon
  	echo CONF:CARBON_CACHE_ENABLED=true
  else
  	sed -i "s/CARBON_CACHE_ENABLED=false/CARBON_CACHE_ENABLED=${CARBON_CACHE_ENABLED}/g" /etc/default/graphite-carbon
  	echo CONF:CARBON_CACHE_ENABLED=${CARBON_CACHE_ENABLED}
  fi

  if [ -z $ENABLE_LOGROTATION ];then
  	sed -i 's/ENABLE_LOGROTATION = False/ENABLE_LOGROTATION = True/g' /etc/carbon/carbon.conf
  	echo CONF:ENABLE_LOGROTATION = True
  else
  	sed -i "s/ENABLE_LOGROTATION = False/ENABLE_LOGROTATION = ${ENABLE_LOGROTATION}/g" /etc/carbon/carbon.conf
  	echo CONF:ENABLE_LOGROTATION = ${ENABLE_LOGROTATION}
  fi

  if [ -z $RETENTIONS ];then
  	sed -i 's/retentions = 60s:1d/retentions = 5s:90d,30s:180d,1m:1y/g' /etc/carbon/storage-schemas.conf
  	echo CONF:retentions = 5s:90d,30s:180d,1m:1y
  else
  	sed -i "s/retentions = 60s:1d/retentions = ${RETENTIONS}/g" /etc/carbon/storage-schemas.conf
  	echo CONF:retentions = ${RETENTIONS}
  fi

  echo "no"|graphite-manage syncdb
  chown _graphite:_graphite /var/lib/graphite/graphite.db
  service carbon-cache start

  cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-available
  a2dissite 000-default
  a2ensite apache2-graphite

  service apache2 start
  
  sh /add_datasource.sh &
  
  exec gosu grafana /usr/sbin/grafana-server  \
    --homepath=/usr/share/grafana             \
    --config=/etc/grafana/grafana.ini         \
    cfg:default.paths.data="$GF_PATHS_DATA"   \
    cfg:default.paths.logs="$GF_PATHS_LOGS"   \
    cfg:default.paths.plugins="$GF_PATHS_PLUGINS"

fi


exec "$@"
