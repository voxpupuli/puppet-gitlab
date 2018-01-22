#!/bin/bash

echo 'Checking pgsql version'
CMD=$(sudo gitlab-psql --version)
echo "version is ${CMD##* }"
#9.2.18
if [ "${CMD##* }" = "9.2.18" ]; then
  echo 'Version is below required for Gitlab 10+, checking...'
  DB_SIZE=$(du -shk /var/opt/gitlab/postgresql/data | awk '{print $1}')
  FREE=$(df -hk /var/opt/gitlab/postgresql/data/ | tail -1 | awk '{print $4}')
  echo "Database size is: $DB_SIZE kb and freespace is $FREE kb"
  if [ $DB_SIZE -lt $FREE ]; then
    echo 'Enough freespace available to proceed.'
    sudo gitlab-ctl pg-upgrade
    echo 'Upgrade complete.  Please verify everything is correct and then run the post_upgrade task.'
  else
    echo 'You need to have enough freespace for a second copy of the database. Please resolve and then re-run the task.'
    exit 1
  fi
else
  echo 'Version is correct for Gitlab 10+, upgrade skipped...'
fi
