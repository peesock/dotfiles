#!/bin/sh
trap "kill 0" INT
i=1
while [ $i -le $(nproc) ]; do nice -n -11 yes >/dev/null & i=$(($i + 1)); done
wait
