#!/bin/bash

#
# Sets up the environment to be able to test the ALB container locally. One the components below have been
# initialized, run alb:
#
# docker run --name=web_lb -e SERVICE_TAGS=web -e SERVICE_NAME=web_lb --dns 172.17.0.1 -p 80:80 -p 1936:1936 -d tldr_alb -consul=$(docker-machine ip alb):8500
#
# Visit http://$(docker-machine ip alb):1936 (someuser/password) to verify that haproxy has correctly identified all hosts
#

echo "Starting development node"
docker-machine create -d virtualbox alb

# bootstrap consul
echo "Starting a single-node Consul cluster"
docker run -d -p 8500:8500 --name consul progrium/consul -server -bootstrap-expect 1

echo "Starting registrator"
# Note: this is an unofficial build of registrator that supports overlay networking; we should move back to the official build
# as soon as this fix has been merged into registrator
docker run -d -v /var/run/docker.sock:/tmp/docker.sock -h registrator --name registrator kidibox/registrator -internal consul://$(docker-machine ip alb):8500