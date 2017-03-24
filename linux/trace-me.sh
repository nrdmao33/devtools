#!/bin/bash
if [ $# -lt 1 ]; then
    echo "usage $0 <command to run and trace>"
    exit 1
fi
OUT=$(mktemp)
DEBUGFS=`grep debugfs /proc/mounts | awk '{ print $2; }' | head -n1`
sudo su -c " \
    echo > $DEBUGFS/tracing/trace; \
    echo 0 > $DEBUGFS/tracing/tracing_on; \
    echo 1 > $DEBUGFS/tracing/tracing_on"

fork_exec() {
    PID=$$
       sudo su -c "echo function_graph > $DEBUGFS/tracing/current_tracer; \
               echo $PID > $DEBUGFS/tracing/set_ftrace_pid"
       exec $*
}

fork_exec $* &
wait %1
sudo su -c "cat $DEBUGFS/tracing/trace > $OUT"
sudo su -c "echo nop > $DEBUGFS/tracing/current_tracer"
echo "TRACE output in $OUT"

