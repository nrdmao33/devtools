#!/bin/bash
# 
# Copy interesting files from one machine to another
#

IAM=$(basename $0)
HELP="$IAM --help : for more information" 
USAGE="
$IAM [options] <target>

Copy interesting files, specifically those used for software development to the 
target machine. This script is expected to be used when a new account has been
created on another machine. Only a select set of files is copied over.

This script does not copy all files from the home directory to the new server.

 -h|--help      Print this help message.
 -p|--print     Print the files to copy over but do not actually copy the files.
 -f|--file      Take files from the specified file rather than generating the
                files from this script.
"
TEMP=$(getopt -l 'help,print,file:' -o 'h,p,f:' -- "$@")
if [ $? != 0 ]
then
    echo "$HELP"
    exit 1
fi
FILE=
PRINT=
set -- $TEMP
while true
do
    case $1 in
	-p|--print)
            PRINT=1 ; shift ;;
        -f|--file)
            FILE="${2//\'/}" ; shift 2 ;;
        -h|--help)
            echo "$USAGE" | more
            exit 0
            ;;
        --) shift ; break ;;
    esac
done

TARGET="${1//\'/}"

if [ -z "$TARGET" -a -z "$PRINT" ]
then
    echo "No target specified"
    echo "$HELP"
    exit 2
fi

if [ -n "$TARGET" ]
then
    echo TARGET=$TARGET
fi

# PATHS contains the paths for all the files and directories to be cloned
# to the target machine. Note that when a directory is specified in PATHS
# implicitly all files and subdirectories under that direcroty are copied
# to target.
#
PATHS=".bashrc
bin
emacs
.emacs.d
.emacs.el
.gitconfig
.gitignore
.lemacs.d
.lemacs.el
work/devtools
"

OPWD=$(pwd)
cd $HOME
if [ -z "$FILE" ]
then
    FILE=/tmp/$(id -u)${$}-files
    find $PATHS -type f -print | egrep -v '~$|\.pyc' > $FILE
    DELETE_FILE=1
elif [ "$(echo $FILE | sed 's:^/::')" = "$FILE" ]
then
    FILE="$OPWD/$FILE"
fi

ARCHIVE=/tmp/$(id -u)${$}-env.tgz
if [ -n "$PRINT" ]
then
    cat $FILE
    if [ -n "$DELETE_FILE" ]
    then rm $FILE
    fi
    exit 0
fi

cat $FILE | xargs tar -czf $ARCHIVE 
set -x
if scp $ARCHIVE $TARGET:$ARCHIVE
then
    echo $?
fi
ssh $TARGET "tar -xzf $ARCHIVE; rm $ARCHIVE"
rm $ARCHIVE
set +x
if [ -n "$DELETE_FILE" ]
then
    rm $FILE
fi

exit 0
