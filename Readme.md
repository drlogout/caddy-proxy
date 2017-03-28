# caddy-proxy

caddy-proxy automatically generates [Caddy](https://caddyserver.com/) reverse proxy configurations for docker containers like [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) for Nginx.

## Usage

The template generation only works with docker-compose file version 2.

First, you'll need to create an external docker network named 'caddy-proxy'.

```bash
$ docker network create -d bridge caddy-proxy
```

Then Clone this repository.

```bash
$ git clone https://github.com/drlogout/caddy-proxy
$ cd caddy-proxy
```

Set a proper email address for `LETSENCRYPT_EMAIL` in `caddy/docker-compose.yml`.

```yaml
version: "2"

networks:
  proxy-tier:
    external:
      name: caddy-proxy

services:
  caddy:
    container_name: caddy
    image: abiosoft/caddy
    # remove -ca=https://acme-staging.api.letsencrypt.org/directory in production
    command: --conf /etc/caddy/config/Caddyfile --log stdout -ca=https://acme-staging.api.letsencrypt.org/directory
    ports:
      - 80:80
      - 443:443
    volumes:
      - "../volumes/config:/etc/caddy/config"
      - "../volumes/certs:/etc/caddy/certs"
    environment:
      - CADDYPATH=/etc/caddy/certs
    networks:
      - proxy-tier
    restart: always

  caddy-gen:
    container_name: caddy-gen
    image: drlogout/docker-gen-dind
    volumes:
      - "/var/run/docker.sock:/tmp/docker.sock:ro"
      - "../volumes/templates:/etc/docker-gen/templates:ro"
    volumes_from:
      - caddy
    environment:
      LETSENCRYPT_EMAIL: "<YOUR EMAIL>"
    command: -notify "docker restart caddy" -watch -wait 5s:30s /etc/docker-gen/templates/caddy.tmpl /etc/caddy/config/Caddyfile
    restart: always

```

And start the `caddy` and `caddy-gen` containers.

```bash
$ cd caddy
$ docker-compose up -d
```

Then set the `VIRTUAL_HOST` variable to a fully qualified domain name in `app1/docker-compose.yml` (resp. in `app2/docker-compose.yml`).

```yaml
version: "2"

networks:
  proxy-tier:
    external:
      name: caddy-proxy

services:
  app1:
    container_name: app1
    image: httpd
    networks:
      - proxy-tier
    environment:
      VIRTUAL_HOST: "<YOUR FQDN>"
      VIRTUAL_NETWORK: "caddy-proxy"
      VIRTUAL_PORT: 80
    restart: always

```

And start the `app1` container (resp. `app2`).

```bash
$ cd ../app1
$ docker-compose up -d
```

Please note, that this `caddy` configuration uses the [Letsencrypt staging environment](https://letsencrypt.org/docs/staging-environment/). This means your browser will warn you about an insecure connection. For use in production remove the `-ca=https://acme-staging.api.letsencrypt.org/directory` flag in `caddy/docker-compose.yaml`.

