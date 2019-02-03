#!/bin/bash

TMP_FOLDER=$(mktemp -d)
TMP_BS=$(mktemp -d)
CONFIGFOLDER='/root/.poliscore'
CONFIG_FILE='polis.conf'
COIN_DAEMON='/usr/local/bin/polisd'
COIN_CLI='/usr/local/bin/polis-cli'
COIN_REPO='https://github.com/polispay/polis/releases/download/v1.4.9/poliscore-1.4.9-x86_64-linux-gnu.tar.gz'
SENTINEL_REPO='https://github.com/polispay/sentinel.git'
COIN_NAME='Polis'
COIN_BS='http://explorer.polispay.org/images/bootstrap.dat'

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function update_sentinel() {
  echo -e "${GREEN}Updating sentinel.${NC}"
  cd /sentinel
  git pull
  cd - >/dev/null 2>&1
}

function update_node() {
  echo -e "Preparing to download updated $COIN_NAME"
  rm /usr/local/bin/polis*
  cd $TMP_FOLDER
  wget -q $COIN_REPO
  compile_error
  COIN_ZIP=$(echo $COIN_REPO | awk -F'/' '{print $NF}')
  tar xvf $COIN_ZIP --strip 1 >/dev/null 2>&1
  compile_error
  cp polis{d,-cli} /usr/local/bin
  compile_error
  strip $COIN_DAEMON $COIN_CLI
  cd - >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  chmod +x /usr/local/bin/polisd
  chmod +x /usr/local/bin/polis-cli
  clear
}

function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}

function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi
}

function prepare_system() {
echo -e "Updating the system and the ${GREEN}$COIN_NAME${NC} master node."
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev unzip libgmp3-dev libzmq3-dev ufw pkg-config libevent-dev libdb5.3++>/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev libzmq3-dev ufw fail2ban pkg-config libevent-dev"
 exit 1
fi
systemctl stop $COIN_NAME >/dev/null 2>&1
$COIN_CLI stop >/dev/null 2>&1
sleep 3
pkill -9 $COIN_DAEMON
clear
}

function import_bootstrap() {
  echo -e "Importing Bootstrap For $COIN_NAME"
  rm -rf $CONFIGFOLDER/blocks $CONFIGFOLDER/chainstate $CONFIGFOLDER/peers.dat $CONFIGFOLDER/banlist.dat
#   cd $TMP_BS
  cd $CONFIGFOLDER
  wget -q $COIN_BS
  compile_error
  cd
#   COIN_ZIP=$(echo $COIN_BS | awk -F'/' '{print $NF}')
#   tar xvf $COIN_ZIP --strip 1 >/dev/null 2>&1
#   compile_error
#   cp -r blocks chainstate $CONFIGFOLDER
#   cd - >/dev/null 2>&1
#   rm -rf $TMP_BS >/dev/null 2>&1
  clear
}

function update_config() {
  sed -i '/addnode=*/d' $CONFIGFOLDER/$CONFIG_FILE
  sed -i '/connect=*/d' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
addnode=insight.polispay.org
addnode=explorer.polispay.org
addnode=23.92.216.30
addnode=199.247.30.134
addnode=45.76.153.10
addnode=45.76.135.238
addnode=199.247.26.161
addnode=45.76.220.156
addnode=199.247.9.68
addnode=144.202.59.4
EOF
}

function important_information() {
#  $COIN_DAEMON -daemon -reindex
#  sleep 15
#  $COIN_CLI stop >/dev/null 2>&1
#  sleep 5
 systemctl start $COIN_NAME >/dev/null 2>&1
 sleep 3
 $COIN_DAEMON -daemon >/dev/null 2>&1
 sleep 3 >/dev/null 2>&1
 echo
 echo -e "================================================================================================================================"
 echo -e "$COIN_NAME Masternode is updated and running again!"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "================================================================================================================================"
}

##### Main #####
clear

checks
prepare_system
update_node
import_bootstrap
update_config
update_sentinel
important_information
