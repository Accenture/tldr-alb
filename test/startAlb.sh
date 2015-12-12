#!/bin/sh
#
# Starts a load balancer for the given service
#

if [ "$1" == "" ]; then
	SERVICE_ID="1"
else
	SERVICE_ID=$1
fi

echo "Starting load balancer for service $SERVICE_ID"
docker run --name=service${SERVICE_ID}_testapp_lb \
           -e TLDR_LB_SERVICE_NAME=service${SERVICE_ID}_testapp-80 \
           -e SERVICE_TAGS=tldr.type:lb,tldr.app:testapp \
           --dns 172.17.0.1 \
           -p 80:80 -p 1936:1936 \
           -d \
           tldr_alb -consul=$(docker-machine ip alb):8500