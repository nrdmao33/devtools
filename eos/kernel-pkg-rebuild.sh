#!/bin/bash
#
# Rebuild all the kernel loadable modules for a veos images and update the swi
#

set -x

PKGS="kshim scd-driver scd-em plx-pcie-drivers rbfd fpdma arista-bde"
RPMS=""
for pkg in ${PKGS}
do
    RPMS="${RPMS} /RPMS/${pkg}.i686.rpm"
done

EOSKERNELPKG="EosKernel"
EOSKERNELRPM="/RPMS/EosKernel.i686.rpm"
rm -f ${EOSKERNELRPM} ${RPMS}

for pkg in ${EOSKERNELPKG} ${PKGS}
do
    a4 rpmbuild ${pkg}
done

sudo swi rpm /images/EOS.swi -U --force --nopreun ${EOSKERNELRPM}
sudo swi rpm /images/EOS.swi -U --force ${RPMS}
