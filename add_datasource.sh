#!/bin/bash

sleep 10

if [[ -z `curl -s 'http://admin:admin@localhost:3000/api/datasources' | grep graphite` ]];then
      curl 'http://admin:admin@localhost:3000/api/datasources' -X POST -H 'Content-Type:application/json;charset=UTF-8' --data-binary '{"name":"Graphite","type":"graphite","url":"http://localhost","access":"proxy","isDefault":true,"jsonData":{}}'
fi

