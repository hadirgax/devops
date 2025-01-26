#!/bin/sh

# TODO(hadirga): enter commands to install the list below
echo ">>> Installing brew repositories... >>>"
echo ">>> Installing miniconda... >>>"

echo ">>> Defining variables... >>>"
# provide a date to be restored, in the format "yyyy_MM_dd-HH_mm_ss"
$myBackUpName="2022_03_04-08_06_50-rhel-backup-dev.tar.gz"
$backupPath="/path/to/backups/linux/"$myBackUpName

echo ">>> Updating ubuntu... >>>"
# updating and installing dependencies
sudo apt-get update -y && sudo apt-get upgrade -y

echo ">>> Installing flatpak repositories... >>>"
sudo apt-get install -y flatpak
sudo apt-get install -y gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo


echo ">>> Installing chrome... >>>"
# https://www.google.com/chrome
# sudo apt install ./<file>.deb

echo ">>> Installing tools >>>"
sudo apt-get install --no-install-recommends -y \
	git \
	curl \
	htop \
	zsh \
	apt-transport-https \
	ca-certificates \
	gnupg \
	lsb-release \
	dconf-cli
#	build-essential \
#	cmake \

echo ">>>> Install jetbrains mono font >>>>\n"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

echo ">>> Installing VSCode... >>>"
#https://go.microsoft.com/fwlink/?LinkID=760868
# sudo apt install ./<file>.deb

echo ">>> Installing Docker Engine... >>>"
sudo apt-get update
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
sudo service docker start

echo ">>> Installing Docker Compose... >>>"
# Download the current stable release of Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Apply executable permissions to the binary
sudo chmod +x /usr/local/bin/docker-compose
#sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

echo ">>>> Installing apps... >>>>\n"
sudo flatpak install flathub -y org.kde.krita
sudo flatpak install flathub -y inkscape
sudo flatpak install flathub -y calibre
sudo flatpak install flathub -y okular


echo ">>> Installing DoubleCommander... >>>"
echo 'deb http://download.opensuse.org/repositories/home:/Alexx2000/xUbuntu_21.10/ /' | sudo tee /etc/apt/sources.list.d/home:Alexx2000.list
curl -fsSL https://download.opensuse.org/repositories/home:Alexx2000/xUbuntu_21.10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_Alexx2000.gpg > /dev/null
sudo apt update
sudo apt install -y doublecmd-gtk

echo ">>> Cleaning Installation... >>>"
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo ">>> Transfering the backup file >>>"
sudo rsync --archive --verbose --delete $backupPath $HOME

echo ">>> Downloading the ohmyzsh repository... >>>"
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

echo ">>> Unpacking the backup file... >>>"
cd $HOME \
    && tar -xvpzf $myBackUpName --numeric-owner \
    && sudo rm -rf $myBackUpName

echo ">>>> Install the VSCode extensions >>>>"
cd $HOME \
    && cat vs_code_extensions.txt | xargs -n 1 code --install-extension \
    && rm -rf vs_code_extensions.txt

echo ">>> Installing dracula theme in gnome terminal... >>>"
cd $HOME/Downloads \
    && git clone https://github.com/dracula/gnome-terminal \
    && cd gnome-terminal \
    && ./install.sh

echo ">>> Setting zsh as my default shell... >>>"
chsh -s $(which zsh)
# Enter your WSL password
# Set "Login Shell [/bin/bash]:" as /usr/bin/zsh
