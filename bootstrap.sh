  TMP_BS=$(mktemp -d)
  CONFIGFOLDER='/root/.poliscore'
  CONFIG_FILE='polis.conf'
  COIN_DAEMON='/usr/local/bin/polisd'
  COIN_CLI='/usr/local/bin/polis-cli'
  COIN_NAME='Polis'
  COIN_BS='http://bootstrap.polis.tools/polisbootstrap.tar.gz'
  
function update_config() {
  sed -i '/^addnode=/d' $CONFIGFOLDER/$CONFIG_FILE
  sed -i '/^connect=/d' $CONFIGFOLDER/$CONFIG_FILE
  sed -i 's/daemon=0/daemon=1/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
addnode=167.172.143.204
addnode=206.189.79.85
addnode=167.172.45.36
addnode=167.71.246.3
addnode=178.128.16.154
addnode=68.183.201.109
addnode=143.110.145.33
addnode=95.111.237.31
addnode=161.97.112.31
EOF
}

function import_bootstrap() {
  rm -rf $CONFIGFOLDER/llmq $CONFIGFOLDER/evodb $CONFIGFOLDER/blocks $CONFIGFOLDER/chainstate $CONFIGFOLDER/peers.dat $CONFIGFOLDER/banlist.dat $CONFIGFOLDER/mncache.dat $CONFIGFOLDER/sporks.dat
  cd $TMP_BS
#   cd $CONFIGFOLDER
  wget -q $COIN_BS
#   cd
  COIN_ZIP=$(echo $COIN_BS | awk -F'/' '{print $NF}')
  tar xvf $COIN_ZIP >/dev/null 2>&1
  cp -r llmq evodb blocks chainstate peers.dat sporks.dat $CONFIGFOLDER
  cd - >/dev/null 2>&1
  rm -rf $TMP_BS >/dev/null 2>&1
  clear
}

  echo -e "Bootstrap Update For $COIN_NAME"
  echo -e "Stopping polis..."
  systemctl stop $COIN_NAME >/dev/null 2>&1
  $COIN_CLI stop >/dev/null 2>&1
  sleep 3
  pkill -9 $COIN_DAEMON
  echo -e "Importing Bootstrap..."
  import_bootstrap
  echo -e "Updating addnodes..."
  update_config
#   $COIN_DAEMON -daemon -reindex
#   sleep 15
#   $COIN_CLI stop >/dev/null 2>&1
#   sleep 5
  echo -e "Restarting polis..."
  systemctl start $COIN_NAME >/dev/null 2>&1
  sleep 3
  $COIN_DAEMON -daemon >/dev/null 2>&1
  sleep 3 >/dev/null 2>&1
  echo -e "Bootstrap Update Complete!"
