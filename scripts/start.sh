#!/bin/bash

set -e

# Display PHP error's or not
if [[ "$ERRORS" != "1" ]] ; then
 echo php_flag[display_errors] = off >> /etc/php7/php-fpm.conf
else
 echo php_flag[display_errors] = on >> /etc/php7/php-fpm.conf
fi

if [ ! -z ${S3_ACCESS_KEY_ID} ]; then
  echo "Downloading artifact..."

  mc config host add s3 $S3_ENDPOINT $S3_ACCESS_KEY_ID $S3_SECRET_ACCESS_KEY --api S3v4
  if [ ! -z ${MC_INSECURE} ]; then
    mc --insecure cp s3/$S3_BUCKET/$DEPLOYMENT_NAME/$VERSION.tar.gz /tmp/
  else
    mc cp s3/$S3_BUCKET/$DEPLOYMENT_NAME/$VERSION.tar.gz /tmp/
  fi
  rm /root/.mc/config.json

  echo "Extracting artifact..."
  tar xf /tmp/$VERSION.tar.gz -C /app
fi

# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
