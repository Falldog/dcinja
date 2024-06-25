#!/usr/bin/env bash

dcinja -e CONTENT -e NAME \
       -s /code/template/index.html.template \
       > /code/index.html

dcinja -e NAME \
       -s /code/template/nginx.conf.template \
       > /etc/nginx/conf.d/my.conf \

nginx -g 'daemon off;'
