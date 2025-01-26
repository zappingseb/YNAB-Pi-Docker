#!/bin/sh

# Replace environment variables in config.json
sed -i "s|\${API_SECRET}|$API_SECRET|g" /usr/share/nginx/html/config.json

exec "$@"