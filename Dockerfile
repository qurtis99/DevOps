# Етап 1: Збірка
FROM ubuntu:latest as builder

RUN apt-get update && apt-get install -y \
    build-essential \
    automake \
    autoconf \
    libtool \
    g++ \
    git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --branch branchHTTPserver https://github.com/qurtis99/DevOps.git
WORKDIR /build/DevOps
RUN autoreconf --install && ./configure && make
RUN ls -l /build/DevOps && file /build/DevOps/HTTP_Server

# Етап 2: Запуск
FROM ubuntu:latest
WORKDIR /app
COPY --from=builder /build/DevOps/HTTP_Server /usr/local/bin/HTTP_Server
RUN chmod +x /usr/local/bin/HTTP_Server
EXPOSE 8081
ENTRYPOINT ["/usr/local/bin/HTTP_Server"]
