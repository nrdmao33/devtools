#!/bin/bash
#
# Find files matching grep regular expression
#

IAM=$(basename $0)

USAGE="$IAM [-h] [-d <dir(s)>] <expression>
    where:
        -d <dir(s)> The director(y|ies) to which find should restrict its
	   	     search ((enclose in quotes for multiple directories).
        -h          Print this message.

    $IAM finds files from the current working directory matching regular
    expression <expression>, optionally restricting its search to <dir(s)>.
"

DIR=.

while getopts :hd: c
do
    case $c in
    h)
        echo "$USAGE"
        exit 0;;
    d)
        DIR="$OPTARG";;
    :)
        echo "$IAM: $OPTARG requires a value:"
        echo "$USAGE"
        exit 2;;
    \?) echo "$IAM: unknown option $OPTARG"
        echo "$USAGE"
        exit 2;;
    esac
done

shift $((OPTIND-1))

if [ -z "$1" ]
then
    echo "$IAM: no expression specified"
    echo "$USAGE"
    exit 2
fi

find $DIR -type f | xargs grep -I -n "$1" 2> /dev/null
