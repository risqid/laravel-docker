#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/backup-functions.sh"
source "$SCRIPT_DIR/restore-functions.sh"

main() {

    info "Starting restore..."

    require_command docker
    require_command tar

    ensure_service_running "$POSTGRES_SERVICE"
    ensure_service_running "$APP_SERVICE"

    prepare_backup_dir
    trap 'cleanup_tmp_dir "$RESTORE_TMP_DIR"' EXIT

    perform_restore "$@"

}

main "$@"