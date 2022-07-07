# debian-qemu (previously debian-qemu)

The original purpose was to implement a way to run **ancient** Intel x86 based operating systems inside an OCI container (docker / podman). In the meantime it has grown a little bit more generic. This is why the repository was renamed to 
**debian-qemu**.

The original purpose of running ancient OSs and providing a showcase for educational purposes, of what OSs looked
like in the 1980-ies and 1990-ies works well.

The following OSs have been successfully bootstrapped to virtual hard disks (VHDs) in the QCOW2 format:
- MS-DOS 3.2 (HP branded)
- MS-DOS 3.3
- MS-DOS 5.0 (HP branded)
- MS-DOS 6.2
- MS-DOS 6.22
- DR-DOS 5.0

Besides that the following Windows versions have been installed on the MS-DOS 6.22 QCOW2 image:
- Microsoft Windows 3.0
- Microsoft Windows 3.1
- Microsoft Windows 3.11

In the meantime after giving it some thought, I also came up with a sister project called `alpine-qemu`.
The idea was to have a smaller container footprint and to use newer versions of QEMU. Both containers work
equally well and of course the QCOW2 files containing the actual OS, can be interchanged between the two.

## Purpose

To allow old applications to run (for nostalgia reasons) and to ensure that old operating system can participate in CI/CD scenarios. Using qemu (which is the current state of the art emulator on Linux platforms), it is possible to encapsulate and automate workloads that run on OSs which date back to the 1980-ies.

Main target for this exercise are of course Microsoft OSs, which by nature are not that easy to containerize.
This is why I simply wrap a container around QEMU. Given that this works successfully for MS-DOS 3.2, I
would conclude that it works as well for all other Microsoft OSs and Windows versions coming after that.

Example files on how the `qemu` is started can be found under `/usr/local/bin` inside the container or
under `srv/usr/local/bin` in the repository.

This also eliminates the need for VirtualBox installations (for me personally). I don't need the VirtualBox UI and I am 
happy using a WSL2 based Linux distro to fire up all my virtualized OSs.

## Concept

- OCI container image based on Debian Linux
- qemu running inside the container
- some helper tools and scripts

## Build

    podman build .
or

    docker build .

Then tag the resulting image as you like

    podman tag <image hash> debian-qemu:1.0
or

    docker tag <image hash> debian-qemu:1.0

## Usage

To prepare your working qemu hard disk image, you need some boot floppy images to bootstrap your environment. Place them in a place that you will then volume mount into the container. To persist the resulting qcow2 image, make sure to mount `/tmp/images` into the container.

Example:

    podman run -it --rm \
    -p 5901:5901 \
    -p 2323:2323 \
    -v /host-machine/some-floppy-path:/tmp/floppies \
    -v /host-machine/some-hdimg-path:/tmp/images \
    debian-qemu:1.0

Some wrapper shell scripts are included. They illustrate how to work with the container. The GUI of the image / the screen is exposed via VNC on display :1 (= port 5901). The qemu monitor port is exposed via telnet on port 2323. Via the qemu monitor, you are able to control the virtual machine running inside the container.

## qemu startup parameters

| qemu option | note                                   |
|-------------|----------------------------------------|
| `-m 4M`       | Memory: 4 MB (Megabytes) are fine for ancient DOS, if you want to be really generous, put 8M |
| `-vnc :1`     | Screen is exposed via VNC on port 5901 |
| `-monitor telnet:0.0.0.0:2323,server,nowait` | QEMU monitor is exposed via telnet on port 2323 |
| `-boot adc`   | Set boot sequence to floppy, cdrom, hard disc |

additional QEMU command line parameters can be found in the example files under `/usr/local/bin`.

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
