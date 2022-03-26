#!/bin/bash
# 
# Convert the specified file to a byte array in a format that can be consumed
# by the C compiler.
#

od -tx1 -v $1 | awk '
{
    for (i = 2; i <= NF; i++) {
    	printf("0x%s, ", $i)
    }
}
END {
    print ""
}
'
