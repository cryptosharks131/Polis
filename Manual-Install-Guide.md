## Preperation

1. Get a VPS from a provider like DigitalOcean, Vultr, Linode, etc. 
   - Recommended VPS size at least 1gb RAM 
   - **It must be Ubuntu 16.04 (Xenial)**
2. Make sure you have a transaction of exactly 1000 POLIS in your desktop cold wallet.

## VPS Setup

1. Log into your VPS
   - Windows users [follow this guide](https://www.digitalocean.com/community/tutorials/how-to-log-into-your-droplet-with-putty-for-windows-users) to log into your VPS.
2. Copy/paste these commands into the VPS and hit enter: (One Box At A Time)
```
apt-get -y update
```
```
apt-get -y upgrade
```
```
apt-get -y install software-properties-common
```
```
apt-add-repository -y ppa:bitcoin/bitcoin
```
```
apt-get -y update
```
```
apt-get -y install \
    wget \
    git \
    unzip \
    libevent-dev \
    libboost-dev \
    libboost-chrono-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libminiupnpc-dev \
    build-essential \
    libtool \
    autotools-dev \
    automake \
    pkg-config \
    libssl-dev \
    libevent-dev \
    bsdmainutils \
    libzmq3-dev \
    nano
```
```
apt-get -y update
```
```
apt-get -y upgrade
```
```
apt-get -y install libdb4.8-dev
```
```
apt-get -y install libdb4.8++-dev
```
```
wget https://github.com/polispay/polis/releases/download/v1.7.0/poliscore-1.7.0-x86_64-linux-gnu.tar.gz
```
```
tar -xvf poliscore-1.7.0-x86_64-linux-gnu.tar.gz
```
```
rm poliscore-1.7.0-x86_64-linux-gnu.tar.gz
```
```
cp poliscore-1.7.0/bin/polis{d,-cli} /usr/local/bin/
```
```
rm -r poliscore-1.7.0
```
```
cd
```
```
mkdir -p .poliscore
```
```
nano .poliscore/polis.conf
```
Replace:
externalip=VPS_IP_ADDRESS
With your info!
```
rpcuser=randuser43897ty8943
rpcpassword=passhf95uiygr5308h08r3h0249fbgh7389h973
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
externalip=VPS_IP_ADDRESS
#masternode=1
addnode=167.172.143.204
addnode=206.189.79.85
addnode=167.172.45.36
addnode=167.71.246.3
addnode=178.128.16.154
addnode=68.183.201.109
addnode=143.110.145.33
addnode=95.111.237.31
addnode=161.97.112.31
```
CTRL X to save it. Y for yes, then ENTER.
```
polisd &
```

3.Use `watch polis-cli getinfo` to check and wait til it's synced 
  (look for blocks number and compare with block explorer https://insight.polispay.org/ )
  
4. Generate a BLS key and update the config file one lat time (you will need to add the "secret" key to the config file)
```
polis-cli bls generate
```
```
nano .poliscore/polis.conf
```
5. Remove the '#' in front of masternode=1 and add the "secret" key from above to the file
```
masternode=1
masternodeblsprivkey=secret_key_here
```
CTRL X to save it. Y for yes, then ENTER.

6. Restart the wallet and now the VPS is ready
```
polis-cli stop
```
```
polisd &
```

## Cold Wallet Setup Part 2 

1. Register your MN - follow this video from the Polis team for help with the registration process
   https://www.polispayserver.com/page/video/4/
2. Once you make the registration, wait for it to confirm on the transactions tab
3. You should see your MN appear as 'Enabled' on the Masternodes tab with the 'My masternodes only' checked

Done!
