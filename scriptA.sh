#!/bin/bash

# Функція для запуску контейнера
launch_container() {
    local container_id=$1
    local cpu_core=$2

    if docker ps -a --format "{{.Names}}" | grep -q "^$container_id$"; then
        echo "$(date '+%m-%d %H:%M:%S'): Контейнер $container_id вже існує. Видаляю..."
        docker rm -f "$container_id"
    fi
    echo "$(date '+%m-%d %H:%M:%S'): Запуск контейнера $container_id на ядрі ЦП #$cpu_core"
    docker run --name "$container_id" --cpuset-cpus="$cpu_core" --network bridge -d qurtis99/http-server:latest
}

# Функція для зупинки контейнера
terminate_container() {
    local container_id=$1
    echo "$(date '+%m-%d %H:%M:%S'): Зупинка контейнера $container_id"
    docker kill "$container_id"
}

# Визначення індексу ядра ЦП для контейнера
get_cpu_core() {
    case $1 in
        srv1) echo "0" ;;
        srv2) echo "1" ;;
        srv3) echo "2" ;;
        *) echo "0" ;; # Ядро за замовчуванням
    esac
}

# Отримання навантаження на ЦП для контейнера
retrieve_cpu_load() {
    local container_id=$1
    docker stats --no-stream --format "{{.Name}} {{.CPUPerc}}" | grep "$container_id" | awk '{print $2}' | sed 's/%//'
}

# Завантаження нової версії образу Docker, якщо доступна
check_for_new_image() {
    echo "$(date '+%m-%d %H:%M:%S'): Перевірка наявності нового образу..."
    if docker pull qurtis99/http-server:latest | grep -q "Завантаження новішого образу"; then
        echo "$(date '+%m-%d %H:%M:%S'): Новий образ знайдено."
        return 0
    else
        echo "$(date '+%m-%d %H:%M:%S'): Новий образ не знайдено."
        return 1
    fi
}

# Оновлення всіх контейнерів
refresh_containers() {
    local containers=("srv1" "srv2" "srv3")
    for container in "${containers[@]}"; do
        echo "$(date '+%m-%d %H:%M:%S'): Оновлення $container..."
        terminate_container "$container"
        launch_container "$container" "$(get_cpu_core "$container")"
        echo "$(date '+%м-%d %H:%M:%S'): $container оновлено."
    done
}

# Моніторинг і управління контейнерами
manage_containers() {
    local srv1_busy=0
    local srv2_busy=0
    local srv3_idle=0

    while true; do
        if docker ps --format "{{.Names}}" | grep -q "^srv1$"; then
            local cpu_srv1=$(retrieve_cpu_load "srv1")
            if (( $(echo "$cpu_srv1 > 47.0" | bc -l) )); then
                srv1_busy=$((srv1_busy + 1))
                if (( srv1_busy >= 2 )); then
                    echo "$(date '+%m-%d %H:%M:%S'): srv1 зайнятий. Запуск srv2..."
                    if ! docker ps --format "{{.Names}}" | grep -q "^srv2$"; then
                        launch_container "srv2" 1
                    fi
                fi
            else
                srv1_busy=0
            fi
        else
            launch_container "srv1" 0
        fi

        if docker ps --format "{{.Names}}" | grep -q "^srv2$"; then
            local cpu_srv2=$(retrieve_cpu_load "srv2")
            if (( $(echo "$cpu_srv2 > 52.0" | bc -l) )); then
                srv2_busy=$((srv2_busy + 1))
                if (( srv2_busy >= 2 )); then
                    echo "$(date '+%m-%d %H:%M:%S'): srv2 зайнятий. Запуск srv3..."
                    if ! docker ps --format "{{.Names}}" | grep -q "^srv3$"; then
                        launch_container "srv3" 2
                    fi
                fi
            else
                srv2_busy=0
            fi
        fi
            for container in srv3; do
            if docker ps --format "{{.Names}}" | grep -q "^$container$"; then
                local cpu=$(retrieve_cpu_load "$container")
                if (( $(echo "$cpu < 1.0" | bc -l) )); then
                    if [[ "$container" == "srv3" ]]; then
                        srv3_idle=$((srv3_idle + 1))
                        if (( srv3_idle >= 2 )); then
                            echo "$(date '+%м-%d %H:%M:%S'): $container неактивний. Зупинка..."
                            terminate_container "$container"
                        fi
                    fi
                else
                    [[ "$container" == "srv3" ]] && srv3_idle=0
                fi
            fi
        done

        if check_for_new_image; then
            refresh_containers
        fi
        sleep 120
    done
}

manage_containers
