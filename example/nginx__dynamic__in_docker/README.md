# dcinja example

Here is an example for generating a nginx config file when docker run. It will be executed
every time by Dockerfile `CMD`.

1. Prepare a Dockerfile, ref the folder example.
2. Build docker image `docker build . --tag dcinja_example_dynamic`.
3. Run the docker container and pass environment at cli, `docker run --rm -p 8080:8080 -it -e NAME=<your name> dcinja_example_dynamic`.
4. Launch browser and browse http://127.0.0.1:8080
5. Open "Developer Tools" > "Network Inspector", check the request header `X-Dcinja`, it should include the env 
   pass by docker run.
 