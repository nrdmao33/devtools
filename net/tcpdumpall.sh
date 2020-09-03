#!/bin/bash

IAM=$(basename $0)
USAGE="$IAM [-p <prefix> ]
    where:
        -p <prefix>    Start a tcpdump session for each interface matching
                       <prefix>, which by default is 'et'.

    Start a tcpdump session for each interface matching the prefix and 
    store it in a binary files called <interface_name>.pcap.
"

PREFIX="et"

while getopts :hp: c
do
    case $c in
    p)
        PREFIX="$OPTARG";;
    h)
        echo "$USAGE"
        exit 0;;
    :)
        echo "$IAM: $OPTARG requires a value:"
        echo "$USAGE"
        exit 2;;
    \?) echo "$IAM: unknown option $OPTARG"
        echo "$USAGE"
        exit 2;;
    esac
done

ip -o link show | awk '$2 ~/^et[0-9]/ { gsub(":", "", $2); print $2}' |
    while read intf
    do
	tcpdump -i ${intf} -w ${intf}.pcap &
    done

wait
