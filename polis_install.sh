#!/bin/bash

TMP_FOLDER=$(mktemp -d)
TMP_BS=$(mktemp -d)
CONFIG_FILE='polis.conf'
CONFIGFOLDER='/root/.poliscore'
COIN_DAEMON='/usr/local/bin/polisd'
COIN_CLI='/usr/local/bin/polis-cli'
COIN_REPO='https://hub.polispay.com/PolisCore/v1.5.3/poliscore-1.5.3-x86_64-linux-gnu.tar.gz'
SENTINEL_REPO='https://github.com/polispay/sentinel.git'
COIN_NAME='Polis'
COIN_PORT=24126
COIN_BS='https://hub.polispay.com/PolisCore/bootstrap.tar.gz'


NODEIP=$(curl -s4 icanhazip.com)


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'


function install_sentinel() {
  echo -e "${GREEN}Install sentinel.${NC}"
  apt-get -y install python-virtualenv virtualenv >/dev/null 2>&1
  git clone $SENTINEL_REPO /sentinel >/dev/null 2>&1
  cd /sentinel
  virtualenv ./venv >/dev/null 2>&1
  ./venv/bin/pip install -r requirements.txt >/dev/null 2>&1
  crontab -l > $CONFIGFOLDER/$COIN_NAME.cron
  echo  "* * * * * cd /sentinel && ./venv/bin/python bin/sentinel.py >> $CONFIGFOLDER/sentinel.log 2>&1" >> $CONFIGFOLDER/$COIN_NAME.cron
  crontab $CONFIGFOLDER/$COIN_NAME.cron
  rm $CONFIGFOLDER/$COIN_NAME.cron >/dev/null 2>&1
  cd -
}


function compile_node() {
  echo -e "Prepare to download $COIN_NAME"
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

function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid

ExecStart=$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}


function create_config() {
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
port=$COIN_PORT
EOF
}

function create_key() {
  echo -e "Enter your ${RED}$COIN_NAME Masternode Private Key${NC}. Leave it blank to generate a new ${RED}Masternode Private Key${NC} for you:"
  read -e COINKEYOLD
  if [[ -z "$COINKEYOLD" ]];
  then
    $COIN_DAEMON -daemon
    sleep 30
    if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
     echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
     exit 1
    fi
    COINKEYOLD=$($COIN_CLI masternode genkey)
    COINKEY=$($COIN_CLI bls generate)
    COINKEYPRIVRAW=$(echo "$COINKEY" | grep -Po '"secret": ".*?[^\\]"' | cut -c12-)
    COINKEYPRIV=${COINKEYPRIVRAW::-1}
    COINKEYPUBRAW=$(echo "$COINKEY" | grep -Po '"public": ".*?[^\\]"' | cut -c12-)
    COINKEYPUB=${COINKEYPUBRAW::-1}
    if [ "$?" -gt "0" ];
      then
      echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the Private Key${NC}"
      sleep 30
      COINKEYOLD=$($COIN_CLI masternode genkey)
      COINKEY=$($COIN_CLI bls generate)
      COINKEYPRIVRAW=$(echo "$COINKEY" | grep -Po '"secret": ".*?[^\\]"' | cut -c12-)
      COINKEYPRIV=${COINKEYPRIVRAW::-1}
      COINKEYPUBRAW=$(echo "$COINKEY" | grep -Po '"public": ".*?[^\\]"' | cut -c12-)
      COINKEYPUB=${COINKEYPUBRAW::-1}
    fi
    $COIN_CLI stop
  else
    $COIN_DAEMON -daemon
    sleep 30
    if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
     echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
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
  fi
clear
}

function update_config() {
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
logintimestamps=1
maxconnections=64
masternode=1
externalip=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEYOLD
masternodeblsprivkey=$COINKEYPRIV
EOF
}


function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
  apt-get -y install fail2ban >/dev/null 2>&1
  systemctl enable fail2ban >/dev/null 2>&1
  systemctl start fail2ban >/dev/null 2>&1
}



function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]] && [[ $(lsb_release -d) != *18.04* ]] && [[ $(lsb_release -d) != *18.10* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04 or 18.04 or 18.10. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already installed.${NC}"
  exit 1
fi
}

function prepare_system() {
echo -e "Preparing the system to install ${GREEN}$COIN_NAME${NC} master node."
echo -e "This might take 15-20 minutes and the screen will not move, so please be patient."
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${GREEN}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev unzip libzmq3-dev ufw pkg-config libevent-dev libdb5.3++>/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw fail2ban pkg-config libevent-dev"
 exit 1
fi

clear
}


function important_information() {
 echo
 echo -e "================================================================================================================================"
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEYOLD${NC}"
 echo -e "MASTERNODE BLS PUBKEY is: ${RED}$COINKEYPUB${NC}"
 if [[ -n $SENTINEL_REPO  ]]; then
  echo -e "${RED}Sentinel${NC} is installed in ${RED}/sentinel${NC}"
  echo -e "Sentinel logs is: ${RED}$CONFIGFOLDER/sentinel.log${NC}"
 fi
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "================================================================================================================================"
}

function import_bootstrap() {
  echo -e "Importing Bootstrap For $COIN_NAME"
  cd $TMP_BS
#   cd $CONFIGFOLDER
  wget -q $COIN_BS
  compile_error
  COIN_ZIP=$(echo $COIN_BS | awk -F'/' '{print $NF}')
  tar xvf $COIN_ZIP --strip 1 >/dev/null 2>&1
  compile_error
#   cd
  cp -r blocks $CONFIGFOLDER
  cp -r chainstate $CONFIGFOLDER
#   cp -r peers.dat $CONFIGFOLDER
  cd - >/dev/null 2>&1
  rm -rf $TMP_BS >/dev/null 2>&1
  clear
}

function add_swap() {
  sudo fallocate -l 2G /swapfile >/dev/null 2>&1
  sudo chmod 600 /swapfile >/dev/null 2>&1
  sudo mkswap /swapfile >/dev/null 2>&1
  sudo swapon /swapfile >/dev/null 2>&1
  cat << EOF >> /etc/sysctl.conf
vm.swappiness=10
EOF
  cat << EOF >> /etc/fstab
/swapfile none swap sw 0 0
EOF
}

function setup_node() {
  get_ip
  create_config
  #import_bootstrap
  create_key
  update_config
  enable_firewall
  install_sentinel
  important_information
  configure_systemd
  add_swap
}

##### Main #####
clear

checks
prepare_system
compile_node
setup_node
