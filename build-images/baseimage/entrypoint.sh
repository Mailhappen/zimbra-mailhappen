#!/bin/bash
set -e

# Run supervisord when no CMD provided
if [ $# -eq 0 ]; then
  exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon
else
  exec "$@"
fi
