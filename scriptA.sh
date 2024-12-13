#!/bin/bash

# Docker image
IMAGE="qurtis99/http-server:latest"

# Контейнерні імена та відповідні ядра CPU
CONTAINERS=("srv1" "srv2" "srv3")
CORES=("0" "1" "2")

# Таймер перевірки
CHECK_INTERVAL=120  # 2 хвилини
CPU_THRESHOLD=50    # Поріг завантаженості CPU у відсотках

# Функція запуску контейнера
run_container() {
    local container=$1
    local core=$2
    
    if docker ps -a --format "{{.Names}}" | grep -q "^$container$"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Контейнер $container вже існує. Видаляємо його."
        docker rm -f "$container"
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S'): Запуск контейнера $container на ядрі CPU #$core."
    docker run -d --name "$container" --cpuset-cpus="$core" -p 808"$core":8081 "$IMAGE"
}

# Функція зупинки контейнера
stop_container() {
    local container=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Зупинка контейнера $container."
    docker stop "$container" && docker rm "$container"
}

# Функція перевірки завантаження CPU контейнера
check_cpu_usage() {
    local container=$1
    local usage=$(docker stats --no-stream --format "{{.CPUPerc}}" "$container" | sed 's/%//')
    echo "$usage"
}

# Функція перевірки та оновлення образу
update_image_if_needed() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Перевірка оновлень для образу..."
    if docker pull "$IMAGE" | grep -q "Downloaded newer image"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Знайдено новий образ."
        return 0
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Новий образ відсутній."
        return 1
    fi
}

# Функція оновлення всіх контейнерів
refresh_containers() {
    for i in ${!CONTAINERS[@]}; do
        stop_container "${CONTAINERS[i]}"
        run_container "${CONTAINERS[i]}" "${CORES[i]}"
    done
}

# Основний цикл управління контейнерами
manage_containers() {
    local busy_containers=(0 0 0) # Масив для зберігання статусу завантаженості контейнерів

    while true; do
        for i in ${!CONTAINERS[@]}; do
            local container="${CONTAINERS[i]}"

            if docker ps --format "{{.Names}}" | grep -q "^$container$"; then
                local cpu_usage=$(check_cpu_usage "$container")

                if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
                    echo "$(date '+%Y-%m-%d %H:%M:%S'): Контейнер $container перевантажений з CPU: $cpu_usage%."
                    busy_containers[$i]=$((busy_containers[$i] + 1))

                    if (( busy_containers[$i] >= 2 && i < 2 )); then
                        run_container "${CONTAINERS[i+1]}" "${CORES[i+1]}"
                    fi
                else
                    busy_containers[$i]=0
                fi
            else
                run_container "$container" "${CORES[i]}"
            fi

            # Видалення неактивних контейнерів
            if [[ $i -gt 0 && $(echo "$cpu_usage < 1.0" | bc -l) -eq 1 ]]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S'): Контейнер $container неактивний з CPU: $cpu_usage%. Видаляємо його."
                stop_container "$container"
            fi
        done

        # Перевірка оновлень образу
        if update_image_if_needed; then
            refresh_containers
        fi

        sleep "$CHECK_INTERVAL"
    done
}

# Обробка сигналів завершення
trap "echo 'Завершення скрипту...'; exit 0" SIGINT SIGTERM

# Запуск управління контейнерами
manage_containers
