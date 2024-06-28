#!/bin/bash

PID=$$

echo -n "Proportional Set Size: "
echo "$(awk '/Pss/{ sum += $2 } END { print sum }' /proc/$PID/smaps) KB"

echo -n "Unique Set Size: "
echo "$(awk '/Private/{ sum += $2 } END { print sum }' /proc/$PID/smaps) KB"

ps -ef | egrep "^( *)$PID root" | sed -e 's/.*[0-9] //g'
