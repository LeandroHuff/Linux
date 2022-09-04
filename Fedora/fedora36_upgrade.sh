#!/usr/bin/env bash

#Performing system upgrade
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-36-primary
dnf upgrade --refresh -y
dnf upgrade --bugfix -y
dnf upgrade --enhancement -y
dnf upgrade --newpackage -y
dnf upgrade --security -y
dnf upgrade --sec-severity Critical -y
dnf upgrade --sec-severity Important -y
dnf upgrade --sec-severity Moderate -y
dnf upgrade --sec-severity Low -y
dnf install dnf-plugin-system-upgrade -y
dnf system-upgrade download -y
dnf distro-sync -y
dnf system-upgrade reboot -y

#Resolving post-upgrade issues
#Rebuilding the RPM database
rpm --rebuilddb
dnf distro-sync -y
dnf distro-sync --allowerasing -y

#Optional post-upgrade tasks
#Update system configuration files
dnf install rpmconf -y
rpmconf -a

#Clean-up retired package
dnf install remove-retired-packages -y
remove-retired-packages

#Clean-up old packages
dnf repoquery --unsatisfied -y
dnf repoquery --duplicates -y
dnf list extras -y
dnf autoremove -y

#Clean-Up Old Kernels
old_kernels=($(dnf repoquery --installonly --latest-limit=-1 -q -y))
if [ "${#old_kernels[@]}" -eq 0 ]; then
    echo "No old kernels found"
    exit 0
fi

if ! dnf remove "${old_kernels[@]}" -y; then
    echo "Failed to remove old kernels"
    exit 1
fi

echo "Removed old kernels"

#Clean-up old symlinks
dnf install symlinks -y
symlinks -r /usr | grep dangling
symlinks -r -d /usr

#Relabel files with the latest SELinux policy
fixfiles -B onboot

#Exit
exit 0
