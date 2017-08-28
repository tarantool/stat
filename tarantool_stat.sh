#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin"

# скрипт для сбора статистики тарантула в collectd

INTERVAL="1"	# sec
# set hostname
if [[ -z $COLLECTD_HOSTNAME ]]; then
	if [[ -z $HOSTNAME ]]; then
		HOSTNAME='localhost'
	fi
else
	HOSTNAME=$COLLECTD_HOSTNAME
fi
INSTANCE_NAMES=$( systemctl | grep '\starantool@.*\.service' | awk '{print $1}' | sed 's|tarantool@||; s|\.service||' )

while true; do
	for INSTANCE_NAME in $INSTANCE_NAMES; do
    BOX_STAT=$( echo "require('stat').stat()" | tarantoolctl enter $INSTANCE_NAME 2>/dev/null )
		METRICS=$( echo "$BOX_STAT" | grep -P "^(-|\s)\s" | sed 's|-| |' | awk '{print $1}' )
		for METRIC in $METRICS; do
			VAL=$( echo "$BOX_STAT" | grep -w $METRIC | awk '{print $NF}' )
			METRIC_NAME=$( echo $METRIC | tr '[:upper:]' '[:lower:]' | sed 's|:||g; s|\.|_|g' )
			echo -e "PUTVAL \"$HOSTNAME/tarantool/tarantool-$METRIC_NAME\" interval=$INTERVAL N:$VAL"
		done
	done
	sleep $INTERVAL
done
