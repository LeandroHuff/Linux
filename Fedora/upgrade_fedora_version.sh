#!/bin/sh

if [ -z "$1" ]
then
      echo "\$You should pass a parameter number for version, 36, 37, ..."
      exit 1
fi

#Atualizar o sistema Fedora xx
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y
sudo dnf install dnf-plugin-system-upgrade -y

#Atualize o Fedora 3x para 3y via parametro
sudo dnf system-upgrade download --releasever=$1

#for any problem, try execute fix_problems() and reboot to fix any kind of problems,
#try the steps before again.
fix_problems ()
{
    sudo dnf system-upgrade download --releasever=37 --allowerasing -y
    sudo dnf distro-sync -y
    sudo fixfiles -B onboot
}

#
sudo dnf system-upgrade reboot -y

#end
exit 0
