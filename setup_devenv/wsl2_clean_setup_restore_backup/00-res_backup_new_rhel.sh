#!/bin/bash

# provide a date to be restored, in the format "yyyy_MM_dd-HH_mm_ss"
$myBackUpName="2022_01_30-21_31_41-rhel-backup-dev.tar.gz"
$backupPath="/path/to/backup/"$myBackUpName

# updating and installing dependencies
sudo dnf update -y

printf ">>>> install some gnome extensions >>>>\n"
sudo dnf install gnome-tweak-tool

printf ">>>> install flatpak repositories >>>>\n"
sudo dnf install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists rhel https://flatpaks.redhat.io/rhel.flatpakrepo

printf ">>>> Installing tools >>>>\n"
sudo dnf install -y git cmake htop zsh && sudo dnf groupinstall "Development Tools"
# curl apt-transport-https

printf ">>>> install jetbrains mono font >>>>\n"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

printf ">>>> Install Python3.8 >>>>\n"
sudo dnf install gcc openssl-devel bzip2-devel libffi-devel 
sudo yum update -y
cd /Downloads && wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz  
tar xzf Python-3.8.12.tgz
cd Python-3.8.12 && sudo ./configure --enable-optimizations && sudo make altinstall

printf ">>>> Installing Node >>>>\n"
dnf module install nodejs:16

# Install jetbrains box
# TODO(hadirga): search repository

# Download stoplight studio
# TODO(hadirga): download file and save it at .stoplight

printf ">>>> Install VSCode >>>>\n"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
sudo dnf install code

printf ">>>> Installing Docker Engine >>>>\n"
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io
sudo groupadd docker && sudo usermod -aG docker ${USER} && newgrp docker
# groupadd docker && sudo gpasswd -a ${USER} docker && sudo systemctl restart docker
# usermod -aG docker ${USER}

printf ">>>> Installing Docker Compose >>>>\n"
# Download the current stable release of Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# or below
bash -c 'sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$("uname "-s)-$("uname "-m)" -o /usr/local/bin/docker-compose'
# Apply executable permissions to the binary
bash -c "sudo chmod +x /usr/local/bin/docker-compose \
    && sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose \
    && sudo service docker start"

printf ">>>> install apps >>>>\n"
flatpak install flathub -y org.kde.krita
flatpak install flathub -y inkscape
flatpak install flathub -y calibre
flatpak install flathub -y okular

printf ">>>> Cleaning Installation >>>>\n"
sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# yum clean all dnf clean all

printf ">>>> Instalar DoubleCommander >>>>\n"
cd /etc/yum.repos.d/
wget https://download.opensuse.org/repositories/home:Alexx2000/CentOS_7/home:Alexx2000.repo
yum install doublecmd-gtk
# or
dnf config-manager --add-repo https://download.opensuse.org/repositories/home:Alexx2000/Fedora_24/home:Alexx2000.repo
dnf install doublecmd-gtk


printf ">>>> Transfer backup file >>>>\n"
sudo rsync --archive --verbose --delete \
    $backupPath \
    $HOME

printf ">>>> Download the ohmyzsh repository >>>>\n"
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

printf ">>>> Unpack the backup file >>>>\n"
cd $HOME \
    && tar -xvpzf $myBackUpName --numeric-owner \
    && rm -rf $myBackUpName

printf ">>>> Install the VSCode extensions >>>>\n"
cd $HOME \
    && cat vs_code_extensions_list.txt | xargs -n 1 code --install-extension
    && rm -rf vs_code_extensions_list.txt


printf ">>>> Set zsh as my default shell >>>>\n"
chsh -s $(which zsh)
# Enter your user password...
# Set "Login Shell [/bin/bash]:" as /usr/bin/zsh
