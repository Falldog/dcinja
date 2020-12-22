NAME = dcinja
INCLUDE = -I src/include
CFLAGS = -Wall -Os
CFLAGS_DEV = -Wall
DIST_DIR = dist
SRC_DIR = src

all:
	mkdir -p ${DIST_DIR}
	g++ ${INCLUDE} ${CFLAGS} -o ${DIST_DIR}/${NAME} ${SRC_DIR}/${NAME}.cpp

dev:
	mkdir -p ${DIST_DIR}
	g++ ${INCLUDE} ${CFLAGS_DEV} -o ${DIST_DIR}/${NAME} ${SRC_DIR}/${NAME}.cpp

	echo "TEST Name: {{ name }}" | ./${DIST_DIR}/${NAME} -j '{"name": "Foo"}'

build-docker:
	docker build -t dcinja:dev -f docker/Dockerfile.dev .
	docker build -t dcinja:ubuntu-20 -f docker/Dockerfile.ubuntu-20 .
	docker build -t dcinja:ubuntu-18 -f docker/Dockerfile.ubuntu-18 .
	docker build -t dcinja:debian-buster -f docker/Dockerfile.debian-buster .
	docker build -t dcinja:debian-stretch -f docker/Dockerfile.debian-stretch .
	docker build -t dcinja:alpine-3.12 -f docker/Dockerfile.alpine-3.12 .
	docker build -t dcinja:alpine-3.9 -f docker/Dockerfile.alpine-3.9 .

	# dump binary size
	docker run --rm --entrypoint="" dcinja:ubuntu-20 ls -alh /app/dcinja | awk '{print $$5}'
	docker run --rm --entrypoint="" dcinja:ubuntu-18 ls -alh /app/dcinja | awk '{print $$5}'
	docker run --rm --entrypoint="" dcinja:debian-buster ls -alh /app/dcinja | awk '{print $$5}'
	docker run --rm --entrypoint="" dcinja:debian-stretch ls -alh /app/dcinja | awk '{print $$5}'
	docker run --rm --entrypoint="" dcinja:alpine-3.12 ls -alh /app/dcinja | awk '{print $$5}'
	docker run --rm --entrypoint="" dcinja:alpine-3.9 ls -alh /app/dcinja | awk '{print $$5}'