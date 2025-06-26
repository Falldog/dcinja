include Makefile.base

VERSION = 1.4.1
RELEASE_DIR = $(abspath ${DIST_DIR}/release/${VERSION})
ALL_PLATFORM=linux/amd64,linux/arm64,linux/arm/v7

# release images and related arch as below
# format as <image-name>:<tag-name>
#           + arch-1
#           + arch-2
#           ...
#
### glibc
# dcinja:latest
#   + linux/amd64
#   + linux/arm64
#   + linux/arm/v7
# dcinja:1.x
#   + linux/amd64
#   + linux/arm64
#   + linux/arm/v7
#
### alpine
# dcinja:latest-alpine
#   + linux/amd64
#   + linux/arm64
#   + linux/arm/v7
# dcinja:1.x-alpine
#   + linux/amd64
#   + linux/arm64
#   + linux/arm/v7

fn-test-dcinja = \
    export lib="$(1)" \
    && export platform="$(2)" \
    && export image="$(3)" \
    \
    && docker run \
        --rm \
        --platform=$${platform} \
        -v `pwd`/${DIST_DIR}/$${lib}/$${platform}:/app \
        $${image} \
        sh -c "echo \"Normal: {{ name }}\" \
            | /app/dcinja -j '{\"name\": \"$${image}\"}'"

fn-build-dcinja = \
    export lib="$(1)" \
    && export platform="$(2)" \
    && export tag="$(3)" \
    && export dockerfile="$(4)" \
    && export dist="$(DIST_DIR)/$${lib}/$${platform}" \
    \
    && mkdir -p $${dist} \
	&& docker buildx build \
	    --platform=$${platform} \
	    --tag dcinja:$${tag} \
	    --load \
	    -f docker/$${dockerfile} \
	    . \
    && docker run --name tmp-build-dcinja --platform=$${platform} dcinja:$${tag} \
	&& docker cp tmp-build-dcinja:/app/dcinja $${dist}/dcinja \
	&& docker rm tmp-build-dcinja

# release multi-platform by buildx and push it to dockerhub
# buildx support push single tag name with multiple platform, and allow user to pull image by specific platform arch.
fn-release-dcinja = \
    export tag="$(1)" \
    && export dockerfile="$(2)" \
    \
	&& docker buildx build \
	    --platform=$(ALL_PLATFORM) \
	    --tag falldog/dcinja:$${tag} \
	    --push \
	    -f docker/$${dockerfile} \
	    .

fn-compress-file = \
    export lib="$(1)" \
    && export platform="$(2)" \
    && export suffix="$(3)" \
    \
    && cd $(DIST_DIR)/$${lib}/$${platform} \
    && tar cvzf $(RELEASE_DIR)/dcinja-$(VERSION).$${suffix}.tar.gz dcinja


test-docker: build
	### glibc
	# param: (1) libc (2) platform (3) image name
	$(call fn-test-dcinja,glibc,linux/amd64,ubuntu:20.04)
	$(call fn-test-dcinja,glibc,linux/amd64,ubuntu:18.04)
	$(call fn-test-dcinja,glibc,linux/amd64,ubuntu:16.04)
	$(call fn-test-dcinja,glibc,linux/amd64,debian:stretch)
	$(call fn-test-dcinja,glibc,linux/amd64,debian:buster)


	### alpine
	# need build the image include libstd++
	docker build --platform=linux/amd64 -t dcinja/alpine-3.9 --build-arg=VER=3.9 -f docker/Dockerfile.alpine-tester-base .
	docker build --platform=linux/amd64 -t dcinja/alpine-3.10 --build-arg=VER=3.10 -f docker/Dockerfile.alpine-tester-base .
	docker build --platform=linux/amd64 -t dcinja/alpine-3.11 --build-arg=VER=3.11 -f docker/Dockerfile.alpine-tester-base .
	docker build --platform=linux/amd64 -t dcinja/alpine-3.12 --build-arg=VER=3.12 -f docker/Dockerfile.alpine-tester-base .
	# param: (1) libc (2) platform (3) image name
	$(call fn-test-dcinja,alpine,linux/amd64,dcinja/alpine-3.9)
	$(call fn-test-dcinja,alpine,linux/amd64,dcinja/alpine-3.10)
	$(call fn-test-dcinja,alpine,linux/amd64,dcinja/alpine-3.11)
	$(call fn-test-dcinja,alpine,linux/amd64,dcinja/alpine-3.12)


# only focus on alpine environment
# for quick testing
pytest: build-alpine
	docker build -t dcinja:pytest-alpine -f docker/Dockerfile.alpine-test .
	docker run --rm -it dcinja:pytest-alpine


build: build-linux build-alpine


build-linux:
	# param: (1) libc (2) platform (3) tag name (4) Dockerfile name
	$(call fn-build-dcinja,glibc,linux/amd64,linux-amd64,Dockerfile.linux)
	$(call fn-build-dcinja,glibc,linux/arm64,linux-arm64,Dockerfile.linux)
	$(call fn-build-dcinja,glibc,linux/arm/v7,linux-arm-v7,Dockerfile.linux)


build-alpine:
	# param: (1) libc (2) platform (3) tag name (4) Dockerfile name
	$(call fn-build-dcinja,alpine,linux/amd64,alpine-amd64,Dockerfile.alpine)
	$(call fn-build-dcinja,alpine,linux/arm64,alpine-arm64,Dockerfile.alpine)
	$(call fn-build-dcinja,alpine,linux/arm/v7,alpine-arm-v7,Dockerfile.alpine)


build-dev:
	docker build -t dcinja:dev -f docker/Dockerfile.dev .


release: build
	mkdir -p ${RELEASE_DIR}/
	# param: (1) libc (2) platform (3) filename suffix
	$(call fn-compress-file,glibc,linux/amd64,linux-amd64)
	$(call fn-compress-file,glibc,linux/arm64,linux-arm64)
	$(call fn-compress-file,glibc,linux/arm/v7,linux-arm-v7)
	$(call fn-compress-file,alpine,linux/amd64,alpine-amd64)
	$(call fn-compress-file,alpine,linux/arm64,alpine-arm64)
	$(call fn-compress-file,alpine,linux/arm/v7,alpine-arm-v7)


publish-dockerhub:
	# param: (1) tag (2) dockerfile
	$(call fn-release-dcinja,$(VERSION),Dockerfile.linux)
	$(call fn-release-dcinja,$(VERSION)-alpine,Dockerfile.alpine)
	$(call fn-release-dcinja,latest,Dockerfile.linux)
	$(call fn-release-dcinja,latest-alpine,Dockerfile.alpine)

