FROM debian:stable-20211011-slim AS litestream_downloader

ARG litestream_version="v0.3.9"
ARG litestream_binary_tgz_filename="litestream-${litestream_version}-linux-amd64-static.tar.gz"

WORKDIR /litestream

RUN set -x && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ca-certificates \
      wget
RUN wget "https://github.com/benbjohnson/litestream/releases/download/${litestream_version}/${litestream_binary_tgz_filename}"
RUN tar -xvzf "${litestream_binary_tgz_filename}"

FROM gotify/server

COPY --from=litestream_downloader /litestream/litestream /app/litestream
COPY ./docker_entrypoint /app/docker_entrypoint
COPY ./litestream.yml /etc/litestream.yml

RUN ["chmod", "+x", "/app/docker_entrypoint"]

# Frequency that database snapshots are replicated.
ENV DB_SYNC_INTERVAL="1s"

ENTRYPOINT ["/app/docker_entrypoint"]