# Використовуємо базовий образ з підтримкою C++
FROM ubuntu:20.04

# Оновлюємо систему та встановлюємо необхідні пакети
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Встановлюємо необхідний порт
EXPOSE 8081

# Копіюємо проект у контейнер
WORKDIR /app
COPY . .

# Збираємо проект
RUN ./configure && make

# Запускаємо сервер
CMD ["./HTTP_Server"]
