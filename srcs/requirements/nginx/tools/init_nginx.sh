#!/bin/sh

set -eu

if [ ! -f "$SSL_PATH/nginx-selfsigned.crt" ]; then
   echo "> creating SSL cerfitikate"
   mkdir -p $SSL_PATH
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
       -keyout "$SSL_PATH/nginx-selfsigned.key" \
       -out "$SSL_PATH/nginx-selfsigned.crt" \
       -subj "/C=CH/ST=Vaud/L=Lausanne/O=sydubois/CN=Inception"

  chmod 600 "$SSL_PATH/nginx-selfsigned.key"
  chmod 644 "$SSL_PATH/nginx-selfsigned.crt"
fi

echo "> executing nginx"

exec nginx -g "daemon off;"