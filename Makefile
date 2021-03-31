NAME = dcinja
INCLUDE = -I src/include
CFLAGS = -Wall -Os -std=c++11 
CFLAGS_DEV = -Wall -std=c++11
CLANG_FLAGS = -Wall -Os -std=c++11 -stdlib=libstdc++ -DCLANG_DEFAULT_LINKER='lld'
DIST_DIR = dist
SRC_DIR = src

all: by-g++


by-g++:
	mkdir -p ${DIST_DIR}
	g++ ${INCLUDE} ${CFLAGS} -o ${DIST_DIR}/${NAME} ${SRC_DIR}/${NAME}.cpp

by-clang:
	mkdir -p ${DIST_DIR}
	clang++ ${INCLUDE} ${CLANG_FLAGS} -o ${DIST_DIR}/${NAME} ${SRC_DIR}/${NAME}.cpp

dev:
	mkdir -p ${DIST_DIR}
	g++ ${INCLUDE} ${CFLAGS_DEV} -o ${DIST_DIR}/${NAME} ${SRC_DIR}/${NAME}.cpp

	echo "TEST Name: {{ name }}" | ./${DIST_DIR}/${NAME} -j '{"name": "Foo"}'


fn-test-dcinja-linux-amd64 = docker run --rm -v `pwd`/${DIST_DIR}:/app $(1) sh -c "echo \"Normal: {{ name }}\" | /app/dcinja-linux-amd64 -j '{\"name\": \"$(1)\"}'"
fn-test-dcinja-alpine = docker run --rm -v `pwd`/${DIST_DIR}:/app $(1) sh -c "echo \"Normal: {{ name }}\" | /app/dcinja-alpine -j '{\"name\": \"$(1)\"}'"
test-docker: build-docker
	# linux-amd64
	rm -f ${DIST_DIR}/dcinja-linux-amd64
	docker run --name tmp-build-dcinja dcinja:linux-amd64
	docker cp tmp-build-dcinja:/app/dcinja ${DIST_DIR}/dcinja-linux-amd64
	docker rm tmp-build-dcinja
	
	$(call fn-test-dcinja-linux-amd64,ubuntu:20.04)
	$(call fn-test-dcinja-linux-amd64,ubuntu:18.04)
	$(call fn-test-dcinja-linux-amd64,ubuntu:16.04)
	$(call fn-test-dcinja-linux-amd64,debian:stretch)
	$(call fn-test-dcinja-linux-amd64,debian:buster)


	# alpine
	rm -f ${DIST_DIR}/dcinja-alpine
	docker run --name tmp-build-dcinja dcinja:alpine
	docker cp tmp-build-dcinja:/app/dcinja ${DIST_DIR}/dcinja-alpine
	docker rm tmp-build-dcinja
	
	docker build -t dcinja/alpine-3.9 --build-arg=VER=3.9 -f docker/Dockerfile.alpine-tester-base .
	docker build -t dcinja/alpine-3.10 --build-arg=VER=3.10 -f docker/Dockerfile.alpine-tester-base .
	docker build -t dcinja/alpine-3.11 --build-arg=VER=3.11 -f docker/Dockerfile.alpine-tester-base .
	docker build -t dcinja/alpine-3.12 --build-arg=VER=3.12 -f docker/Dockerfile.alpine-tester-base .
	$(call fn-test-dcinja-alpine,dcinja/alpine-3.9)
	$(call fn-test-dcinja-alpine,dcinja/alpine-3.10)
	$(call fn-test-dcinja-alpine,dcinja/alpine-3.11)
	$(call fn-test-dcinja-alpine,dcinja/alpine-3.12)


build-docker:
	docker build -t dcinja:dev -f docker/Dockerfile.dev .
	docker build -t dcinja:linux-amd64 -f docker/Dockerfile.linux-amd64 .
	docker build -t dcinja:alpine -f docker/Dockerfile.alpine .
