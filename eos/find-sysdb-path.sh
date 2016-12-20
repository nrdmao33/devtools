#!/usr/bin/bash
#
IAM=$(basename $0)
USAGE="$IAM <project> <sysdb-path>

   Find all occurances of <sysdb-path> in all .tin and .py files in <project>
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

find /src/$2 -type f | egrep '.*\.tin|.*\.py' | egrep -v '/[ps]*test/' |
    xargs grep "$1"

