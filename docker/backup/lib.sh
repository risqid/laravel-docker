#!/usr/bin/env bash

set -Eeuo pipefail

########################################
# Validation
########################################

require_command() {

    local command="$1"

    if ! command -v "$command" >/dev/null 2>&1; then
        error "Required command '$command' is not installed."
        exit 1
    fi

}

ensure_file_exists() {

    local file="$1"

    if [[ ! -f "$file" ]]; then
        error "Required file '$file' was not created."
        exit 1
    fi

}

ensure_service_running() {

    local service="$1"

    if [[ -z "$(docker_compose ps -q "$service")" ]]; then
        error "Service '$service' is unavailable."
        exit 1
    fi

}

########################################
# Timestamp
########################################

timestamp() {
    date +"%Y-%m-%d_%H-%M-%S"
}

########################################
# Logging
########################################

info() {
    printf "[INFO] %s\n" "$1"
}

success() {
    printf "[ OK ] %s\n" "$1"
}

warning() {
    printf "[WARN] %s\n" "$1"
}

error() {
    printf "[FAIL] %s\n" "$1" >&2
}

########################################
# Directories
########################################

prepare_backup_dir() {

    if [[ ! -d "$BACKUP_DIR" ]]; then
        error "Backup directory '$BACKUP_DIR' does not exist."
        exit 1
    fi

    if [[ ! -w "$BACKUP_DIR" ]]; then
        error "Backup directory '$BACKUP_DIR' is not writable."
        exit 1
    fi

}

prepare_tmp_dir() {

    local directory="$1"

    rm -rf "$directory"
    mkdir -p "$directory"

}

cleanup_tmp_dir() {

    local directory="$1"

    rm -rf "$directory"

}

########################################
# Docker Compose
########################################

docker_compose() {
    docker compose "$@"
}

########################################
# Laravel
########################################

artisan() {

    docker_compose exec -T "$APP_SERVICE" \
        php artisan "$@"

}


storage_link_exists() {

    docker_compose exec -T "$APP_SERVICE" \
        test -L public/storage

}

########################################
# Environment
########################################

get_env() {

    local key="$1"
    local value

    if [[ ! -f "$ENV_FILE" ]]; then
        error ".env file not found: $ENV_FILE"
        exit 1
    fi

    value="$(
        grep -E "^${key}=" "$ENV_FILE" \
            | head -n1 \
            | cut -d'=' -f2-
    )"

    if [[ -z "$value" ]]; then
        error "Environment variable '$key' not found."
        exit 1
    fi

    printf '%s\n' "$value"

}

get_metadata() {

    local key="$1"

    sed -n "s/.*\"${key}\":[[:space:]]*\"\([^\"]*\)\".*/\1/p" \
        "$RESTORE_TMP_DIR/$METADATA_FILE"

}