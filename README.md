# Laravel Docker

> A production-ready Laravel Docker template for Laravel applications using PHP 8.4, PostgreSQL, PgBouncer, Redis, and Docker Compose.

This repository provides a consistent environment for both local development and production deployment while keeping the architecture simple, maintainable, and scalable.

---

# Features

## Runtime

* Laravel 13
* PHP 8.4 FPM
* Nginx
* PostgreSQL 16
* PgBouncer (Transaction Pooling)
* Redis 7

## Docker

* Multi-stage Dockerfile
* Docker Compose
* Health checks
* Named volumes
* Automatic `storage:link`
* Upload persistence
* Redis persistence

## Deployment

* GitHub Actions
* GitHub Container Registry (GHCR)
* Immutable Docker images
* Version-based deployment
* Rollback support

## Backup & Restore

* PostgreSQL backup
* Upload backup (`storage/app/public`)
* Restore automation
* Metadata generation
* rclone integration
* Disaster Recovery support

---

# Requirements

Before getting started, ensure the following software is installed:

* Docker Engine
* Docker Compose

---

# Local Development

## 1. Clone the repository

```bash
git clone https://github.com/risqid/laravel-docker.git
cd laravel-docker
```

## 2. Copy the environment file

```bash
cp .env.example .env
```

## 3. Start the containers

```bash
docker compose up -d
```

## 4. Generate the application key

> This only needs to be done once for a new installation.

```bash
docker compose exec app php artisan key:generate
```

## 5. Run database migrations

```bash
docker compose exec app php artisan migrate
```

## 6. Open the application

```
http://localhost
```

---

# Production Deployment

The production environment uses pre-built Docker images published to GitHub Container Registry (GHCR).

## 1. Prepare the server

* Install Docker Engine
* Install Docker Compose
* Clone or copy the deployment files
* Configure the production `.env`

## 2. Pull the latest image

```bash
docker compose pull
```

## 3. Start or update the application

```bash
docker compose up -d
```

## 4. Run migrations

```bash
docker compose exec app php artisan migrate --force
```

---

# Updating to a New Version

Pull the latest images:

```bash
docker compose pull
```

Restart the services:

```bash
docker compose up -d
```

Run migrations if required:

```bash
docker compose exec app php artisan migrate --force
```

---

# Backup & Restore

Backup and restore are documented separately.

Please refer to:

```
docker/backup/README.md
```

The backup system includes:

* PostgreSQL database backup
* Upload backup (`storage/app/public`)
* Restore automation
* Backup metadata
* rclone integration for off-site storage
* Disaster Recovery workflow

---

# Documentation

| File                      | Description                                 |
| ------------------------- | ------------------------------------------- |
| `DECISIONS.md`            | Architecture decisions and design rationale |
| `ROADMAP.md`              | Project roadmap and planned features        |
| `docker/backup/README.md` | Backup & Restore usage guide                |

---

# Project Philosophy

This project follows a few simple principles:

* Production-ready by default
* Keep the architecture simple
* Avoid unnecessary complexity
* Keep local and production environments consistent
* Secure by default
* Scale when needed
* Prefer automation over manual operations

---

# Contributing

Contributions are welcome.

Before proposing architectural changes, please read:

* `DECISIONS.md`
* `ROADMAP.md`

This helps keep the project consistent with its design philosophy.

---

# License

This project is licensed under the MIT License.
