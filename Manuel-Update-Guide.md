## Updating Polis

cd  
polis-cli stop  
wget https://github.com/polispay/polis/releases/download/v1.4.1/poliscore-1.4.1-x86_64-linux-gnu.tar.gz  
tar -xvf poliscore-1.4.1-x86_64-linux-gnu.tar.gz  
rm poliscore-1.4.1-x86_64-linux-gnu.tar.gz  
cp ~/polis-1.4.1/bin/polis{d,-cli} /usr/local/bin  
polisd -reindex  
