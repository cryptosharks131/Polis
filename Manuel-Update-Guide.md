## Updating Polis

cd  
polis-cli stop  
wget https://github.com/polispay/polis/releases/download/v1.4.5/poliscore-1.4.5-x86_64-linux-gnu.tar.gz  
tar -xvf poliscore-1.4.5-x86_64-linux-gnu.tar.gz  
rm poliscore-1.4.5-x86_64-linux-gnu.tar.gz  
cp ~/poliscore-1.4.5/bin/polis{d,-cli} /usr/local/bin/  
polisd -reindex &  

1. If the command 'polis-cli masternode status' says 'sucessfully started' then you are running again and are done.  
2. If the command 'polis-cli masternode status' says 'node just started' then you should continue to wait and if this persist, make sure your blocks match the explorer and 'polis-cli mnsync status' says '"IsSynced": True'.  
3. If the command 'polis-cli masternode status' says 'invalid protocol' or 'new start' or 'not in list' then you will need to restart this MN from the local wallet.  

## Updating Polis
cd /sentinel && git pull  
