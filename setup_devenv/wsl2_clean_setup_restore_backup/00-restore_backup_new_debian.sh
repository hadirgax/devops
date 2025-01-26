#!/bin/sh

echo ">>> Define variables >>>"
# provide a date to be restored, in the format "yyyy_MM_dd-HH_mm_ss"
$myBackUpName = "2022_02_22-20_04_06-rhel-backup-dev.tar.gz"
$backupPath="/path/to/backups/linux/"$myBackUpName

# updating and installing dependencies
echo ">>> Updating debian >>>"
sudo apt-get update -y && sudo apt-get upgrade -yq

echo ">>> install flatpak repositories >>>"
sudo apt-get install flatpak
sudo apt-get install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo ">>> Install nvidia drivers>>>"
#https://wiki.debian.org/NvidiaGraphicsDrivers#Version_470.103.01-2
# append to /etc/apt/sources.list
# Debian Bookworm
# deb http://deb.debian.org/debian bullseye-backports main contrib non-free
sudo apt update
sudo apt install -t bullseye-backports nvidia-driver firmware-misc-nonfree

echo ">>> Install chrome >>>"
# https://www.google.com/chrome
# sudo apt install ./<file>.deb

echo ">>> Installing tools >>>"
sudo apt-get install --no-install-recommends -y git build-essential \
    cmake curl htop zsh apt-transport-https rsync

echo ">>>> Install jetbrains mono font >>>>\n"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

echo ">>> Install VSCode >>>"
#https://go.microsoft.com/fwlink/?LinkID=760868
#wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
#sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
#sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
#rm -f packages.microsoft.gpg
#sudo apt install apt-transport-https
#sudo apt update
#sudo apt install code # or code-insiders

echo ">>> Installing Docker Engine >>>"
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
sudo service docker start

echo ">>> Installing Docker Compose >>>"
# Download the current stable release of Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Apply executable permissions to the binary
sudo chmod +x /usr/local/bin/docker-compose
#sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

echo ">>>> Install apps >>>>\n"
sudo flatpak install flathub -y org.kde.krita
sudo flatpak install flathub -y inkscape
sudo flatpak install flathub -y calibre
sudo flatpak install flathub -y okular

echo ">>> Install DoubleCommander >>>"
echo 'deb http://download.opensuse.org/repositories/home:/Alexx2000/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/home:Alexx2000.list
curl -fsSL https://download.opensuse.org/repositories/home:Alexx2000/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_Alexx2000.gpg > /dev/null
sudo apt update
sudo apt install -y doublecmd-gtk

# bash -c "echo -e '\n***** Installing Python *****\n' \
#    && sudo apt-get install --no-install-recommends -y python3-pip pipenv \
#    && sudo python3 -m pip install --upgrade pipenv"
# python3-venv python3-setuptools \

# Installing Node
bash -c "curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash - \
    && sudo apt-get install --no-install-recommends -y nodejs \
    && sudo npm install -g yarn"

# Cleaning Installation
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo ">>> Transfer the backup file >>>"
sudo rsync --archive --verbose --delete $backupPath $HOME

echo ">>> Download the ohmyzsh repository >>>"
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

echo ">>> Unpack the backup file >>>"
cd $HOME
tar -xvpzf $myBackUpName --numeric-owner
sudo rm -rf $myBackUpName

echo ">>>> Install the VSCode extensions >>>>"
cd $HOME \
    && cat vs_code_extensions.txt | xargs -n 1 code --install-extension \
    && rm -rf vs_code_extensions.txt

# Set zsh as my default shell
bash -c '"chsh -s $(" - "which zsh)"'
# Enter your WSL password
# Set "Login Shell [/bin/bash]:" as /usr/bin/zsh
