#!/bin/bash

# Script adapted of https://serverfault.com/questions/266039/temporarily-increasing-sudos-timeout-for-the-duration-of-an-install-script
install -dm777 ../log
log=../log/running_setup.txt
sudo_stat=sudo_status.txt

echo $$ >> $sudo_stat
trap 'rm -f $sudo_stat >/dev/null 2>&1' 0
trap "exit 2" 1 2 3 15

sudo_me() {
 while [ -f $sudo_stat ]; do
  sudo -v
  sleep 5
 done &
}

sudo -v
sudo_me

echo "=running setup=" >> $log
while [ -f $log ]
do
 echo "running setup $$ ...$(date) ===" >> $log
 sleep 2
done

# finish sudo loop
rm $sudo_stat
