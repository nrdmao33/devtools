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
    set $line
    TEST_FILE=$1
    LOGFILE=$(echo $line | sed -e 's/[ \t][ \t]*/_/g' -e 's/=/_/g' ).testlog
    TEST_DIR=$(dirname ${TEST_FILE})
    cd ${TEST_DIR}
    eval $* < /dev/null > ${LOGFILE} 2>&1
    R=$?
    case $R in
        0 )
            echo SUCCESS RC=$R COMMAND=\"$*\" >> $SUMMARY
            ;;
        1 )
            echo PSUCCESS RC=$R COMMAND=\"$*\" >> $SUMMARY
            ;;
        69 )
            echo SKIP RC=$R COMMAND=\"$*\" >> $SUMMARY
            ;;
        * )
            echo FAIL RC=$R COMMAND=\"$*\" >> $SUMMARY
            ;;
    esac
done
