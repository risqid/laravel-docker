#!/bin/sh
set -e

php artisan storage:link >/dev/null 2>&1 || true

exec "$@"