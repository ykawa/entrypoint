# entrypoint.sh

## About

This is an entrypoint to deter execution as root in linux.
maybe, it can also work on container orchestration.


## usage

### build

```Dockerfile
FROM debian:bullseye
ADD https://raw.githubusercontent.com/oggfogg/entrypoint/main/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ etc, etc ]
```

### run

```bash
$ docker build --no-cache --force-rm -t foo .
$ docker run --rm -i \
    -v $PWD:/work -w /work \
    --add-host host.docker.internal:host-gateway foo command
```