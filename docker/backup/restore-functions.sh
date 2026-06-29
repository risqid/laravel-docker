#!/usr/bin/env bash

set -Eeuo pipefail
RESTORE_ARCHIVE=""

locate_backup() {

    if [[ $# -gt 0 ]]; then
        RESTORE_ARCHIVE="$1"
        return
    fi

    RESTORE_ARCHIVE="$(
        find "$BACKUP_DIR" \
            -maxdepth 1 \
            -type f \
            -name "${BACKUP_NAME}_*.tar.gz" \
            | sort \
            | tail -n1
    )"

    if [[ -z "$RESTORE_ARCHIVE" ]]; then
        error "No backup archive found."
        exit 1
    fi

}

validate_archive() {

    if [[ ! -f "$RESTORE_ARCHIVE" ]]; then
        error "Backup archive '$RESTORE_ARCHIVE' not found."
        exit 1
    fi

    if ! tar -tf "$RESTORE_ARCHIVE" >/dev/null 2>&1; then
        error "Backup archive is invalid."
        exit 1
    fi

}

extract_archive() {

    info "Extracting backup archive..."

    prepare_tmp_dir "$RESTORE_TMP_DIR"

    tar \
        --extract \
        --gzip \
        --file="$RESTORE_ARCHIVE" \
        --directory="$RESTORE_TMP_DIR"

    success "Backup archive extracted."

}

validate_backup() {

    info "Validating backup..."

    ensure_file_exists "$RESTORE_TMP_DIR/$DATABASE_FILE"
    ensure_file_exists "$RESTORE_TMP_DIR/$UPLOADS_FILE"
    ensure_file_exists "$RESTORE_TMP_DIR/$METADATA_FILE"

    success "Backup validated."

}

validate_metadata() {

    info "Validating metadata..."

    if ! grep -q '"backup_format":[[:space:]]*1' \
        "$RESTORE_TMP_DIR/$METADATA_FILE"; then

        error "Unsupported backup format."

        exit 1

    fi

    success "Metadata validated."

}

show_backup_information() {

    local app_name
    local app_version
    local app_env
    local created_at

    app_name="$(get_metadata app_name)"
    app_version="$(get_metadata app_version)"
    app_env="$(get_metadata app_env)"
    created_at="$(get_metadata created_at)"

    info "Backup information:"
    printf "  Application : %s\n" "$app_name"
    printf "  Version     : %s\n" "$app_version"
    printf "  Environment : %s\n" "$app_env"
    printf "  Created At  : %s\n\n" "$created_at"

}

confirm_restore() {

    printf "\n"
    warning "This operation will overwrite:"
    printf "  - PostgreSQL database\n"
    printf "  - Uploaded files\n"
    printf "\n"

    read -r -p "Continue? [y/N]: " answer

    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            ;;
        *)
            info "Restore cancelled."
            exit 0
            ;;
    esac

}

maintenance_down() {

    info "Enabling maintenance mode..."

    artisan down

    success "Maintenance mode enabled."

}

maintenance_up() {

    info "Disabling maintenance mode..."

    artisan up

    success "Maintenance mode disabled."

}

automatic_backup() {

    info "Creating automatic backup..."

    perform_backup

    success "Automatic backup created."

    printf "Archive:\n"
    printf "%s\n\n" "$BACKUP_ARCHIVE"

}

restore_uploads() {

    info "Restoring uploads..."

    docker_compose exec -T "$APP_SERVICE" \
        find "$UPLOADS_PATH" \
        -mindepth 1 \
        -delete

    docker_compose exec -T "$APP_SERVICE" \
        tar \
        --extract \
        --file=- \
        --directory="$UPLOADS_PATH" \
        < "$RESTORE_TMP_DIR/$UPLOADS_FILE"

    success "Uploads restored."

}

restore_database() {

    info "Restoring PostgreSQL database..."

    local db_name
    local db_user

    db_name="$(get_env DB_DATABASE)"
    db_user="$(get_env DB_USERNAME)"

    cat "$RESTORE_TMP_DIR/$DATABASE_FILE" \
        | docker_compose exec -T "$POSTGRES_SERVICE" \
            pg_restore \
            --username="$db_user" \
            --dbname="$db_name" \
            --clean \
            --if-exists \
            --no-owner \
            --no-privileges \
            --exit-on-error

    success "PostgreSQL database restored."

}

restore_storage_link() {

    if storage_link_exists; then
        info "Storage link already exists."
        return
    fi

    info "Creating storage link..."

    artisan storage:link

    success "Storage link created."

}

perform_restore() {

    locate_backup "$@"

    validate_archive

    info "Using backup:"
    printf "%s\n\n" "$RESTORE_ARCHIVE"

    extract_archive

    validate_backup

    validate_metadata

    show_backup_information

    confirm_restore

    automatic_backup

    maintenance_down

    restore_uploads

    restore_database

    restore_storage_link

    maintenance_up

    success "Restore completed."

}