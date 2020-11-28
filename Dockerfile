FROM nginx:mainline-alpine

COPY getting-started.html /usr/share/nginx/html/getting-started.html

COPY geoserver.html /usr/share/nginx/html/geoserver.html
