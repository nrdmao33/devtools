#!/bin/bash
#
# Delete the offending line number from the ~/.ssh/known_hosts
#

IAM=$(basename $0)
USAGE="
usage: $IAM {line_number} [{file}]
    Delete {line_number} from {file} where if not specified {file}
    defaults to ~/.ssh/known_hosts
"

while getopts :h c
do
    case $c in
    h)
        echo "$USAGE"
        exit 0;;
    \?) echo "$IAM: unknown option $OPTARG"
        echo "$USAGE"
        exit 2;;
    esac
done

LINE_NUMBER="$1"
FILE_NAME="$2"

if [ -z "$LINE_NUMBER" ]
then
    echo "$USAGE" 
    exit 1
fi

if [ -z "$FILE_NAME" ]
then FILE_NAME=~/.ssh/known_hosts
fi

TEST_LINE_NUMBER=$(echo $LINE_NUMBER | sed 's/[^(0-9)]//')
if [ "$TEST_LINE_NUMBER" != "$LINE_NUMBER" ]
then
    echo "$USAGE"
    exit 2
fi

sed -i ${LINE_NUMBER}d $FILE_NAME
