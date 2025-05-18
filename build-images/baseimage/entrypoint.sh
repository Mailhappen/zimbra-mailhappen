#!/bin/bash
set -e

# Run supervisord when no CMD provided
<<<<<<< HEAD
if [ $# -eq 0 ]; then
=======
if [ -z "$@" ]; then
>>>>>>> 49bbdca (New improved start.sh.)
  exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon
else
  exec "$@"
fi
