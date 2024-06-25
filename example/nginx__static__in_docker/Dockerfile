FROM nginx:1.27.0

COPY --from=falldog/dcinja:latest \
     /app/dcinja \
     /bin

ARG NAME="Hello World"

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
' | dcinja -e NAME \
>> /etc/nginx/conf.d/my.conf

