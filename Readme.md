# caddy-proxy

caddy-proxy automatically generates [Caddy](https://caddyserver.com/) reverse proxy configurations for docker containers like [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) for Nginx.

## Usage

The template generation only works with docker-compose file version 2.

First, you'll need to create an external docker network named 'caddy-proxy' (or change the name in compose file).

```bash
$ docker network create -d bridge caddy-proxy
```

Then Clone this repository.

```bash
$ git clone https://github.com/drlogout/caddy-proxy
```

Adjust the values for the environment variables `VIRTUAL_HOST` and `LETSENCRYPT_EMAIL` in the `docker-compose.yml`.

```yaml
  app1:
    container_name: nginx
    image: nginx
    networks:
      - proxy-tier
    environment:
      VIRTUAL_HOST: "<YOUR FQDN>"
      VIRTUAL_NETWORK: "caddy-proxy"
      VIRTUAL_PORT: 80
    restart: always

  app2:
    container_name: apache
    image: httpd
    networks:
      - proxy-tier
    environment:
      VIRTUAL_HOST: "<YOUR FQDN>"
      VIRTUAL_NETWORK: "caddy-proxy"
      VIRTUAL_PORT: 80
    restart: always

  caddy-gen:
    container_name: caddy-gen
    image: drlogout/docker-gen-dind
    volumes:
      - "/var/run/docker.sock:/tmp/docker.sock:ro"
      - "./volumes/templates:/etc/docker-gen/templates:ro"
    volumes_from:
      - caddy
    environment:
      LETSENCRYPT_EMAIL: "<YOUR EMAIL>"
    command: -notify "docker restart caddy" -watch -wait 5s:30s /etc/docker-gen/templates/caddy.tmpl /etc/caddy/config/Caddyfile
    restart: always
    
    ...
```

Then start the containers.

```bash
$ cd caddy-proxy
$ docker-compose up
```





