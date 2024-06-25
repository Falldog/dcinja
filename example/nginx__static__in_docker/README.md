# dcinja example

Here is an example for building a nginx config file when build docker. Once the docker image is ready. 
The config will not be changed.

1. Prepare a Dockerfile, ref the folder example.
2. Create an ARG, and build docker with `--build-arg`. For the example, 
   the command line would be `docker build . --tag dcinja_example --build-arg NAME=YOYO`.
3. Run the docker example, `docker run --rm -p 8080:8080 -it dcinja_example`.
4. Launch browser and browse http://127.0.0.1:8080
5. Open "Developer Tools" > "Network Inspector", check the request header "X-Dcinja", it should include the building arg.
 