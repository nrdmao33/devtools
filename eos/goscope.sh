#!/bin/bash
#
# goscope - cscope wrapper for generation and browsing via emacs of a cscope
#           database constructed from go files found in the EOS source tree
#
# Source files are found in the following directories:
# 
# test:          /src/<pkg>/go/test/*.go
# testlibs:      /src/<pkg/go/testlib/*.go
# tacc wrappers: /usr/share/gocode/src/arista.com/<TacLib>/*.go
#                 - Note, tacc wrappers may be in /bld for packages built in
#                   this tree but there are simlinks in /usr/share/gocode/

IAM=$(basename $0)

USAGE="$IAM [-bhplr] [-d <dir>] [-C <options>]
    where:
        -b              Build the database
        -p              Set \$SB_SRC to the pwd.
        -d <dir>        Set \$SB_SRC to the directory specified by <dir>.
        -h              Print this message.
        -C <options>    Pass these options to cscope
        -l              Use line mode
        -r              In read only file system, build database in
                        \$HOME/cscope/\$(pwd)
	-I              Include all files under /usr/include in the
			database
        -f              follow symbolic links in source tree
        -F <file>       Build database from files in <file>.
        -P <path-list>  File files from \$SB_SRC/<path> for <path> in <path-list> where
                        <path-list> is a colon (:) seperated list of relative paths to
                        follow. 

    $IAM accesses/builds a cscope database at the directory
    specified by \$SB_SRC.  By default, $IAM assumes
    \$SB_SRC is set, but it may be specified explicitly
    by the -p and -d options.

    When building a database, $IAM finds files matching '*.[chSs]'.
    The database is archived in \$SB_SRC/cscope, unless the -r
    option is specified, in which case the database is built
    in \$HOME/cscope/\$(pwd).

    When accessing the database \$SB_SRC/cscope is checked, if not
    found, \$HOME/cscope/\$(pwd) is checked.  So, the -r option is
    not required when accessing a database regardless of how it was
    built.
"

BUILD=FALSE
CSCOPE_OPTIONS=
READ_ONLY_FS=FALSE
export TMPDIR=/var/tmp
USR_INCLUDE=
FOLLOW=
FILE_LIST=
PATH_LIST=

while getopts :IlfbprhdFP::C: c
do
    case $c in
    b)
        BUILD=TRUE;;
    p)
        SB_SRC=$(pwd);;
    h)
        echo "$USAGE"
        exit 0;;
    d)
        SB_SRC=$OPTARG;;
    r)
        READ_ONLY_FS=TRUE;;
    F)
        FILE_LIST="$OPTARG";;
    C)
        CSCOPE_OPTIONS="$OPTARG $CSCOPE_OPTIONS";;
    l)
        CSCOPE_OPTIONS="-l $CSCOPE_OPTIONS";;
    I)
	USR_INCLUDE=TRUE;;
    f)
        FOLLOW='-follow';;
    P)
        PATH_LIST=$(echo "$OPTARG" | sed 's/:/ /g');;
    :)
        echo "$IAM: $OPTARG requires a value:"
        echo "$USAGE"
        exit 2;;
    \?) echo "$IAM: unknown option $OPTARG"
        echo "$USAGE"
        exit 2;;
    esac
done

if [ $BUILD = TRUE ]
then

    if [ "$SB_SRC" = "" ]
    then
        SB_SRC=''
    fi
    if [ $READ_ONLY_FS = FALSE ]
    then
        DATABASE_DIR=$SB_SRC/tmp/cscope
    else
        DATABASE_DIR=$HOME/cscope$(pwd)/cscope
    fi

    mkdir -p $DATABASE_DIR
    if [ $? != 0 ]
    then
        exit 2
    fi

    cd $SB_SRC/
    #
    # If the file list was given to us, use it.
    # Otherwise we will find the files ourself.
    #
    if [ "$FILE_LIST" != "" ]
    then
        realpath < $FILE_LIST > $DATABASE_DIR/file_list
    else
        FIND_LIST=
        if [ "$PATH_LIST" = "" ]
        then
            FIND_LIST="$SB_SRC/src $SB_SRC/usr/share/gocode/src/arista.com $SB_SRC/bld"
        else
            for P in $PATH_LIST
            do
                FIND_LIST="$FIND_LIST $SB_SRC/$P"
            done
        fi
        find $FIND_LIST -type f -name '*.go' > $DATABASE_DIR/file_list
    fi
    if [ "$USR_INCLUDE" = "TRUE" ]
    then
	find /usr/include  -name '*.[ch]' -print \
	   >> $DATABASE_DIR/file_list
    fi

    cd $DATABASE_DIR
    cscope -b -q -f db -i file_list $CSCOPE_OPTIONS

else

    DATABASE_DIR=$SB_SRC/tmp/cscope
    cd $DATABASE_DIR
    if [ $? != 0 ]
    then
        exit 3
    fi

    cscope -d -q -f db -i file_list $CSCOPE_OPTIONS
fi

# exit with cscope's exit value.
