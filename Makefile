NAME = dcinja
INCLUDE = -I include
CFLAGS = -Wall -Os
CFLAGS_DEV = -Wall
DIST_DIR= dist

all:
	mkdir -p ${DIST_DIR}
	g++ ${INCLUDE} ${CFLAGS} -o ${DIST_DIR}/${NAME} ${NAME}.cpp

dev:
	mkdir -p ${DIST_DIR}
	g++ ${INCLUDE} ${CFLAGS_DEV} -o ${DIST_DIR}/${NAME} ${NAME}.cpp

	echo "TEST Name: {{ name }}" | ./${DIST_DIR}/${NAME} -j '{"name": "Foo"}'

build-docker:
	docker build -t dcinja:alpine -f docker/Dockerfile.alpine .
	docker build -t dcinja:ubuntu-20 -f docker/Dockerfile.ubuntu-20 .
	docker build -t dcinja:ubuntu-18 -f docker/Dockerfile.ubuntu-18 .