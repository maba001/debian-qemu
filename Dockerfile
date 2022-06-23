FROM debian:bullseye

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y qemu-system-x86 vim telnet \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY /src/root/ /root/
COPY /src/etc/profile /etc/
COPY /src/etc/bash.bashrc /etc/
COPY /src/usr/ /usr/

RUN mkdir -p /opt/floppies
COPY /src/opt/floppies/ /opt/floppies/

ENV SHELL=/bin/bash
WORKDIR /root
