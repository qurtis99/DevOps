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

# Клонуємо репозиторій з GitHub
RUN git clone --branch branchHTTPserver https://github.com/qurtis99/DevOps.git

WORKDIR /build/DevOps

# Конфігурація та збірка
RUN autoreconf --install && ./configure && make

# Перевірка наявності зібраного бінарного файлу
RUN test -f /build/DevOps/branchHTTPserver || (echo "Binary not found!" && exit 1)

# Етап 2: Запуск
FROM alpine:latest
WORKDIR /app

# Копіюємо виконуваний файл з етапу збірки
COPY --from=builder /build/DevOps/branchHTTPserver /usr/local/bin/branchHTTPserver

# Встановлюємо права на виконання
RUN chmod +x /usr/local/bin/branchHTTPserver

# Встановлюємо порт
EXPOSE 8081

# Запускаємо сервер
ENTRYPOINT ["/usr/local/bin/branchHTTPserver"]
