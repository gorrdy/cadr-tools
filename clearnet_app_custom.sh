#!/usr/bin/env bash

# add clearnet domain

SCRIPT=`basename "$0"`
usage="sudo ./$SCRIPT <domain> <target-ip> <target-port> <your-email> <nginx-port-http> <nginx-port-https>"

if [[ $UID != 0 ]]; then
    echo "Reverse proxy must be started as root"
    echo "Please re-run this script as"
    echo "Usage: $usage"
    exit 1
fi

if [ -z $1 ]; then
    echo "You must specify the app you want to add"
    echo "Usage: $usage"
    exit
fi
if [ -z $2 ]; then
    echo "You must specify the target IP"
    echo "Usage: $usage"
    exit
fi
if [ -z $3 ]; then
    echo "You must specify the port that you app uses"
    echo "Usage: $usage"
    exit
fi
if [ -z $4 ]; then
    echo "You must specify email for lets encrypt"
    echo "Usage: $usage"
    exit
fi
if [ -z $5 ]; then
    echo "You must specify the port for http listen nginx (default 80 or something like 15080 if you are behind any reverse proxy or something)"
    echo "Usage: $usage"
    exit
fi
if [ -z $6 ]; then
    echo "You must specify the port for https listen nginx (default 443 or something like 15080 if you are behind any reverse proxy or something)"
    echo "Usage: $usage"
    exit
fi

APP=$1
TARGET=$2
PORT=$3
EMAIL=$4
PORT_HTTP=$5
PORT_HTTPS=$6

echo
echo "======================================"
echo "============= STARTING ==============="
echo "====== Reverse Proxy Add App ========="
echo "======================================"
echo

echo
echo "Update"
sudo apt update

echo
echo "Install certbot, nginx, dependencies"
sudo apt install -y python3-acme python3-certbot python3-mock python3-openssl python3-pkg-resources python3-pyparsing python3-zope.interface python3-certbot-nginx nginx

echo
echo "Move default nginx server to port 85"
sudo sed -i 's/80 default_server/85/g' /etc/nginx/sites-available/default

echo
echo "Try to finish the installation"
sudo apt install -f -y

FILE=/etc/nginx/sites-available/main
FILE_LINK=/etc/nginx/sites-enabled/main
if [ -f "$FILE" ] && [ -L "$FILE_LINK" ]; then
    RUN=0
    echo
    echo "Entry 'main' already configured : /etc/nginx/sites-available/main"
else
    RUN=1
    echo
    echo "Create a main in /etc/nginx/sites-available/"
    touch /etc/nginx/sites-available/main
    echo "proxy_buffer_size          128k;"        > /etc/nginx/sites-available/main
    echo "proxy_buffers              4 256k;"  >> /etc/nginx/sites-available/main
    echo "proxy_busy_buffers_size    256k;"    >> /etc/nginx/sites-available/main
    echo "client_header_buffer_size 500k;"     >> /etc/nginx/sites-available/main
    echo "large_client_header_buffers 4 500k;" >> /etc/nginx/sites-available/main
    echo "http2_max_field_size       500k;"    >> /etc/nginx/sites-available/main
    echo "http2_max_header_size      500k;"    >> /etc/nginx/sites-available/main

    echo
    echo "Create a ln -s /etc/nginx/sites-available/main /etc/nginx/sites-enabled/"
    sudo ln -s /etc/nginx/sites-available/main /etc/nginx/sites-enabled/
fi

echo
echo "Add reverse proxy"
echo "Create this reverse proxy entries: $1"

FILE=/etc/nginx/sites-available/$APP
FILE_LINK=/etc/nginx/sites-enabled/$APP

if [ -f "$FILE" ] && [ -L "$FILE_LINK" ]; then
    RUN="NO"
    echo
    echo "ERROR : Entry '$APP' already configured : $FILE"
    echo
    echo "If you want to generate a new config, remove the older one"
    echo "rm $FILE"
    echo "rm $FILE_LINK"
    exit
else
    RUN="YES"
    echo
    echo "Create a $APP in /etc/nginx/sites-available/"
    touch $FILE
    echo "
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}
server {
    server_name $APP;
    location / {
        proxy_pass http://$TARGET:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
    }

    listen $PORT_HTTP;
    listen [::]:$PORT_HTTP;
}" > $FILE

    echo
    echo "Create a ln -s /etc/nginx/sites-available/$APP /etc/nginx/sites-enabled/"
    sudo ln -s /etc/nginx/sites-available/$APP /etc/nginx/sites-enabled/
fi

echo
echo "Check nginx configuration"
sudo nginx -t

echo
echo "Reload nginx server"
sudo systemctl reload nginx.service


DHPARAM=/etc/nginx/dhparam.pem
NEW_DHPARAM_NEEDED="UNDEFINED"
if [ -f "$DHPARAM" ]; then
    echo
    echo "File /etc/nginx/dhparam exists, do not generate a new one"
    NEW_DHPARAM_NEEDED="NO"
else
    echo
    echo "Create dhparam.pem 4096"
    sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096
    NEW_DHPARAM_NEEDED="YES"
fi

echo
CERT=/etc/letsencrypt/live/$APP/fullchain.pem
if [ -f "$CERT" ]; then
    echo
    echo "Certificate $CERT exists, do not generate a new one"
else
    echo
    echo "Genereate lets encrypt certificate for $APP, $EMAIL, 443, 80"
    certbot --nginx -d $APP -m $EMAIL --agree-tos
fi

if [ -f "$CERT" ]; then
  echo "Certificate generated successfully!"
else
  echo "ERROR : There was a problem with the certificate generation, delete the $APP file from /etc/nginx/sites-available and /etc/nginx/sites-enabled symlink"
  rm $FILE $FILE_LINK
  RUN="NO"
fi

if [ $RUN == "YES" ]; then
    echo
    echo "Create a final configuration with SSL for $APP:$PORT"
    echo "
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen $PORT_HTTP;
    server_name $APP www.$APP;
    return 301 https://$APP\$request_uri;
}

# $APP
server {
    listen $PORT_HTTPS ssl; # Here, you'll tell nginx to listen on port 443 for SSL connections
    server_name $APP; # Here you'll tell nginx the expected domain for requests
    access_log /var/log/nginx/reverse-access.log; # Your first go-to for troubleshooting
    error_log /var/log/nginx/reverse-error.log; # Same as above
    location / {
      proxy_pass http://$TARGET:$PORT;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection \$connection_upgrade;
      proxy_set_header X-Forwarded-Proto https;
      proxy_set_header Host \$host;
      proxy_http_version 1.1; # These are the headers I've found to both give access to LNbits, AND ensure that replies back are re-written with the lightning.domain.com URL as opposed to the private IP or .onion.
    }
    ssl on; # This is important and declares connections should be secured with SSL.
    ssl_certificate /etc/letsencrypt/live/$APP/fullchain.pem; # Point to the fullchain.pem
    ssl_certificate_key /etc/letsencrypt/live/$APP/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
    ssl_session_tickets off;

    # curl https://ssl-config.mozilla.org/ffdhe2048.txt > /path/to/dhparam
    ssl_dhparam /etc/nginx/dhparam.pem;

    # intermediate configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # HSTS (ngx_http_headers_module is required) (63072000 seconds)
    add_header Strict-Transport-Security "max-age=63072000" always;

    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
}" > $FILE

else
    echo
    echo "ERROR : Do not create a final configuration for $APP:$PORT"

    echo
    echo "ERROR : Adding the $APP was not successfull. Exiting."
    exit
fi

if [ $NEW_DHPARAM_NEEDED == "YES" ]; then
    echo
    echo "Create 4096b dhparam.pem. This WILL take a long time. Be patient."
    sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096
fi

echo
echo "Reload nginx server"
sudo systemctl reload nginx.service