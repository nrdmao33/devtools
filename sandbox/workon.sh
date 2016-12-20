#!/bin/bash
#
# workon <tree_name>
#
# This script sets some variables and aliases for working on a particular
# tree.
#

SB_TREE=$1
if [ "$SB_TREE" = "" ]
then
    SB_TREE=$(basename $(pwd))
fi
if [ "$SB_BASE" = "" ]
then
    SB_BASE=$(dirname $(pwd))
fi

SB_SRC="$SB_BASE/$SB_TREE"
SB_BUILD="$SB_BASE/$SB_TREE"

if [ ! -d "$SB_SRC" ]
then
	echo "No such directory: $SB_SRC"
	exit 1
fi

#
# SB_SRC: The root of the source tree
# SB_BASE: The location of all trees
# SB_TREE: The name of the source tree top directory.
# SB_BUILD: Where built objects are placed.
#

export SB_SRC SB_BASE SB_TREE SB_BUILD

cd $SB_SRC
exec bash
