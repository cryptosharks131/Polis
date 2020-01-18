  TMP_BS=$(mktemp -d)
  CONFIGFOLDER='/root/.poliscore'
  COIN_DAEMON='/usr/local/bin/polisd'
  COIN_CLI='/usr/local/bin/polis-cli'
  COIN_NAME='Polis'
  COIN_BS='https://github.com/polispay/polis/releases/download/v1.6.0/bootstrap.tar.gz'  

  echo -e "Importing Bootstrap For $COIN_NAME"
  systemctl stop $COIN_NAME >/dev/null 2>&1
  $COIN_CLI stop >/dev/null 2>&1
  sleep 3
  pkill -9 $COIN_DAEMON
#   cd $CONFIGFOLDER
  rm -r $CONFIGFOLDER/evodb $CONFIGFOLDER/blocks $CONFIGFOLDER/chainstate $CONFIGFOLDER/peers.dat $CONFIGFOLDER/banlist.dat $CONFIGFOLDER/mncache.dat
  cd $TMP_BS
  wget -q $COIN_BS
#   cd
  COIN_ZIP=$(echo $COIN_BS | awk -F'/' '{print $NF}')
  tar xvf $COIN_ZIP >/dev/null 2>&1
  cp -r evodb blocks chainstate peers.dat $CONFIGFOLDER
  cd - >/dev/null 2>&1
  rm -rf $TMP_BS >/dev/null 2>&1
#   $COIN_DAEMON -daemon -reindex
#   sleep 15
#   $COIN_CLI stop >/dev/null 2>&1
#   sleep 5
  systemctl start $COIN_NAME >/dev/null 2>&1
  sleep 3
  $COIN_DAEMON -daemon >/dev/null 2>&1
  sleep 3 >/dev/null 2>&1
  echo -e "Import Bootstrap Complete"
