#!/bin/bash
# 
# Template for using getopt in shell scripts
#

IAM=$(basename $0)
HELP="$IAM --help : for more information" 
USAGE="
$IAM [options]

<synopsis>

 -h|--help      Print this help message.
 -o|--option    An option without an argument.
 -a|--arg <arg> An option with an argument.

"
TEMP=$(getopt -l 'help,option,arg:' -o 'h,o,a:' -- "$@")
if [ $? != 0 ]
then
    echo "$HELP"
    exit 1
fi

OPTION=
ARG=
set -- $TEMP
while true
do
    case $1 in
        -o|--option)
            OPTION=1 ; shift ;;
        -a|--arg)
            ARG=$2 ; shift 2 ;;
        -h|--help)
            echo "$USAGE" | more
            exit 0
            ;;
        --) shift ; break ;;
    esac
done

echo "OPTION=${OPTION} ARG=${ARG}"
exit 0
