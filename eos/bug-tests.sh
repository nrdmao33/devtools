#!/usr/bin/bash

IAM=$(basename $0)
USAGE="$IAM [-p <project> ]
    where:
        -p <project>    Report on tests only matching the specifiec project.

    This script takes as input the output of a4 bugs <bugid> --fs and prints out
    all the test cases that have failed due to that bug. The output is in the
    form of the full path name of the test script followed by the arguments to
    the test.
"

PROJECT='.*'

while getopts :hp: c
do
    case $c in
    p)
        PROJECT="$OPTARG";;
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

awk '
BEGIN {
      check = 0
      }
/BUG FAILURES BY TEST/ {
     check = 1
     }
/BUG FAILURES BY DUT/ {
    exit(0)
}

check == 1 && $3 ~ /^'$PROJECT'$/ && $1 ~ /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ {
    #printf("NF=%d $0=%s\n", NF, $0)
    if ($7 == "autotest") {
       start = 9
    } else {
       start = 7
    }
    n = split($start, a, "/")
    if (n != 2) {
        next # Ignore strange test file descriptions
        print "Error: unexpected test file description:", $start
	#exit(0)
    }
    printf("/src/%s/ptest/%s", a[1], a[2])
    for (i = start + 1; i <= NF; i++) {
        if ($i == "against") {
            break
        }
    	printf(" %s", $i)
    }
    print ""
}' | sort -u

