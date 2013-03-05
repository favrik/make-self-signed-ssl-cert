#!/bin/sh
PASS=nomames
openssl genrsa -des3 -passout pass:$PASS  -out server.key 1024
openssl req -new -passin pass:$PASS -subj "/C=US/ST=Oregon/L=Portland/CN=$1" -key server.key -out server.csr
cp server.key server.key.org
openssl rsa -in server.key.org -passin pass:$PASS -out server.key
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt


APACHE=`ps -ef|awk '/[a]pache/{print $8}'|head -n1`
APACHE_DIR=`$APACHE -V | grep HTTPD_ROOT | cut -d '"' -f 2`

sudo cp server.crt $APACHE_DIR/ssl/$1.crt
sudo cp server.key $APACHE_DIR/ssl/$1.key

echo "
SSLEngine on
SSLCertificateFile $APACHE_DIR/ssl/$1.crt
SSLCertificateKeyFile $APACHE_DIR/ssl/$1.key
SetEnvIf User-Agent \".*MSIE.*\" nokeepalive ssl-unclean-shutdown
 "
