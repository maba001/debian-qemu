# docker-msdos

This repo implements a way to run **ancient** Intel x86 based operating systems inside an OCI container (docker / podman).

## Purpose

To allow old applications to run (for nostalgia reasons) and to ensure that old operating system can participate in CI/CD scenarios. Using qemu (which is the current state of the art emulator on Linux platforms), it is possible to encapsulate and automate workloads that run on OSs which date back to the 1980ies.

## Concept

- OCI container image based on Debian Linux
- qemu running inside the container
- some helper tools and scripts

## Build

    podman build .
or

    docker build .

Then tag the resulting image as you like

    podman tag <image hash> docker-msdos:1.0
or

    docker tag <image hash> docker-msdos:1.0

## Usage

To prepare your working qemu hard disk image, you need some boot floppy images to bootstrap your environment. Place them in a place that you will then volume mount into the container. To persist the resulting qcow2 image, make sure to mount `/tmp/images` into the container.

Example:

    podman run -it --rm \
    -p 5901:5901 \
    -p 2323:2323 \
    -v /host-machine/some-floppy-path:/tmp/floppies \
    -v /host-machine/some-hdimg-path:/tmp/images \
    docker-msdos:1.0

Some wrapper shell scripts are included. They illustrate how to work with the container. The GUI of the image / the screen is exposed via VNC on display :1 (= port 5901). The qemu monitor port is exposed via telnet on port 2323. Via the qemu monitor, you are able to control the virtual machine running inside the container.

## qemu startup parameters

| qemu option | note                                   |
|-------------|----------------------------------------|
| `-m 4M`       | Memory: 4 MB (Megabytes) are fine for ancient DOS, if you want to be really generous, put 8M |
| `-vnc :1`     | Screen is exposed via VNC on port 5901 |
| `-monitor telnet:0.0.0.0:2323,server,nowait` | QEMU monitor is exposed via telnet on port 2323 |
| `-cdrom`      | Emulate a CD drive, just in case |
| `-boot adc`   | Set boot sequence to floppy, cdrom, hard disc |

## qemu monitor commands needed for bootstrapping

| qemu command | used for                                   |
|-------------|----------------------------------------|
| `change floppy0 <path-to-floppy-img>` | virtually insert or change a floppy |
| `system_reset` | re-boot the VM |
| `eject floppy0` | remove floppy from floppy drive |

### bootstrapping strategy

1. start the container and qemu (e.g. using one of the helper scripts)
2. connect to the screen via VNC
3. insert the first install disk via the qemu monitor port
4. reboot - wait for the install screen to come up
5. follow the install sequence, change and eject floppies as directed by the installer
