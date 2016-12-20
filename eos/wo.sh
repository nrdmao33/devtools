#!/bin/bash
#
# wo <tree_name>
#
# This script does an a4 chroot to get you working and isolated in a tree
#
# export the variable WO_BASE in your environment to automatically get
# put into your tree.
#

WO_TREE=$1
if [ "$WO_TREE" = "" ]
then
    WO_TREE=$(basename $(pwd))
fi
if [ "$WO_BASE" = "" ]
then
    WO_BASE=$(dirname $(pwd))
fi

WO_SRC="$WO_BASE/$WO_TREE"
WO_BUILD="$WO_BASE/$WO_TREE/bld"

if [ ! -d "$WO_SRC" ]
then
	echo "No such directory: $WO_SRC"
	exit 1
fi

#
# WO_SRC: The root of the source tree
# WO_BASE: The location of all trees
# WO_TREE: The name of the source tree top directory.
# WO_BUILD: Where built objects are placed.
#

export WO_SRC WO_BASE WO_TREE WO_BUILD

cd $WO_SRC
a4 chroot -i
