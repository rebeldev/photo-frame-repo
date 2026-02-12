FROM alpine:3.19

RUN apk add --no-cache bash nfs-utils coreutils

COPY run.sh /run.sh
RUN chmod +x /run.sh
RUN ls -l /

CMD ["/run.sh"]

