#!/bin/bash
set -e

# Run supervisord when no CMD provided
<<<<<<< HEAD
<<<<<<< HEAD
if [ $# -eq 0 ]; then
=======
if [ -z "$@" ]; then
>>>>>>> 49bbdca (New improved start.sh.)
=======
if [ $# -eq 0 ]; then
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
  exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon
else
  exec "$@"
fi
