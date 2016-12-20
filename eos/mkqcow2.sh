#!/bin/bash
# 
# This script is used to build an EOS.qcow2 file from any locally
# built rpm files. 
# Before executing this script, build your rpms as follows:
#
# a4 make -p <XXX> rpmbuild
#

# Clean out the /bld/EosImages directory, otherwise a4 make will think
# EOS.swi is up to date.
rm -rf /bld/EosImage/

# Make the swi first, copy to /images and then make the qcow2 and copy that as
# well
a4 make -p EosImage EOS.swi && \
    sudo cp /bld/EosImage/EOS.swi /images/ && \
    a4 make -p EosImage EOS.qcow2 && \
    sudo cp /bld/EosImage/EOS.qcow2 /images/

exit $?
