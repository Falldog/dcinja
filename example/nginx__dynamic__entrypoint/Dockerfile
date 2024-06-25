FROM nginx:1.27.0

COPY --from=falldog/dcinja:latest \
     /app/dcinja \
     /bin

ENV NAME='Hello World'
ENV CONTENT='FOOBAR'

RUN mkdir -p /code/template
COPY entrypoint.sh /code/
COPY template /code/template/

ENTRYPOINT ["/code/entrypoint.sh"]
