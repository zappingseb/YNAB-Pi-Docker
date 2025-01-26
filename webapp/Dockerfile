FROM node:16-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
RUN apk add --no-cache bash jq
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY config.json /usr/share/nginx/html/config.json

COPY nginx/generate_nginx_conf.sh /usr/local/bin/generate_nginx_conf.sh

# Make the script executable
RUN chmod +x /usr/local/bin/generate_nginx_conf.sh

RUN chmod 777 /etc/nginx/conf.d/default.conf
# Run the script to modify nginx.conf with dynamic locations
RUN set -e && /usr/local/bin/generate_nginx_conf.sh
RUN chmod 750 /etc/nginx/conf.d/default.conf

# Add script to replace config values
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh


EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
