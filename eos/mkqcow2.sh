#!/bin/bash
# 
# This script is used to build an EOS.qcow2 file from any locally
# built rpm files. 
# Before executing this script, build your rpms as follows:
#
# a4 make -p <XXX> rpmbuild
#

IAM=$(basename $0)
HELP="$IAM --help : for more information" 
USAGE="
$IAM [options]

Build the EOS.qcow2 image in an EOS workspace.

 -h|--help      Print this help message.
 -a|--all       Delete and rebuild EOS swi and everything in the /bld area

Build the EOS.qcow image by calling a4 make -p EosImage EOS.qcow2. Also copy
the image to the images directory. With the --all option, the .swi is rebuilt
as well.
"
TEMP=$(getopt -l 'help,all' -o 'h,a' -- "$@")
if [ $? != 0 ]
then
    echo "$HELP"
    exit 1
fi
ALL=0
set -- $TEMP
while true
do
    case $1 in
        -a|--all)
            ALL=1
            shift ;;
        -h|--help)
            echo "$USAGE" | more
            exit 0
            ;;
        --) shift ; break ;;
    esac
done

if [ $ALL = 1 ]
then
    # Clean out the /bld/EosImages directory, otherwise a4 make will think
    # EOS.swi is up to date.
    rm -rf /bld/EosImage/

    # Make the swi first, copy to /images and then make the qcow2 and copy that as
    # well
    a4 make -p EosImage EOS.swi && \
        sudo cp /bld/EosImage/EOS.swi /images/
fi

a4 make -p EosImage EOS.qcow2 && \
    sudo cp /bld/EosImage/EOS.qcow2 /images/

exit $?
