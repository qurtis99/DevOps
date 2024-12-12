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
COPY ./src ./src
COPY ./configure.ac ./configure.ac
COPY ./Makefile.am ./Makefile.am
COPY ./tests ./tests

RUN autoreconf --install && ./configure && make

# Етап 2: Запуск
FROM ubuntu:latest
WORKDIR /app

# Копіюємо виконуваний файл
COPY --from=builder /build/HTTP_Server .

# Встановлюємо порт
EXPOSE 8081

# Запускаємо сервер
CMD ["./HTTP_Server"]
