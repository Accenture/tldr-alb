#!/bin/bash

#
# Starts an nginx server that simulates a new service endpoint
#

if [ "$1" == "" ]; then
	SERVICE_ID="1"
else
	SERVICE_ID=$1
fi

echo "service $SERVICE_ID" > ./files/index_$SERVICE_ID.html

echo "Starting service $SERVICE_ID"
docker run -v $(pwd)/files/index_$SERVICE_ID.html:/usr/share/nginx/html/index.html:ro \
           -e SERVICE_TAGS=tldr.type:rest,tldr.app:testapp,tldr.port:80 \
           -e SERVICE_NAME=service${SERVICE_ID}_testapp \
           -p 80 -p 443 -d \
           --name service${SERVICE_ID}_testapp_1 \
           nginx

docker run -v $(pwd)/files/index_$SERVICE_ID.html:/usr/share/nginx/html/index.html:ro \
           -e SERVICE_TAGS=tldr.type:rest,tldr.app:testapp,tldr.port:80 \
           -e SERVICE_NAME=service${SERVICE_ID}_testapp \
           -p 80 -p 443 -d \
           --name service${SERVICE_ID}_testapp_2 \
           nginx