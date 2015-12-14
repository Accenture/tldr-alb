#  Application Load Balancer (ALB)

# Pre-requisites

- Docker Toolbox 1.9
- A running Docker engine provisioned via Docker Machine (assumed to be "alb" in the rest of this documentation):

```
docker-machine create -d virtualbox alb
```

# Building the container

```
docker build -t tldr_alb .
```

# How it works

TODO

# Running the container

Use the TLDR_LB_SERVICE_NAME environment variable, which identifies the names of the services that this load balancer should work with.

Variable SERVICE_TAGS should contain ```tldr.type:lb``` to identify this component as a load balancer, and ```tldr.app:testapp``` to identify the app to which this load balancer belongs.

Also, provide the URL to the Consul server with the service information as a parameter:

```
docker run --name=web_lb -e SERVICE_TAGS=web -e SERVICE_NAME=web_lb --dns 172.17.0.1 -p 80:80 -p 1936:1936 --rm alb -consul=$(docker-machine ip alb):8500
```

When ready, visit ```http://$(docker-machine ip alb):1936``` (someuser/password) to verify that both nginx containers are visible to haproxy. To access nginx, use ```http://$(docker-machine ip alb)/web-80``` (the 'web-80') part is a known issue.

# Test run

To load balance a service called service1_testapp-80, use the following command:

```
docker run --name=service1_testapp_lb -e TLDR_LB_SERVICE_NAME=service1_testapp-80  -e SERVICE_TAGS=tldr.type:lb,tldr.app:testapp -e SERVICE_NAME=service1_testapp_lb --dns 172.17.0.1 -p 80:80 -p 1936:1936 --rm pass_alb -consul=$(docker-machine ip alb):8500 -dry -once
```

Alternatively, use the scripts under the ```test``` folder:

1. Run ```tests/setup.sh``` to bootstrap a docker-machine host with the needed components (Consul and registrator)
2. Run ```tests/startService.sh 1``` to start two instances for the given service id/number
3. Run ```tests/startAlb.sh 1``` to start a load balancer for the given servie id/number. Must match with the parameter provided to startService.sh.

# Known issues

* Haproxy restart after updating configuration may not correctly work, and instead multiple haproxy instances are spawned. This eventually leads to a situation where haproxy configuration data is not correct and the entire load balancer has to be restarted. This is due to issue https://github.com/hashicorp/consul-template/issues/442, which should be monitored. In the meantime, we have downgraded to consul-template 0.10.0 where the issue cannot be reproduced.
* Zero downtime Haproxy reloads: http://engineeringblog.yelp.com/2015/04/true-zero-downtime-haproxy-reloads.html