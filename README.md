# ARMv6 Rust compilation image

## Background
I was working on a DIY project and needed to compile some
https://www.rust-lang.org[Rust] code I wrote for a
https://www.raspberrypi.org/products/raspberry-pi-zero-w/[Raspberry Pi Zero W].
There are
https://hackernoon.com/compiling-rust-for-the-raspberry-pi-49fdcd7df658[plenty]
of https://hackernoon.com/seamlessly-cross-compiling-rust-for-raspberry-pis-ede5e2bd3fe2[blog]
https://medium.com/@wizofe/cross-compiling-rust-for-arm-e-g-raspberry-pi-using-any-os-11711ebfc52b[posts]
and howto's on the web about how to cross-compile Rust for the Pi but most of
those resources are about newer Pi's which have the ARMv7 (or v8) architecture
(see https://en.wikipedia.org/wiki/Raspberry_Pi#Specifications[Wikipedia] for a
list of which Pis are based on which ARM architecture). The Zero W (and Zero)
are based on ARMv6, so it took a little extra Google-ing to figure out how to
compile for that. And since I don't really want to have a bunch of ARM packages
installed on my own x86 laptop I put everything in a
https://www.docker.com[Docker] image so it's nice and isolated.

Thanks to Reddit user Arakvk33 on who's
https://www.reddit.com/r/rust/comments/9io0z8/run_crosscompiled_code_on_rpi_0/[post]
this image is mostly based.

## Usage
The `cmd` in the Dockerfile is:
```
cargo build --release --target=arm-unknown-linux-gnueabihf
```
https://github.com/rust-lang/cargo[Cargo] knows how to cross-compile to ARMv6,
but we need the linker from the official Raspberry PI toolchain (installed in
the image). To use it, make sure your project has a `.cargo/config` file with at
least the following content:
```
[target.arm-unknown-linux-gnueabihf]
linker = "/rpi_tools/arm-bcm2708/arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc"
```

For Cargo to pick up on this config it needs to be in the working directory
(_inside_ the running docker container) where the command is run, so we need
to run `docker` with the `-w` switch. We should also mount our local Cargo
registry in the container (to avoid downloading the registry and all
dependencies each time) and provide an environment flag that tells `pkg-config`
it's allowed to cross-compile. Also, for good measure, don't run the container
as root (so that root doesn't own all the binaries that are produced) and also
set the `HOME` environment variable to the working directory so Cargo doesn't
attempt to create files in the home of a non-existent (in the container at
least) uid.

Putting that all together we get:
```
WORKDIR="/work"
docker run -t --rm \
       -u "$(id -u):$(id -g)" \
       -e "HOME=${WORKDIR}" \
       -w "${WORKDIR}" \
       -v "$(pwd):${WORKDIR}" \
       -v "${HOME}/.cargo/registry:/usr/local/cargo/registry" \
       gedweb/rust_armv6:latest
```

Copy and paste at will or use the link:compile_armv6.sh[script included with this repo].