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

# Клонування публічного репозиторію
WORKDIR /build
RUN git clone https://github.com/qurtis99/DevOps.git .

# Конфігурація та збірка
RUN autoreconf --install && ./configure && make

# Етап 2: створення кінцевого образу
FROM alpine:latest
WORKDIR /app

# Встановлюємо необхідні бібліотеки для сумісності
RUN apk add --no-cache libstdc++ libc6-compat

# Копіюємо виконуваний файл
COPY --from=builder /build/HTTP_Server .

# Перевірка прав на виконання
RUN chmod +x /app/HTTP_Server

# Встановлюємо порт
EXPOSE 8081

# Запускаємо сервер
CMD ["./HTTP_Server"]
