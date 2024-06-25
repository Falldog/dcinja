# dcinja example

Here is an example for building a nginx config file and index.html when docker running. It will be executed 
every time by `entrypoint.sh`.

1. Prepare a Dockerfile, ref the folder example.
2. Build docker image `docker build . --tag dcinja_example_dynamic_entrypoint`.
3. Run the docker container and pass environment at cli, `docker run --rm -p 8080:8080 -it -e NAME=<your name> -e CONTENT=<your content> dcinja_example_dynamic_entrypoint`.
4. Launch browser and browse http://127.0.0.1:8080
5. Check the web page result, should contain the `NAME` and `CONTENT` which define by env.
 