#!/usr/bin/env bash

set -Eeuo pipefail

########################################
# Project
########################################

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly ENV_FILE="$PROJECT_ROOT/.env"

########################################
# Application
########################################

readonly APP_NAME="$(get_env APP_NAME)"
readonly APP_ENV="$(get_env APP_ENV)"
readonly APP_VERSION="$(get_env APP_VERSION)"

readonly BACKUP_NAME="$(
    printf '%s' "$APP_NAME" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-z0-9]/-/g' \
        | tr -s '-' \
        | sed 's/^-//; s/-$//'
)"

########################################
# Backup Configuration
########################################

readonly BACKUP_DIR="/opt/backups"
readonly TMP_DIR="/tmp/laravel-backup"
readonly RESTORE_TMP_DIR="/tmp/laravel-restore"

readonly BACKUP_RETENTION_ENABLED="$(get_env BACKUP_RETENTION_ENABLED)"
readonly BACKUP_RETENTION_COUNT="$(get_env BACKUP_RETENTION_COUNT)"

########################################
# Backup Files
########################################

readonly DATABASE_FILE="database.dump"
readonly UPLOADS_FILE="uploads.tar"
readonly METADATA_FILE="metadata.json"

########################################
# Docker Services
########################################

readonly APP_SERVICE="app"
readonly POSTGRES_SERVICE="postgres"

########################################
# Laravel
########################################

readonly UPLOADS_PATH="/var/www/html/storage/app/public"