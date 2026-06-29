#!/usr/bin/env bash

set -Eeuo pipefail

########################################
# Project
########################################

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly ENV_FILE="$PROJECT_ROOT/.env"

########################################
# Backup Configuration
########################################

readonly BACKUP_NAME="laravel-docker"
readonly BACKUP_DIR="/opt/backups"
readonly TMP_DIR="/tmp/laravel-backup"
readonly RESTORE_TMP_DIR="/tmp/laravel-restore"

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