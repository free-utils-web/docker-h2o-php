https://hub.docker.com/r/kodyph/h2o

Because https://hub.docker.com/r/fukata/h2o-php/
and https://hub.docker.com/r/lkwg82/h2o-http2-server
had not been updated for at lease one year.

And https://hub.docker.com/u/h2oserver
had not provided h2o server image.

I updated the h2o docker image here.

The system platform is Alpine-edge.
It has php 8.1. And h2o is 2.3.0-DEV with mruby(with ruby standard 2.x) and ssl function.

Using compose or portainer.io is recommended:

```yaml
version: '3.3'

services:
  h2o:
    image: kodyph/h2o:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - <host-h2o-dir>:/etc/h2o/ext/
      - <host-www-dir>:/var/www
    command: ["h2o", "-m", "master", "-c", "/etc/h2o/ext/h2o.conf"]
    deploy:
      restart_policy:
        condition: on-failure
```

Example `h2o.conf` could be found in github or official site (https://h2o.examp1e.net/configure/quick_start.html).
