#!/usr/bin/bash
IAM=$(basename $0)
USAGE="$IAM 

  This script takes a list of test execution commands as standard input and
  executes those tests. For each test the failure is detected. Log files are also
  generated for each test. The log files are located in the current directory.
  Also a general summary file is produced that includes the results for each
  test.

  Each log file is named <testfilename>.testlog

  The summary file is named exec-test-summary.txt
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

rm *.testlog > /dev/null 2>&1
SUMMARY=$(pwd)/exec-test-summary.txt
> $SUMMARY

while read line
do
    if [ -z "$(echo $line | sed 's/ \t//')" ]
    then
        continue
    fi
    set $line
    TEST_FILE=$1
    if [ -z "$TEST_FILE" ]
    then
	continue
    fi
    LOGFILE=$(echo $line | sed -e 's/[ \t][ \t]*/_/g' -e 's/=/_/g' ).testlog
    TEST_DIR=$(dirname ${TEST_FILE})
    cd ${TEST_DIR}
    eval $* < /dev/null > ${LOGFILE} 2>&1
    R=$?
    case $R in
        0 )
            echo SUCCESS RC=$R COMMAND=\"$*\" >> $SUMMARY
            echo SUCCESS RC=$R COMMAND=\"$*\"
            ;;
        1 )
            echo PSUCCESS RC=$R COMMAND=\"$*\" >> $SUMMARY
            echo PSUCCESS RC=$R COMMAND=\"$*\"
            ;;
        69 )
            echo SKIP RC=$R COMMAND=\"$*\" >> $SUMMARY
            echo SKIP RC=$R COMMAND=\"$*\"
            ;;
        * )
            echo FAIL RC=$R COMMAND=\"$*\" >> $SUMMARY
            echo FAIL RC=$R COMMAND=\"$*\"
            ;;
    esac
done
