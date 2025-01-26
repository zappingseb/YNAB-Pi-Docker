#!/bin/bash

# Path to the config.json file and nginx.conf
CONFIG_FILE="/usr/share/nginx/html/config.json"
NGINX_CONF="/etc/nginx/conf.d/default.conf"

API_SECRET="X"
containerid="X"
type="X"
what="X"

# Copy the config.json to the temporary file
cp $CONFIG_FILE /tmp/config.json

# Use envsubst to replace the environment variables in the copied config file
envsubst < /tmp/config.json > /tmp/config_with_env.json

jq . /tmp/config_with_env.json

# Check if jq encountered an error
if [ $? -ne 0 ]; then
  echo "Error: Invalid JSON format"
  echo "Contents of /tmp/config_with_env.json:"
  cat /tmp/config_with_env.json
  exit 1
fi

# Read the config.json (now with environment variables substituted) and extract the backends
jq -r '.backends[] | "\(.containerid)"' /tmp/config_with_env.json | while read -r CONTAINER_ID; do

    # Generate the location block to be added to the nginx.conf
    LOCATION_BLOCK="
location /api/$CONTAINER_ID/ {
    proxy_pass http://$CONTAINER_ID:80/;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
"

# Write the location block to a temporary file

    echo "$LOCATION_BLOCK" > /tmp/location_block.txt
    cat /tmp/location_block.txt
    sed -i -e '$d' $NGINX_CONF
    sed -i -e '$r /tmp/location_block.txt' $NGINX_CONF
    echo "}" >> $NGINX_CONF
done
