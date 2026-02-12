FROM alpine:3.19

RUN apk add --no-cache bash coreutils jq cifs-utils

COPY run.sh /run.sh

RUN chmod 755 /run.sh

CMD ["/run.sh"]
