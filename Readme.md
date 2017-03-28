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

Then adjust the values for the environment variables `VIRTUAL_HOST` and `VIRTUAL_HOST` in the `docker-compose.yml`.

```bash
$ cd caddy-proxy
$ docker-compose up
```





