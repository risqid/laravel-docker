#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/backup-functions.sh"

main() {

    info "Starting backup..."

    require_command docker
    require_command tar

    ensure_positive_integer \
        "$BACKUP_RETENTION_COUNT" \
        "BACKUP_RETENTION_COUNT"
    ensure_service_running "$POSTGRES_SERVICE"
    ensure_service_running "$APP_SERVICE"

    prepare_backup_dir

    perform_backup

    printf "\n"
    printf "Backup completed successfully.\n\n"
    printf "Archive:\n"
    printf "%s\n" "$BACKUP_ARCHIVE"

}

main "$@"