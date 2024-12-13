# Етап 1: збірка
FROM ubuntu:latest as builder

# Оновлюємо систему та встановлюємо необхідні інструменти
RUN apt-get update && apt-get install -y \
    build-essential \
    automake \
    autoconf \
    libtool \
    g++ \
    git && \
    rm -rf /var/lib/apt/lists/*

# Копіюємо файли
WORKDIR /build
COPY . .

# Конфігурація та збірка
RUN autoreconf --install && ./configure && make

# Етап 2: створення кінцевого образу
FROM alpine:latest
WORKDIR /app

# Встановлюємо необхідні бібліотеки для сумісності
RUN apk add --no-cache libc6-compat

# Копіюємо виконуваний файл з етапу збірки
COPY --from=builder /build/HTTP_Server /usr/local/bin/

# Перевірка прав на виконання
RUN chmod +x /usr/local/bin/HTTP_Server

# Встановлюємо порт
EXPOSE 8081

# Запускаємо сервер
CMD ["/usr/local/bin/HTTP_Server"]
