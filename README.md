get
===
Collection of build scripts for various projects.

Spec
----
Each formula will have each of the following functions

- build() { ... }
- clean() { ... }
- get() { ... }

and will be provided the following environment variables

- TARGET  (The directory to unpack files to)
- PREFIX  (The prefix to install files to)
- TMPDIR  (The temporary directory to install archives to)

Each function invocation assumes that the current working directory is set to
TARGET.

Usage
-----
```
$ git clone https://erhlee-bird/get.sh
$ cd ./get.sh
$ # Edit get.sh's PREFIX to point to the directory for your prefix.
$ ./get.sh -cgb get.sh
$ get.sh -cgb go
$ get.sh -cgb nim
...
```
