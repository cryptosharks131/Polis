#!/bin/bash

TMP_FOLDER=$(mktemp -d)
TMP_BS=$(mktemp -d)
CONFIGFOLDER='/root/.poliscore'
CONFIG_FILE='polis.conf'
COIN_DAEMON='/usr/local/bin/polisd'
COIN_CLI='/usr/local/bin/polis-cli'
COIN_REPO='https://github.com/polispay/polis/releases/download/v1.6.6/poliscore-1.6.6-x86_64-linux-gnu.tar.gz'
SENTINEL_REPO='https://github.com/polispay/sentinel.git'
COIN_NAME='Polis'
COIN_BS='https://public.oly.tech/bootstrap.tar.gz'
BRIDGE='no'

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
  cp bin/polis{d,-cli} /usr/local/bin
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
if [[ $(lsb_release -d) != *16.04* ]] && [[ $(lsb_release -d) != *18.04* ]] && [[ $(lsb_release -d) != *18.10* ]] && [[ $(lsb_release -d) != *20.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04 or 18.04 or 18.10. Update is cancelled.${NC}"
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
  rm -rf $CONFIGFOLDER/evodb $CONFIGFOLDER/blocks $CONFIGFOLDER/chainstate $CONFIGFOLDER/peers.dat $CONFIGFOLDER/banlist.dat $CONFIGFOLDER/mncache.dat $CONFIGFOLDER/sporks.dat
  cd $TMP_BS
#   cd $CONFIGFOLDER
  wget -q $COIN_BS
  compile_error
#   cd
  COIN_ZIP=$(echo $COIN_BS | awk -F'/' '{print $NF}')
  tar xvf $COIN_ZIP --strip 1 >/dev/null 2>&1
  compile_error
  cp -r evodb blocks chainstate peers.dat sporks.dat $CONFIGFOLDER
  cd - >/dev/null 2>&1
  rm -rf $TMP_BS >/dev/null 2>&1
  clear
}

function update_config() {
  sed -i '/^addnode=/d' $CONFIGFOLDER/$CONFIG_FILE
  sed -i '/^connect=/d' $CONFIGFOLDER/$CONFIG_FILE
  sed -i 's/daemon=0/daemon=1/' $CONFIGFOLDER/$CONFIG_FILE
  if grep -q "masternodeblsprivkey=" $CONFIGFOLDER/$CONFIG_FILE;
  then
    :
  else
    sed -i '/^masternode=1/d' $CONFIGFOLDER/$CONFIG_FILE
    update_key
  fi
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
addnode=insight.polispay.org
addnode=116.203.116.205
addnode=95.216.56.42
addnode=207.180.218.18
addnode=80.211.45.85
addnode=176.233.138.86
addnode=5.189.161.94
addnode=149.28.209.101
addnode=167.99.85.39
addnode=157.230.87.57
EOF
}

function important_information() {
 #rm -rf $CONFIGFOLDER/blocks $CONFIGFOLDER/chainstate $CONFIGFOLDER/peers.dat $CONFIGFOLDER/banlist.dat $CONFIGFOLDER/mncache.dat
 #$COIN_DAEMON -daemon -reindex
 #sleep 15
 #$COIN_CLI stop >/dev/null 2>&1
 #sleep 5
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
 echo -e "BLS PubKey: $COINKEYPUB"
 echo -e "================================================================================================================================"
}

function update_key() {
  echo -e "This masternode was on a version prior to 1.5.0 and needs to generate a new BLS PrivKey."
  echo -e "The script will now generate a new ${RED}BLS Private Key${NC} for you.  Press enter to continue."
  read -e COINKEY
  echo -e "Generating a new ${RED}BLS Private Key${NC}"
#   if [[ -z "$COINKEY" ]]; then
  $COIN_DAEMON -daemon
  sleep 30
  if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
   echo -e "Could not start ${RED}$COIN_NAME server. Check /var/log/syslog for errors.{$NC}"
   exit 1
  fi
  COINKEY=$($COIN_CLI bls generate)
  COINKEYPRIVRAW=$(echo "$COINKEY" | grep -Po '"secret": ".*?[^\\]"' | cut -c12-)
  COINKEYPRIV=${COINKEYPRIVRAW::-1}
  COINKEYPUBRAW=$(echo "$COINKEY" | grep -Po '"public": ".*?[^\\]"' | cut -c12-)
  COINKEYPUB=${COINKEYPUBRAW::-1}
  if [ "$?" -gt "0" ];
    then
    echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the Private Key${NC}"
    sleep 30
    COINKEY=$($COIN_CLI bls generate)
    COINKEYPRIVRAW=$(echo "$COINKEY" | grep -Po '"secret": ".*?[^\\]"' | cut -c12-)
    COINKEYPRIV=${COINKEYPRIVRAW::-1}
    COINKEYPUBRAW=$(echo "$COINKEY" | grep -Po '"public": ".*?[^\\]"' | cut -c12-)
    COINKEYPUB=${COINKEYPUBRAW::-1}
  fi
  $COIN_CLI stop
# fi
clear

  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
masternodeblsprivkey=$COINKEYPRIV
masternode=1
EOF
echo $COINKEYPUB > $CONFIGFOLDER/masternode.info
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
