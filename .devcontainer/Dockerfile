FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# System packages
# ---------------------------------------------------------------------------
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        autotools-dev \
        autoconf \
        automake \
        pkg-config \
        libusb-1.0-0 \
        libusb-1.0-0-dev \
        libftdi1-2 \
        libftdi-dev \
        libhidapi-dev \
        git \
        ca-certificates \
        wget \
        xz-utils \
        bzip2 \
        make \
        libc6:i386 \
        libncurses5:i386 \
        libstdc++6:i386 \
        gdb-multiarch \
        python2.7 \
        python3 \
        python3-numpy \
        python3-scipy \
        python3-matplotlib \
        python3-serial \
        gcc-avr \
        binutils-avr \
        avr-libc \
        avrdude \
        openocd \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# ARM GCC toolchain 4.8 (original Mutable Instruments version)
# ---------------------------------------------------------------------------
RUN wget -q https://launchpad.net/gcc-arm-embedded/4.8/4.8-2013-q4-major/+download/gcc-arm-none-eabi-4_8-2013q4-20131204-linux.tar.bz2 \
        -O /tmp/arm-toolchain.tar.bz2 \
    && mkdir -p /usr/local/arm-4.8.3 \
    && tar -xjf /tmp/arm-toolchain.tar.bz2 -C /usr/local/arm-4.8.3 --strip-components=1 \
    && ln -s /usr/local/arm-4.8.3 /usr/local/arm \
    && rm /tmp/arm-toolchain.tar.bz2

ENV PATH="/usr/local/arm-4.8.3/bin:${PATH}"

# Mutable Instruments makefiles expect AVR tools here
RUN ln -s /usr /usr/local/CrossPack-AVR

# Mutable Instruments tooling invokes `python` (Python 2). Ubuntu 22.04 does
# not provide an unversioned `python` symlink, so create one explicitly.
RUN ln -s /usr/bin/python2.7 /usr/local/bin/python

# ---------------------------------------------------------------------------
# Python / locale
# ---------------------------------------------------------------------------
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US
ENV PYTHONPATH=.:${PYTHONPATH}
