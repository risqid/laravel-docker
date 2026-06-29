#!/usr/bin/env bash

set -Eeuo pipefail
BACKUP_ARCHIVE=""

backup_database() {

    info "Creating PostgreSQL backup..."

    local db_name
    local db_user
    local container_file="/tmp/$DATABASE_FILE"

    db_name="$(get_env DB_DATABASE)"
    db_user="$(get_env DB_USERNAME)"

    docker_compose exec -T "$POSTGRES_SERVICE" \
        pg_dump \
        --username="$db_user" \
        --format=custom \
        --file="$container_file" \
        "$db_name"

    docker_compose cp \
        "$POSTGRES_SERVICE:$container_file" \
        "$TMP_DIR/$DATABASE_FILE"

    docker_compose exec -T "$POSTGRES_SERVICE" \
        rm -f "$container_file" || true

    success "PostgreSQL backup created."

}

backup_uploads() {

    info "Creating uploads backup..."

    docker_compose exec -T "$APP_SERVICE" \
        tar \
        --create \
        --file=- \
        --directory="$UPLOADS_PATH" \
        . \
        > "$TMP_DIR/$UPLOADS_FILE"

    success "Uploads backup created."

}

create_metadata() {

    info "Creating metadata..."

    local created_at
    local app_name
    local app_version
    local app_env

    created_at="$(date --iso-8601=seconds)"
    app_name="$(get_env APP_NAME)"
    app_version="$(get_env APP_VERSION)"
    app_env="$(get_env APP_ENV)"

    created_at="$(date --iso-8601=seconds)"

cat > "$TMP_DIR/$METADATA_FILE" <<EOF
{
  "backup_format": 1,
  "app_name": "$app_name",
  "app_version": "$app_version",
  "app_env": "$app_env",
  "created_at": "$created_at",
  "backup_name": "$BACKUP_NAME",
  "database_file": "$DATABASE_FILE",
  "uploads_file": "$UPLOADS_FILE"
}
EOF

    success "Metadata created."

}

create_archive() {

    info "Creating backup archive..."

    local archive_name
    local archive_path

    archive_name="${BACKUP_NAME}_$(timestamp).tar.gz"
    archive_path="$BACKUP_DIR/$archive_name"

    tar \
        --create \
        --gzip \
        --owner=0 \
        --group=0 \
        --file="$archive_path" \
        --directory="$TMP_DIR" \
        "$DATABASE_FILE" \
        "$UPLOADS_FILE" \
        "$METADATA_FILE"
    
    BACKUP_ARCHIVE="$archive_path"
    success "Backup archive created."
}

perform_backup() {
    prepare_tmp_dir "$TMP_DIR"

    backup_database
    ensure_file_exists "$TMP_DIR/$DATABASE_FILE"

    backup_uploads
    ensure_file_exists "$TMP_DIR/$UPLOADS_FILE"

    create_metadata
    ensure_file_exists "$TMP_DIR/$METADATA_FILE"

    create_archive
    ensure_file_exists "$BACKUP_ARCHIVE"

    cleanup_tmp_dir "$TMP_DIR"
}