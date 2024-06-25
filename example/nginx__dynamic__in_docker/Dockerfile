FROM nginx:1.27.0

COPY --from=falldog/dcinja:latest \
     /app/dcinja \
     /bin

ENV NAME='Hello World'

RUN echo '\
server { \n\
    listen       8080; \n\
    server_name  localhost; \n\
 \n\
    location / { \n\
        root   /usr/share/nginx/html; \n\
        index  index.html index.htm; \n\
    } \n\
 \n\
    add_header X-DCINJA "its dcinja header info! My name is `{{ NAME }}`"; \n\
} \n\
' \
>> /etc/nginx/my.template

CMD dcinja \
        -e NAME \
        -s /etc/nginx/my.template \
        > /etc/nginx/conf.d/my.conf \
    && nginx -g 'daemon off;'
