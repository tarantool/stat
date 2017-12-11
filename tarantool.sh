#!/bin/bash
PATH="/bin:/sbin:/usr/bin:/usr/sbin"

#
# Copyright (C) 2017 Tarantool AUTHORS: please see the [AUTHORS](AUTHORS.md) file.
#

# TODO Move to 'help' and to the README.md [[[
#
# чекалка для tarantool 1.6+ для centos7
#
# логика примерно такая:
# 1. достаём список инстансов из systemctl
# 2. по каждому инстансу делаем проверки:
#	a) процент занятой арены arena_used_ratio < 85%
#	b) статус инстанса - running
#	c) статус реплики off (мастер) или follow (реплика)
#	d) если статус реплики follow, то доп роверка на server_ro=true и replication_lag < 1s
# ]]]

INSTANCE_NAMES=$( systemctl --no-pager --no-legend list-units 'tarantool@*' | cut -f 1 -d ' '| sed 's|tarantool@||; s|\.service||' )
EXIT_CODE=0

get_metric_val(){
	INSTANCE_NAME=$1
	METRIC=$2

	VAL=$( echo "${METRIC}" | tarantoolctl enter $INSTANCE_NAME 2>/dev/null | grep '^- ' | cut -f 2-255 -d ' ' )
	if [[ -z $VAL ]]; then
		echo "can't get $METRIC from $INSTANCE_NAME" >&2
		return 1
	fi

	echo $VAL
}

EXIT_CODE=0

for INSTANCE_NAME in $INSTANCE_NAMES; do

	# check arena
	VAL=$( get_metric_val $INSTANCE_NAME "tonumber(box.slab.info().arena_used_ratio:sub(1,-2))" )
	EXIT_CODE=$(( $EXIT_CODE | $? ))
	if [[ ${VAL%%.*} -gt 85 ]]; then
		echo "$INSTANCE_NAME arena_used_ratio more than 85%"
		EXIT_CODE="1"
	fi
	VAL=""

	# check status
	VAL=$( get_metric_val $INSTANCE_NAME "box.info().status" )
	EXIT_CODE=$(( $EXIT_CODE | $? ))
	if [[ "$VAL" != "running" ]]; then
		echo "instance $INSTANCE_NAME - status not running"
		EXIT_CODE="1"
	fi

	# replication_status
	VAL=$( get_metric_val $INSTANCE_NAME "require('stat').check_replica { exclude = {'follow'} }" )
	EXIT_CODE=$(( $EXIT_CODE | $? ))
	for UUID in $VAL; do
	    echo "instance $INSTANCE_NAME replica $UUID - replication status is not equal \"follow\""
	    EXIT_CODE="1"
	done

	VAL=$( get_metric_val $INSTANCE_NAME "require('stat').check_replica { include = {'follow'}, lag = 10 }" )
    EXIT_CODE=$(( $EXIT_CODE | $? ))
    for UUID in $VAL; do
	    echo "instance $INSTANCE_NAME replica $UUID - replication lag more 10s ($VAL)"
	    EXIT_CODE="1"
	done

done
exit $EXIT_CODE
