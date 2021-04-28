include Makefile.base

VERSION = 1.3
RELEASE_DIR = $(abspath ${DIST_DIR}/release/${VERSION})

fn-test-dcinja-linux-amd64 = docker run --rm -v `pwd`/${DIST_DIR}:/app $(1) sh -c "echo \"Normal: {{ name }}\" | /app/linux-amd64/dcinja -j '{\"name\": \"$(1)\"}'"
fn-test-dcinja-alpine = docker run --rm -v `pwd`/${DIST_DIR}:/app $(1) sh -c "echo \"Normal: {{ name }}\" | /app/alpine/dcinja -j '{\"name\": \"$(1)\"}'"

test-docker: build
	# linux-amd64
	$(call fn-test-dcinja-linux-amd64,ubuntu:20.04)
	$(call fn-test-dcinja-linux-amd64,ubuntu:18.04)
	$(call fn-test-dcinja-linux-amd64,ubuntu:16.04)
	$(call fn-test-dcinja-linux-amd64,debian:stretch)
	$(call fn-test-dcinja-linux-amd64,debian:buster)


	# alpine
	# need build the image include libstd++
	docker build -t dcinja/alpine-3.9 --build-arg=VER=3.9 -f docker/Dockerfile.alpine-tester-base .
	docker build -t dcinja/alpine-3.10 --build-arg=VER=3.10 -f docker/Dockerfile.alpine-tester-base .
	docker build -t dcinja/alpine-3.11 --build-arg=VER=3.11 -f docker/Dockerfile.alpine-tester-base .
	docker build -t dcinja/alpine-3.12 --build-arg=VER=3.12 -f docker/Dockerfile.alpine-tester-base .

	$(call fn-test-dcinja-alpine,dcinja/alpine-3.9)
	$(call fn-test-dcinja-alpine,dcinja/alpine-3.10)
	$(call fn-test-dcinja-alpine,dcinja/alpine-3.11)
	$(call fn-test-dcinja-alpine,dcinja/alpine-3.12)


# only focus on alpine environment
# for quick testing
pytest: build-alpine
	docker build -t dcinja:pytest-alpine -f docker/Dockerfile.alpine-test .
	docker run --rm -it dcinja:pytest-alpine


build: build-linux build-alpine


build-linux:
	docker build -t dcinja:linux-amd64 -f docker/Dockerfile.linux-amd64 .
	# linux-amd64
	mkdir -p ${DIST_DIR}/linux-amd64
	rm -f ${DIST_DIR}/linux-amd64/dcinja
	docker run --name tmp-build-dcinja dcinja:linux-amd64
	docker cp tmp-build-dcinja:/app/dcinja ${DIST_DIR}/linux-amd64/dcinja
	docker rm tmp-build-dcinja


build-alpine:
	docker build -t dcinja:alpine -f docker/Dockerfile.alpine .
	# alpine
	mkdir -p ${DIST_DIR}/alpine
	rm -f ${DIST_DIR}/alpine/dcinja
	docker run --name tmp-build-dcinja dcinja:alpine
	docker cp tmp-build-dcinja:/app/dcinja ${DIST_DIR}/alpine/dcinja
	docker rm tmp-build-dcinja


build-dev:
	docker build -t dcinja:dev -f docker/Dockerfile.dev .


release: build
	mkdir -p ${RELEASE_DIR}/
	cd ${DIST_DIR}/alpine \
		&& tar cvzf ${RELEASE_DIR}/dcinja-${VERSION}.alpine.tar.gz dcinja
	cd ${DIST_DIR}/linux-amd64 \
		&& tar cvzf ${RELEASE_DIR}/dcinja-${VERSION}.linux-amd64.tar.gz dcinja