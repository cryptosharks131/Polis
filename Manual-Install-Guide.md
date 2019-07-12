## Preperation

1. Get a VPS from a provider like DigitalOcean, Vultr, Linode, etc. 
   - Recommended VPS size at least 1gb RAM 
   - **It must be Ubuntu 16.04 (Xenial)**
2. Make sure you have a transaction of exactly 1000 POLIS in your desktop cold wallet.

## Cold Wallet Setup Part 1

1. Open your wallet on your desktop.

   Click Settings -> Options -> Wallet
   
   Check "Enable coin control features"
   
   Check "Show Masternodes Tab"
   
   Press Ok (you will need to restart the wallet)
   
   ![Alt text](https://github.com/digitalmine/Guide/blob/master/poliswalletsettings.png "Wallet Settings")

   
   
   
2. Go to the "Tools" -> "Debug console"
3. Run the following command: `masternode genkey`
4. You should see a long key that looks like:
```
3HaYBVUCYjEMeeH1Y4sBGLALQZE1Yc1K64xiqgX37tGBDQL8Xg
```
5. This is your `private key`, keep it safe, do not share with anyone.




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
wget https://github.com/polispay/polis/releases/download/v1.4.18/poliscore-1.4.18-x86_64-linux-gnu.tar.gz
```
```
tar -xvf poliscore-1.4.18-x86_64-linux-gnu.tar.gz
```
```
rm poliscore-1.4.18-x86_64-linux-gnu.tar.gz
```
```
cp poliscore-1.4.18/bin/polis{d,-cli} /usr/local/bin/
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
masternodeprivkey=WALLET_GENKEY
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
masternodeprivkey=WALLET_GENKEY
masternode=1
addnode=polispay.org
addnode=node1.polispay.org
addnode=node2.polispay.org
addnode=insight.polispay.org
addnode=insight2.polispay.org
addnode=explorer.polispay.org
addnode=199.247.2.29:24126
addnode=46.101.32.72:24126
addnode=144.202.19.190:24126
addnode=207.148.5.135:24126
addnode=89.47.165.165:24126
addnode=62.75.139.140:24126
addnode=207.148.5.135:24126
addnode=209.250.245.66:24126
addnode=199.247.3.98:24126
addnode=199.247.29.65:24126
addnode=45.32.149.254:24126
```
CTRL X to save it. Y for yes, then ENTER.
```
polisd &
```
```
apt-get -y install virtualenv python-pip
```
```
git clone https://github.com/polispay/sentinel /sentinel
```
```
cd /sentinel
```
```
virtualenv venv
```
```
. venv/bin/activate
```
```
pip install -r requirements.txt
```
```
crontab -e
```
Hit 2. This will brin up an editor. Paste the following in it at the bottom.
```
* * * * * cd /sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1
```
CTRL X to save it. Y for yes, then ENTER.

3.Use `watch polis-cli getinfo` to check and wait til it's synced 
  (look for blocks number and compare with block explorer https://insight.polispay.org/ )


## Cold Wallet Setup Part 2 

1. On your local machine open your `masternode.conf` file.
   Depending on your operating system you will find it in:
   * Windows: `%APPDATA%\polisCore\`
   * Mac OS: `~/Library/Application Support/polisCore/`
   * Unix/Linux: `~/.poliscore/`
   
   Leave the file open
2. Go to "Tools" -> "Debug console"
3. Run the following command: `masternode outputs`
4. You should see output like the following if you have a transaction with exactly 1000 POLIS:
```
{
    "12345678xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx": "0"
}
```
5. The value on the left is your `txid` and the right is the `vout`
6. Add a line to the bottom of the already opened `masternode.conf` file using the IP of your
VPS (with port 24126), `private key`, `txid` and `vout`:
```
mn1 1.2.3.4:24126 3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 12345678xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 0 
```
7. Save the file, exit your wallet and reopen your wallet.
8. Go to the "Masternodes" tab
9. Click "Start All"
10. You will see "SENTINEL_PING_EXPIRED". Just wait some time, you should see a timer start in about 30 minutes.

Done !  

Note: 15 confirmations are needed to avoid error "Failed to verify MNB".
