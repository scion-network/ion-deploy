#!/bin/bash
set -v
declare -a RABBIT_LIST=(bbcloud01.dev bbcloud02.dev bbcloud03.dev bbcloud04.dev bbcloud05.dev \
    bbcloud11.dev bbcloud12.dev bbcloud13.dev bbcloud14.dev bbcloud15.dev bb-slave2 bb-slave4 \
    r2-dev1 rabbit.dev)
for rabbit in "${RABBIT_LIST[@]}"
do
    echo List for rabbit $rabbit
    python rabbitmqadmin.py -H $rabbit list queues name durable consumers idle_since -f kvp | grep 'consumers="0"' | grep 'durable="False"'|  grep -v "`date +%Y-%m-%d`" | grep -v "`date +%Y-%m-%d | sed 's/-0/-/g'`"
    list=$(python rabbitmqadmin.py -H $rabbit list queues name durable consumers idle_since -f kvp | grep 'consumers="0"' | grep 'durable="False"'|  grep -v "`date +%Y-%m-%d`" | grep -v "`date +%Y-%m-%d | sed 's/-0/-/g'`" | cut -d' ' -f1)
    eval to_delete=($list)
    for val in "${to_delete[@]}"
    do
        python rabbitmqadmin.py -H $rabbit delete queue $val
    done
done

