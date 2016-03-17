#!/bin/bash

# https://spring.io/tools/sts/all
export STS_VERSION='3.7.3.RELEASE'
export ECLIPSE_VERSION='e4.6'
export MAVEN_VERSION='3.3.9'
export JAVA_VERSION='8'

# update the system
sudo apt-get update
sudo apt-get upgrade -y -q

##################################################################################
# This is a port of the JHipster Dockerfile,
# see https://github.com/jhipster/jhipster-docker/
##################################################################################

export LANGUAGE='en_US.UTF-8'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

# we need to update to assure the latest version of the utilities
sudo apt-get install -y -q git-core
sudo apt-get install -y -q --no-install-recommends etckeeper
ETCKEEPER_CONF='/etc/etckeeper/etckeeper.conf'
sudo sed -i 's/^VCS="bzr"/#VCS="bzr"/' ${ETCKEEPER_CONF}
sudo sed -i 's/^#VCS="git"/VCS="git"/' ${ETCKEEPER_CONF}
pushd . && cd /etc && sudo etckeeper init && sudo etckeeper commit -m "Initial Commit" ; popd

echo '##### base install utilities'
sudo apt-get install -y -q vim git sudo zip bzip2 fontconfig curl

echo '##### install Java 8 repos'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886
sudo sh -c 'echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/java.list'
sudo sh -c 'echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/java.list'
pushd . && cd /etc && sudo etckeeper commit -m "added Java source" ; popd
echo '##### Google Chrome repo'
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
pushd . && cd /etc && sudo etckeeper commit -m "added Google Chrome source" ; popd

echo '##### install AWS repos'
sudo apt-add-repository ppa:awstools-dev/awstools
pushd . && cd /etc && sudo etckeeper commit -m "added AWS tools source" ; popd

echo '##### install docker repos'
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo sh -c 'echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" >> /etc/apt/sources.list.d/docker.list'
pushd . && cd /etc && sudo etckeeper commit -m "added Docker source" ; popd


## sudo apt-get update redundant with node installation
#sudo apt-get update

echo '##### install node.js'
sudo curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -
sudo apt-get install -y -q nodejs unzip python g++ build-essential
echo '##### update npm'
sudo npm install -g npm
echo '##### install yeoman grunt bower grunt gulp'
sudo npm install -g yo bower grunt-cli gulp
echo '##### install JHipster'
sudo npm install -g generator-jhipster@2.26.1
pushd . && cd /etc && sudo etckeeper commit -m "added node" ; popd

echo '##### install Java 8'
export JAVA_HOME='/usr/lib/jvm/java-${JAVA_VERSION}-oracle'
sudo echo oracle-java-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y -q --force-yes oracle-java${JAVA_VERSION}-installer
sudo update-java-alternatives -s java-${JAVA_VERSION}-oracle
pushd . && cd /etc && sudo etckeeper commit -m "set java version" ; popd

echo '##### install Maven'
export MAVEN_HOME='/usr/share/maven'
export PATH=$PATH:$MAVEN_HOME/bin
sudo curl -fsSL http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | sudo tar xzf - -C /usr/share && sudo mv /usr/share/apache-maven-${MAVEN_VERSION} /usr/share/maven && sudo ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

##################################################################################
# Install the graphical environment
##################################################################################

echo '##### force encoding'
sudo echo 'LANG=en_US.UTF-8' >> /etc/environment
sudo echo 'LANGUAGE=en_US.UTF-8' >> /etc/environment
sudo echo 'LC_ALL=en_US.UTF-8' >> /etc/environment
sudo echo 'LC_CTYPE=en_US.UTF-8' >> /etc/environment
sudo locale-gen en_US en_US.UTF-8
pushd . && cd /etc && sudo etckeeper commit -m "force encoding" ; popd

echo '##### install Ubuntu desktop and VirtualBox guest tools'
sudo apt-get install -y -q --no-install-recommends ubuntu-desktop
sudo apt-get install -y -q virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
sudo apt-get install -y -q gnome-session-flashback
#sudo apt-get autoremove -q -y --purge libreoffice*
echo '##### run GUI as non-privileged user'
sudo echo 'allowed_users=anybody' > /etc/X11/Xwrapper.config
pushd . && cd /etc && sudo etckeeper commit -m "xwrapper.config allow all users" ; popd

echo '##### Get rid of unecessary items'
echo '##### No screensaver on a VM as host will lock things down'
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
echo '##### remove screensaver'
sudo apt-get remove -y -q gnome-screensaver
# online search
echo '##### set gsettings'
##sudo gsettings set com.canonical.Unity.Lenses disabled-scopes "['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope', 'more_suggestions-populartracks.scope', 'music-musicstore.scope', 'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']"
echo '##### remove unity-lens-shopping'
sudo apt-get remove -y -q unity-lens-shopping
echo '##### commit online search changes'
pushd . && cd /etc && sudo etckeeper commit -m "no shopping search results" ; popd

echo '##### install docker'
# https://docs.docker.com/engine/installation/linux/ubuntulinux/
sudo apt-get purge lxc-docker
sudo apt-get install -y -q linux-image-extra-$(uname -r) 
sudo apt-get install -y -q apparmor
sudo apt-get install -y -q docker-engine
sudo usermod -aG docker ubuntu
sudo usermod -aG docker vagrant
sudo sed -i 's/^DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
echo '##### enable docker to start on boot'
sudo systemctl enable docker

##################################################################################
# Install the development tools
##################################################################################
echo '##### install development tools'
HOME_USER='vagrant'
HOME_DIR="/home/${HOME_USER}"
DEFAULT_PASSWORD="${HOME_USER}"
HOME_GROUP="${HOME_USER}"

echo '##### install Spring Tool Suite'
STS_DOWNLOAD=spring-tool-suite-${STS_VERSION}-${ECLIPSE_VERSION}-linux-gtk-x86_64.tar.gz

echo '##### download Spring Tool Suite'
cd /opt && wget -q http://dist.springsource.com/release/STS/${STS_VERSION}/dist/${ECLIPSE_VERSION}/${STS_DOWNLOAD}
echo '##### unpack Spring Tool Suite'
cd /opt && tar -zxvf ${STS_DOWNLOAD}
echo '##### cleanup archive Spring Tool Suite'
cd /opt && rm -f ${STS_DOWNLOAD}
echo '##### chown Spring Tool Suite'
sudo chown -R ${HOME_USER}:${HOME_GROUP} /opt
cd ${HOME_DIR}

# install MySQL with default passwoard as 'vagrant'
export DEBIAN_FRONTEND=noninteractive
#echo 'mysql-server mysql-server/root_password password vagrant' | sudo debconf-set-selections
#echo 'mysql-server mysql-server/root_password_again password vagrant' | sudo debconf-set-selections
#sudo apt-get install -y -q mysql-server mysql-workbench

echo '##### install Postgres'
sudo apt-get install -y -q postgresql postgresql-client postgresql-contrib libpq-dev
echo "set Postgres default password as 'vagrant'"
sudo -u postgres psql -c "CREATE USER admin WITH PASSWORD '${DEFAULT_PASSWORD}';"
echo 'commit Postgres'
pushd . && cd /etc && sudo etckeeper commit -m "Post Postgres" ; popd

echo '##### chown Spring Tool Suite'
# install Heroku toolbelt
sudo wget -q -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh

echo '##### install Cloud Foundry Toolkit'
cd /opt && sudo curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx
sudo ln -s /opt/cf /usr/bin/cf
cd ${HOME_DIR}
echo '##### install Guake'
sudo apt-get install -y -q guake
sudo cp /usr/share/applications/guake.desktop /etc/xdg/autostart/
pushd . && cd /etc && sudo etckeeper commit -m "Post Guake" ; popd

echo '##### install Atom editor'
sudo apt-get install xdg-utils
wget -q https://github.com/atom/atom/releases/download/v1.3.2/atom-amd64.deb
sudo apt-get install -y -q xdg-utils
sudo dpkg -i atom-amd64.deb
rm -f atom-amd64.deb
sudo dpkg --configure -a


echo '##### install json2csv cmd line tool (& go)'
sudo apt-get install -y -q golang-go
go get github.com/jehiah/json2csv

echo '##### install csvkit'
sudo apt-get install -y -q python3-csvkit xmlstarlet
sudo npm install -g xml2json-command

# AWS tools

# install other tools
echo '##### install other tools'
sudo apt-get install -y -q bash-completion byobu tmux cdargs htop lsof ltrace strace zsh tofrodos ack-grep \
	exuberant-ctags unattended-upgrades pssh clusterssh chromium-browser jq \
	ec2-api-tools ec2-ami-tools \
	iamcli rdscli moncli ascli elasticache elbcli \
	google-chrome-stable

echo '##### install cloudformation'
sudo apt-get install -y -q aws-cloudformation-cli

echo '##### install jekyll blogging'
curl -L https://get.rvm.io | sudo bash -s stable --ruby=2.0.0
sudo gem install jekyll capistrano

## User Directory stuff
echo '##### User Directory stuff'
# provide m2
HOME_tmp="${HOME_DIR}/tmp"
HOME_MVN="${HOME_DIR}/.m2"
HOME_PROJ="${HOME_DIR}/proj"
HOME_GITHUB="${HOME_PROJ}/github"
mkdir -p ${HOME_PROJ}/bitbucket/levonk
mkdir -p ${HOME_GITHUB}/jhipster
mkdir -p ${HOME_GITHUB}/DGHLJ
mkdir -p ${HOME_GITHUB}/levonk
mkdir -p ${HOME_MVN}

echo '##### JHipster Maven Repo Priming'
git clone https://github.com/jhipster/jhipster-travis-build ${HOME_GITHUB}/jhipster/jhipster-travis-build
mv ${HOME_GITHUB}/jhipster/jhipster-travis-build/repository ${HOME_MVN}
rm -Rf ${HOME_GITHUB}/jhipster/jhipster-travis-build

echo '##### Generate VM ssh keys'
HOME_SSH="${HOME_DIR}/.ssh"
mkdir -p ${HOME_SSH}
ssh-keygen -P '' -f "${HOME_SSH}/id_ecdsa" -t ecdsa -C 'devbox autogenerated keypair'


echo '##### Create shortcuts'
HOME_DESKTOP="${HOME_DIR}/Desktop"
sudo mkdir ${HOME_DESKTOP}
ln -s /opt/sts-bundle/sts-${STS_VERSION}/STS ${HOME_DESKTOP}/STS
##ln -s /usr/bin/byobu ${HOME_DESKTOP}/Byobu
##ln -s /usr/bin/xterm ${HOME_DESKTOP}/XTerm
##ln -s /usr/bin/google-chrome ${HOME_DESKTOP}/Google-Chrome

# Vagrant owns all
sudo chown -R ${HOME_USER}:${HOME_GROUP} ${HOME_DIR}

# secure the system (later)
echo '##### Google Authenticator'
# http://www.howtogeek.com/121650/how-to-secure-ssh-with-google-authenticators-two-factor-authentication/
sudo apt-get install -y -q libqrencode3
sudo apt-get install -y -q libpam-google-authenticator
echo 'auth required pam_google_authenticator.so' >> /etc/pam.d/sshd
echo 'ChallengeResponseAuthentication yes' >> /etc/ssh/sshd_config
pushd . && cd /etc && sudo etckeeper commit -m "Google Authenticator settings" ; popd
#sudo service ssh restart ## This kills the script so don't do it
## TODO: Each user still has to run the 'google-authenticator' tool on their own account


echo '##### Clean the box'
sudo apt-get clean -q
sudo apt-get autoremove -q
dd if=/dev/zero of=/EMPTY bs=1M > /dev/null 2>&1
rm -f /EMPTY
echo '##### Reboot the box to get GUI'
sudo shutdown -r now
