FROM jwilder/docker-gen:0.7.3
MAINTAINER Christian Nolte hello@noltech.net

RUN apk -U add docker

ENTRYPOINT ["/usr/local/bin/docker-gen"]
