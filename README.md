# Polis
Shell script to install a [Polis Masternode](https://polispay.org/) on a Linux server running Ubuntu 16.04.  
This script will install version **1.2.2**.
***

## Installation:
```
wget -q https://raw.githubusercontent.com/zoldur/Polis/master/polis_install.sh
bash polis_install.sh
```
***

## Desktop wallet setup

After the MN is up and running, you need to configure the desktop wallet accordingly. Here are the steps for Windows Wallet
1. Open the Polis Core Wallet.
2. Go to RECEIVE and create a New Address: **MN1**
3. Send **1000** **POLIS** to **MN1**.
4. Wait for 15 confirmations.
5. Go to **Tools -> "Debug console - Console"**
6. Type the following command: **masternode outputs**
7. Go to  ** Tools -> "Open Masternode Configuration File"
8. Add the following entry:
```
Alias Address Privkey TxHash Output_index
```
* Alias: **MN1**
* Address: **VPS_IP:PORT**
* Privkey: **Masternode Private Key**
* TxHash: **First value from Step 6** 
* Output index:  **Second value from Step 6** It can be **0** or **1**
9. Click OK and exit the Wallet.
10. Open Polis Core Wallet, go to **Masternode Tab**. If you tab is not shown, please enable it from: **Settings - Options - Wallet - Show Masternodes Tab**
11. Click **Update status** to see your node. If it is not shown, close the wallet and start it again.
10. Click **Start All** or **Start Alias**
11. If you are not able to see your **Masternode**, try to close and open your desktop wallet.
***

## Usage:
```
polis-cli getinfo
polis-cli masternode status
polis-cli mnsync status
```
Also, if you want to check/start/stop **Polis** , run one of the following commands as **root**:
```
systemctl status Polis #To check the service is running.
systemctl start Polis #To start Polis service.
systemctl stop Polis #To stop Polis service.
systemctl is-enabled Polis #To check whetether Polis service is enabled on boot or not.
```
***

## Sentinel

**Sentinel** is installed in **/sentinel** and added to **crontab** file.  
Sentinel log file is **/root/.poliscore/sentinel.log**  
Test the config by running the following commands:
```
cd /sentinel
./venv/bin/py.test ./test
```
***

## Donations:  

Any donation is highly appreciated.  

**POLIS**:  PHoTmCiuWHc4NDn5kmGdt1VRhc1rrTrawq  
**BTC**: 32tAw218fqnPY1zdgZTEquM71aPViGLqAQ  
**ETH**: 0x39d10fe57611c564abc255ffd7e984dc97e9bd6d  
**LTC**: LXrWbfeejNQRmRvtzB6Te8yns93Tu3evGf
