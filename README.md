# entrypoint.sh

## About

This is an entrypoint to deter execution as root in linux.
maybe, it can also work on container orchestration.


## usage

```Dockerfile
FROM xxxx
ADD https://raw.githubusercontent.com/oggfogg/entrypoint/main/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh", "--" ]
CMD [ etc, etc ]
```
