# dcinja
------------
The smallest binary size of template engine, born for docker image

Generate template file by powerful template engine `inja`. This project wrap it in 
docker command line binary. 

For building docker image, smaller execution binary size should be better.
The project `dcinja` compile by c++ compiler, the binary size is only **500KB ~ 600KB**.
It's very suitable to use `dcinja` in container to dynamic generate configuration 
file at run-time.

## Dependency library
* [inja](https://github.com/pantor/inja)
* [cxxopts](https://github.com/jarro2783/cxxopts)
* [nlohmann/json](https://github.com/nlohmann/json)

## Binary size
os           | dcinja size  | embedded libstdc++ 
-------------|:------------:|--------------------
Ubuntu 20.04 | 597KB | Y
Ubuntu 18.04 | 610KB | Y
Debian 10 (buster) | 591KB | Y
Debian 9 (stretch) | 601KB | Y
Alpine 3.12 | 562KB | N (libstdc++.so 1.6MB)
Alpine 3.9 | 585KB | N (libstdc++.so 1.3MB)

## Command line usage
Reference repo docker example to build `dcinja` and copy to `/bin/` as system command in docker image.


help description
```
  dcinja [OPTION...]

  -h, --help      print help
  -s, --src arg   source template file path
  -d, --dest arg  dest template file path
  -e, --defines arg  define string parameters, ex: `-e NAME=FOO -e NUM=1`
  -j, --json arg  define json content, ex: `-j {'NAME': 'FOO'}`
  -f, --json-file arg  load json content from file
  -v, --verbose   verbose mode (default: true)
```

## Template document
[inja - document tutorial](https://github.com/pantor/inja#tutorial), It's compatiable with `Jinja2`.

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

parameter context priority:
`-e` >> `-j` >> `-f`
1. `-f`: json file
2. `-j`: json content defiend in command line
3. `-e`: string parameter defeind in command line
```
$ cat name.json
>>> {"name": "P1"}
$ echo "Name: {{ name }}" | dcinja -f name.json
>>> Name: P1
$ echo "Name: {{ name }}" | dcinja -j '{"name": "P2"}' -e name=P3 -f name.json
>>> Name: P3
```

## Integration
Dockerfile example, using multi-stage to build `dcinja` and copy to your final docker image /bin/ as command

```
FROM ubuntu as dcinja-builder
LABEL maintainer=falldog

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        \
        # build
        g++ \
        make \
        \
        # clone source code
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /code \
    && git clone https://github.com/Falldog/dcinja.git /code

WORKDIR /code
RUN make


FROM ubuntu
COPY --from=dcinja-builder /code/dist/dcinja /bin/
# ...
```


## Defect
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
(Only support ubuntu 20.04, 18.04. Version before 16.04 default g++ is not support)

* Alpine
```
apk add libstdc++
```
