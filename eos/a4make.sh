#!/bin/bash
#
IAM=$(basename $0)
USAGE="$IAM <package>

This script calls a4 make in such a way that its output is more readable when
compiling in emacs. 

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

(a4 make --color no -p $1 2>&1 ; ret=$?) |  sed 's/201[6789].*: //'
exit $ret
