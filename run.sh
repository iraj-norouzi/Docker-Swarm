#!/bin/bash
/usr/bin/supervisord
cd /home/iGap
php index.php start -d

touch /tmp/run.log


while :; do
  sleep 300
done
#touch /tmp/run.log
#/usr/bin/supervisord
