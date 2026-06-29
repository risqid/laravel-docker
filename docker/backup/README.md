# Backup & Restore

Laravel Docker menyediakan mekanisme backup dan restore bawaan yang dirancang untuk deployment production sederhana tanpa bergantung pada package Laravel tambahan.

## Features

* PostgreSQL backup
* PostgreSQL restore
* Upload backup (`storage/app/public`)
* Upload restore
* Automatic pre-restore backup
* Local backup retention
* Remote backup (rclone)
* Remote backup retention
* Maintenance mode during restore
* Backup metadata validation
* Single `.tar.gz` archive
* End-to-end tested

---

# Backup Contents

Setiap backup berisi:

* PostgreSQL database (`pg_dump` custom format)
* Uploaded files (`storage/app/public`)
* `metadata.json`

Redis tidak dibackup karena digunakan sebagai cache, queue, dan session storage.

---

# Backup Workflow

Each backup follows the workflow below:

1. Backup PostgreSQL database
2. Backup uploaded files
3. Generate metadata
4. Create compressed archive
5. Apply local backup retention
6. Upload archive to remote storage (optional)
7. Apply remote backup retention (optional)

This workflow ensures that:

* backup retention is applied only after a successful archive creation;
* remote upload is performed only after a successful local backup;
* remote retention is executed only after a successful remote upload.

---

# Backup Location

Backup disimpan di host:

```text
/opt/backups
```

Format nama file:

```text
<app-name>_YYYY-MM-DD_HH-MM-SS.tar.gz
```

Contoh:

```text
laravel-docker_2026-06-27_15-18-29.tar.gz
```

---

# Create Backup

Jalankan:

```bash
./docker/backup/backup.sh
```

Contoh output:

```text
[INFO] Starting backup...

...

Backup completed successfully.

Archive:
/opt/backups/laravel-docker_2026-06-27_15-18-29.tar.gz
```

---

# Local Backup Retention

Only the newest local backups are kept automatically. Retention is applied only after a backup archive has been successfully created.

Configuration:

```dotenv
BACKUP_RETENTION_ENABLED=true
BACKUP_RETENTION_COUNT=7
```

---

# Remote Backup

Remote backup is optional and uses rclone to upload backup archives to supported cloud storage providers.

Supported providers include:

* Google Drive
* Backblaze B2
* Amazon S3
* Cloudflare R2
* Wasabi
* OneDrive
* Dropbox
* Any storage supported by rclone

Configuration:

```dotenv
BACKUP_REMOTE_ENABLED=true
BACKUP_REMOTE_NAME=backup
BACKUP_REMOTE_PATH=backups/laravel-docker
```

---

# Remote Backup Retention

Remote backup retention automatically removes old backup archives from the configured remote storage.

Configuration:

```dotenv
BACKUP_REMOTE_RETENTION_ENABLED=true
BACKUP_REMOTE_RETENTION_COUNT=30

# Restore Backup

Jalankan:

```bash
./docker/backup/restore.sh
```

Restore akan meminta konfirmasi sebelum data ditimpa.

---

# Restore Workflow

Restore dilakukan dengan urutan berikut:

1. Locate backup archive
2. Validate archive
3. Extract archive
4. Validate backup files
5. Validate metadata
6. Display backup information
7. User confirmation
8. Create automatic pre-restore backup
9. Enable Laravel maintenance mode
10. Restore uploads
11. Restore PostgreSQL database
12. Refresh storage link (if required)
13. Disable maintenance mode

---

# Automatic Pre-Restore Backup

Sebelum restore dimulai, sistem secara otomatis membuat backup baru dari kondisi aplikasi saat ini.

Tujuannya adalah menyediakan recovery point apabila administrator ingin membatalkan restore.

---

# Metadata

Setiap archive berisi `metadata.json`.

Contoh:

```json
{
  "backup_format": 1,
  "app_name": "laravel-docker",
  "app_version": "dev",
  "app_env": "production",
  "created_at": "2026-06-27T15:18:29+07:00",
  "backup_name": "laravel-docker",
  "database_file": "database.dump",
  "uploads_file": "uploads.tar"
}
```

Hanya `backup_format` yang digunakan untuk memastikan kompatibilitas restore.

Field lainnya bersifat informatif.

---

# Maintenance Mode

Restore dijalankan dalam Laravel maintenance mode untuk mencegah perubahan data selama proses berlangsung.

Jika restore gagal setelah maintenance mode aktif, aplikasi akan tetap berada dalam maintenance mode sehingga administrator dapat melakukan investigasi sebelum aplikasi kembali online.

---

# Requirements

Host harus memiliki:

* Docker Engine
* Docker Compose
* GNU tar

Optional:

* rclone (required only when using remote backups)

---

# Notes

* Backup dan restore dilakukan langsung ke container PostgreSQL.
* Restore tidak menggunakan PgBouncer.
* Archive dibuat menggunakan format `.tar.gz`.
* Database menggunakan `pg_dump` custom format.
* Backup dan restore telah diuji melalui end-to-end testing.

---

# Roadmap

Planned improvements:

* Remote restore
* Remote backup browser
* Google Drive guide
* Backblaze B2 guide
* Disaster Recovery guide
