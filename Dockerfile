## NOTE: to retain configuration; mount a Docker volume, or use a bind-mount, on /var/lib/zerotier-one

FROM debian:buster-slim as builder

## Supports x86_64, x86, arm, and arm64

RUN apt-get update && apt-get install -y curl gnupg procps
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 0x1657198823e52a61  && \
    echo "deb http://download.zerotier.com/debian/buster buster main" > /etc/apt/sources.list.d/zerotier.list
RUN apt-get update && apt-get install -y zerotier-one=1.4.6

FROM debian:buster-slim
LABEL version="1.4.6"
LABEL description="Containerized ZeroTier One for use on CoreOS or other Docker-only Linux hosts bundled with script to act as a zerotier moon"
LABEL maintainer="Eduard Saller <github@saller.io>"

# ZeroTier relies on UDP port 9993
EXPOSE 9993/udp

RUN mkdir -p /var/lib/zerotier-one
COPY --from=builder /usr/sbin/zerotier-cli /zerotier-cli
COPY --from=builder /usr/sbin/zerotier-idtool /zerotier-idtool
COPY --from=builder /usr/sbin/zerotier-one /zerotier-one

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
EXPOSE 9993/udp
ENTRYPOINT ["/startup.sh"]
