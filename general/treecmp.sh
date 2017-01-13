#!/bin/bash
# Compare two directory trees and make sure the files are identical
#

function check_dir {
    D1="$1"
    D2="$2"
    RET=0
    # find all files in D1 and make sure they exist in D2
    if [ "$IGNORE" != "" ]
    then
	EGREP="egrep -v $IGNORE"
    else
	EGREP="cat"
    fi
    find "$D1" -type f -print | $EGREP | while read FILE
    do
	NEW_FILE=$(echo $FILE | sed 's:'$D1':'$D2':')
	if [ ! -f $NEW_FILE ]
	then
	    echo "$FILE:"
	    echo "Exists in $D1 but not found in $D2"
	    RET=1
	fi
    done
    return $RET
}

IAM=$(basename $0)

USAGE="$IAM <dir1> <dir2> <ignore>
    where:
      <dir1> and <dir2> are directories to compare
      <ignore> is an egrep style regular expression matching paths that should
               be ignored. For example, if comparing git trees you would ignore
               '/.git/'. Note that the ignore regex should be protected from the
               shell.
"

DIR1="$1"
DIR2="$2"
IGNORE="$3"

if [ -z "$DIR1" -o -z "$DIR2" ]
then
    echo "$USAGE"
fi
if [ ! -d "$DIR1" ]
then
    echo "No such directory: $DIR1"
    echo "$USAGE"
    exit 1
fi

if [ ! -d "$DIR2" ]
then
    echo "No such directory: $DIR2"
    echo "$USAGE"
    exit 1
fi

RET=0
check_dir $DIR1 $DIR2
if [ $? != 0 ]
then
    RET=1
fi
check_dir $DIR2 $DIR1
if [ $? != 0 ]
then
    RET=1
fi
exit $RET
