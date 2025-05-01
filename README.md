# dcinja

`dcinja` is the smallest binary size template engine, designed specifically for Docker images.

<!-- TOC -->
* [Overview](#overview)
* [Why dcinja?](#why-dcinja)
* [Dependency library](#dependency-library)
* [Binary size](#binary-size)
* [Command line usage](#command-line-usage)
* [Template document](#template-document)
* [Example](#example)
* [Real docker example](#real-docker-example)
* [Integration from release build](#integration-from-release-build)
* [Troubleshooting](#troubleshooting)
<!-- TOC -->


## Overview
`dcinja` leverages the powerful inja template engine, encapsulated within a Docker command-line binary. 
It offers a dynamic configuration generator for Docker containers, making it an excellent alternative 
to `envsubst`.

Unlike `envsubst`, which has limitations in style and usage, `dcinja` provides a more robust solution 
for generating various types of configurations. 

## Why dcinja?
For building Docker images, a smaller execution binary size is often preferable. Compiled with a C++ 
compiler, the dcinja binary is only 500KB ~ 600KB, making it highly suitable for dynamically generating 
configuration files at runtime within containers.


## Dependency library
`dcinja` is built upon robust, well-maintained C++ libraries, ensuring stability and performance:
* [inja](https://github.com/pantor/inja)
* [cxxopts](https://github.com/jarro2783/cxxopts)
* [nlohmann/json](https://github.com/nlohmann/json)

All dependencies are statically linked into the dcinja binary, meaning you do not need to install 
any of these libraries separately. This makes dcinja easy to use and integrate into your Docker images 
without additional setup.

## Binary size
arch | os      | dcinja size  | embedded libstdc++ 
-----|:--------|:------------:|--------------------
linux-amd64 | Ubuntu 16+, Debian stretch+ | 591KB | Y
alpine | alpine 3.9+ | 586KB | N (libstdc++.so 1.3MB+)

## Command line usage
Reference repo docker example to build `dcinja` and copy to `/bin/` as system command in docker image.


help description
```
  dcinja [OPTION...]

  -h, --help               print help
  -w, --cwd arg            change current working dir
  -s, --src arg            source template file path
  -d, --dest arg           dest template file path
  -e, --defines arg        define environment parameters, read system env when not assigned value, ex: `-e NAME=FOO -e NUM=1 -e MY_ENV`
      --force-system-envs  force to use system envs as final value
  -j, --json arg           define json content (e.g.: `-j {"NAME": "FOO"} -j {"PHONE": "123"}`)
  -f, --json-file arg      load json content from file (e.g. `-f p1.json -f p2.json`)
  -x, --expression         expression delimiters (e.g. "{{ }}")
  -t, --statement          statement delimiters (e.g. "{% %}")
  -c, --comment            comment delimiters (e.g. "{# #}")
  -v, --verbose            verbose mode
```

## Template document
[inja - document tutorial](https://github.com/pantor/inja#tutorial), It's compatible with [Jinja2](https://palletsprojects.com/p/jinja/).

* variables `{{ ... }}`
* statements `{% ... %}`
    * for loop `{% for key in data %} ... {% endfor %}`
    * condition `{% if value >= 1 %} ... {% else if value >= 0 %} ... {% endif %}`
    * include `{% include "xxx.template" %}`
    * assignment  `{% set name="test" %}`
* functions
    * upper `{{ upper("name") }}`
    * length `{{ length(data_list) }}`
    * ...
* comments  `{# ... #}`


## Example
input template from STDIN, output template to STDOUT
```
$ echo "TEST Name: {{ name }}" | dcinja -j '{"name": "Foo"}'
>>> TEST Name: Foo
```

input template from file, output template to file
```
$ dcinja -j '{"name": "Foo"}' -s input.template -d output.template
```

input json from file
```
$ dcinja -f param.json -s input.template -d output.template
```

define env from command line or system env
```
$ dcinja -e name=Foo -s input.template -d output.template
or
$ export name=Foo
$ dcinja -e name -s input.template -d output.template
```

parameter context priority:
`-e` >> `-j` >> `-f`
1. `-f`: json file
2. `-j`: json content defiend in command line
3. `-e`: environment parameter defeind in command line or system
4. `--force-system-envs`: force to use system envs as final value
```
$ cat name.json
>>> {"name": "P1"}
$ echo "Name: {{ name }}" | dcinja -f name.json
>>> Name: P1
$ echo "Name: {{ name }}" | dcinja -j '{"name": "P2"}' -e name=P3 -f name.json
>>> Name: P3
```

## Real docker example
* nginx, dynamic generate nginx.conf and index.html by entrypoint. [Example Link](example/nginx__dynamic__entrypoint/README.md).
* nginx, dynamic generate nginx.conf and header in Dockerfile. [Example Link](example/nginx__dynamic__in_docker/README.md).
* nginx, generate nginx.conf and header in Dockerfile at build time. [Example Link](example/nginx__static__in_docker/README.md).


## Integration from release build
Dockerfile example, download `dcinja` into docker image /bin/ as command. Copy the `dcinja` executable file via 
docker `COPY --from` command.

**ubuntu**

```
FROM ubuntu:latest
COPY --from=falldog/dcinja:latest /app/dcinja /bin

# testing, check dcinja working normal
RUN dcinja -h \
        && echo "Normal: {{ name }}" | dcinja -j '{"name": "TEST"}'
# ...
```

**alpine**

Need to install `libstdc++` package.

```
FROM alpine:latest
RUN apk --no-cache add libstdc++
COPY --from=falldog/dcinja:latest-alpine /app/dcinja /bin

# testing, check dcinja working normal
RUN dcinja -h \
        && echo "Normal: {{ name }}" | dcinja -j '{"name": "TEST"}'
# ...
```

## Troubleshooting
The binary size build by c++ compiler, it's platform sensitive, the minimum c++ compiler support is C++11. It will dependent with `libstdc++.so`. 

ldd result at ubuntu 18.04
```
$ ldd dcinja
	linux-vdso.so.1 (0x00007ffe933a9000)
	libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f376bc40000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f376b8a2000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f376b68a000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f376b299000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f376c220000)
```

Need to make sure your environment have the correct c++ runtime on
* Ubuntu
```
apt-get update
apt-get install libstdc++
```
(Only support ubuntu 16.04+)

* Alpine
```
apk add libstdc++
```
