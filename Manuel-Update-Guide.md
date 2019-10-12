## Updating Polis

### IMPORTANT!! Updating to 1.5.0 or above for the first time?  You will need to also follow these additional steps.
1. Follow the update instructions below as normal
2. Open the polis.conf file, remove masternode=1 and then save/close
nano ~/.poliscore/polis.conf
3. Open the wallet and generate a new BLS key and copy the "secret key" you are given
polisd &
polis-cli bls generate  
4. Put the "secret key" into the polis.conf file and add masternode=1 back to the file (masternodeblsprivkey=secret_key_here)
nano ~/.poliscore/polis.conf
5. Save and close the config file and then restart the wallet
polis-cli stop
polisd &

### Update Instructions
cd  
polis-cli stop  
wget https://github.com/polispay/polis/releases/download/v1.5.2/poliscore-1.5.2-x86_64-linux-gnu.tar.gz  
tar -xvf poliscore-1.5.2-x86_64-linux-gnu.tar.gz 
rm poliscore-1.5.2-x86_64-linux-gnu.tar.gz  
rm /usr/local/bin/polis*  
cp poliscore-1.5.2/bin/polis{d,-cli} /usr/local/bin/  
rm -r poliscore-1.5.2  
polisd &  

1. If the command 'polis-cli masternode status' says 'sucessfully started' then you are running again and are done.  
2. If the command 'polis-cli masternode status' says 'node just started' then you should continue to wait and if this persist, make sure your blocks match the explorer and 'polis-cli mnsync status' says '"IsSynced": True'.  
3. If the command 'polis-cli masternode status' says 'invalid protocol' or 'new start' or 'not in list' then you will need to restart this MN from the local wallet.  

## Updating sentinel. 
cd /sentinel && git pull  

Note: 15 confirmations are needed to avoid error "Failed to verify MNB".


