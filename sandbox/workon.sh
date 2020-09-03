#
# workon
#
# This script sets some variables and aliases for working on a particular
# tree.
#

SB_SRC=$(pwd)
export SB_SRC

alias cdroot='cd $SB_SRC'

cd $SB_SRC
exec bash
