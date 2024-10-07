# JMRI Docker ![](https://img.shields.io/docker/pulls/jsa1987/jmri-docker.svg?maxAge=60480)

## Overview

Containerized installation of Java Model Railroad Interface (https://www.jmri.org/). The light-weight desktop environment accessible from the browser with NoVNC is based on [piopi/docker-desktop](https://github.com/piopi/docker-desktop).

## Usage

The image comes with noVNC to allow user to view the desktop environment running JMRI with their browsers. You will be able to access the noVNC windows at [http://localhost:6901](http://localhost:6901) or use your VNC viewer with `localhost:5901`.
JMRI WebServer and WiThrottle are enabled in the default configurations. These are accessible respectively at [http://localhost:12080](http://localhost:12080) and `hostname:12090`.

![](/screenshots/Capture.png)
*noVNC view of the Container running JMRI*

## Hardware support
Hardware conneted via Ethernet should be supported without any problems, this has been tested for DCC-EX stations connected via Ethernet. Hardware with serial connections over USB is supported (e.g. DCC-EX station connected via USB), but addional setup steps are needed (see below). 

## Setup

### Basic Example
When using hardware connected over Ethernet (e.g. DCC-EX Station over Ethernet):
```Shell
docker run -d -p 6901:6901 -p 5901:5901 -p 12080:12080 -p 12090:12090 -v jmri-home:/home/jmri --name jmri jsa1987/jmri-docker:stable
```
When using hardware connected over Serial/USB (e.g. DCC-EX Station connected via USB):
```Shell
docker run -d --device /dev/ttyUSBx:/dev/ttyUSB0 -p 6901:6901 -p 5901:5901 -p 12080:12080 -p 12090:12090 -v jmri-home:/home/jmri --name jmri jsa1987/jmri-docker:stable
```
Where /dev/ttyUSBx is the USB serial device on the host.

### Docker Compose Example 
1. Docker Compose example publishing ports on the localhost and using a docker volume to store configuration files.
```
version: "3"
volumes:
  home:
services:
  jmri:
    image: jsa1987/jmri-docker:stable
    container_name: jmri
    volumes:
      - jmri-home:/home/jmri
    environment:
      - NO_VNC_PORT=6901
      - VNC_COL_DEPTH=32
      - VNC_RESOLUTION=1366x768
    ports:
      - 5901:5901
      - 6901:6901
      - 12080:12080
      - 12090:12090
      - 1234:1234     #Optional for LoconetOverTCP
      - 2056:2056     #Optional for JSON server
      - 4303:4303     #Optional for SRCP server
      - 2048:2048     #Optional for SimpleServer
    devices:
      - /dev/ttyUSB0:/dev/ttyUSB0     #Optional needed only when using a hardware connected via serial
    hostname: hostname.domain.com
    restart: unless-stopped
```
NoVNC will be accessible at [http://localhost:6901](http://localhost:6901). JMRI WebServer will be accessible at [http://localhost:12080](http://localhost:12080) and WiThrottle will be reachable at `local_ip:12090`.

2. Docker Compose example using an IPVLAN and a bind mount (local path) to store configurations files.
```
version: "3"
networks:
  ipvlanname:
    external: true
services:
  jmri:
    image: jsa1987/jmri-docker:stable
    container_name: jmri
    volumes:
      - /local/path:/home/jmri
    environment:
      - NO_VNC_PORT=6901
      - VNC_COL_DEPTH=32
      - VNC_RESOLUTION=1366x768
    devices:
      - /dev/ttyUSB0:/dev/ttyUSB0     #Optional needed only when using a hardware connected via serial
    hostname: hostname.domain.com
    networks:
      ipvlanname:
        ipv4_address: xxx.xxx.xxx.xxx
    dns: xxx.xxx.xxx.yyy
    restart: unless-stopped
```
NoVNC will be accessible at `http://hostname.domain.com:6901` (or `http://xxx.xxx.xxx.xxx:6901`). JMRI WebServer will be accessible at `http://hostname.domain.com:12080` (or `http://xxx.xxx.xxx.xxx:6901`) and WiThrottle will be reachable at `http://hostname.domain.com:12090` (or `http://xxx.xxx.xxx.xxx:12090`).

### Environment variables

**NO_VNC_PORT** is used to set the noVNC port (default = 6901)

**VNC_COL_DEPTH** is used to set the VNC color depth (default = 32)

**VNC_RESOLUTION** is used to set the VNC resolution (default = 1366x768)

### Volumes

A docker volume or a bind mount should be used for the `/home/jmri` folder. This will allow JMRI setting, preferences etc. to be permanently saved and not to go lost when the container is re-started. When using a bind moung Read/Write access to the local folder is needed. 

### Ports

**6901** is the standard port exposed by default for the noVNC.

**5901** is the port exposed by default for VNC.

**12080** is the standard port exposed by default for WebServer.

**12090** is the standard port exposed by default for WiThrottle.

**1234** is the standard port exposed by default for LoconetOverTCP.

**2056** is the standard port exposed by default for JSON server.

**4303** is the standard port exposed by default for SRCP server.

**2048** is the standard port exposed by default for SimpleServer.

If the port used for noVNC is changed (via Environment variable) the port to be published shall be adjusted accordingly.
If the ports chosen for JMRI WebServer, WiThrottle, LoconetOverTCP, JSON server, SRCP server and/or Simple Server are changed in the JMRI Preferences then the ports to be published shall be adjusted accordingly. 

### Serial/USB
#### Linux host
When the docker container is run on a Linux host a Serial/USB device connected to the same host can be directly accessed with the `--device /dev/ttyUSBx:/dev/ttyUSB0` option, where `/dev/ttyUSBx` is the Serial/USB device on the host.

USBIP can be used if the device Serial/USB device is instead connected to a different machine on the network. In this case USBIP needs to be installed both on the machine to which the device is connected and on the host runnng docker (e.g. `sudo apt-get install usbip`). Once the remote USB device has been shared from the machine to which this is connected it then needs to be attached to the host (e.g. `sudo usbip attach -r xxx.xxx.xxx.xxx -b y-z` where xxx.xxx.xxx.xxx is the IP address of the remote machine sharing the USB device an y-z is the BUSID of the device). A USB/Serial device should be created (e.g. `/dev/ttyUSBx`) and the conatiner can then be started with the `--device /dev/ttyUSBx:/dev/ttyUSB0` option.

#### Windows host
When running the docker container on a Windows host Serial/USB device even if directtly connected to the host need to be shared via USBIP. The steps below assume that WSL2 has been setup (e.g. wsl --install -d Debian, see [How to install Linux on Windows with WSL](https://learn.microsoft.com/en-us/windows/wsl/install) for details) and Docker Desktop is istalled (see [Install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/) for details).

1) First of all we need to download latest release of [usbipd-win](https://github.com/dorssel/usbipd-win)

2) Open the Windows Terminal by searching the in the start menu, right clicking and select "Run as Administartor"

3) Run the `usbipd list` command to list the USB detected. You should see something like:
```
C:\WINDOWS\system32>usbipd list
Connected:
BUSID  VID:PID    DEVICE                                                        STATE
1-2    1bcf:28b8  Integrated Webcam                                             Not shared
1-8    8087:0a2b  Intel(R) Wireless Bluetooth(R)                                Not shared

Persisted:
GUID                                  DEVICE
```
4) Now connect the USB device to be shared and run the `usbipd list` command again. The new device should show up (USB2.0-Ser! in this case):
```
C:\WINDOWS\system32>usbipd list
Connected:
BUSID  VID:PID    DEVICE                                                        STATE
1-2    1bcf:28b8  Integrated Webcam                                             Not shared
1-3    1a86:7523  USB2.0-Ser!                                                   Not shared
1-8    8087:0a2b  Intel(R) Wireless Bluetooth(R)                                Not shared

Persisted:
GUID                                  DEVICE
```
  Note down he BUSID `1-3` in this case as this will be needed later.

5) To share the device run `C:\WINDOWS\system32>usbipd bind --busid=<busid>`, where `<busid>` is your BUSID.
6) Run the `usbipd list` command again and the device should now show as shared:
```
C:\WINDOWS\system32>usbipd list
Connected:
BUSID  VID:PID    DEVICE                                                        STATE
1-2    1bcf:28b8  Integrated Webcam                                             Not shared
1-3    1a86:7523  USB-SERIAL CH340 (COM3)                                       Shared
1-8    8087:0a2b  Intel(R) Wireless Bluetooth(R)                                Not shared

Persisted:
GUID                                  DEVICE
```

7) To attach the USB device to WSL2 run `usbipd attach --wsl --busid <busid>`
8) Open the WSL distibution termial and run `sudo apt-get update`
9) Install usbutils by running `sudo apt-get install usbutils`
10) Now run `lsusb` to confirm that the shared USB device is accessibe from within WSL. You should see your device listed:
```
user@DESKTOP-TANFHB2:/dev$ lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 002: ID 1a86:7523 QinHeng Electronics CH340 serial converter
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```
11) Check in `/dev` if the `ttyUSBx` USB/Serial device is preset. If not load the correct kernel module (e.g. `sudo modprobe ch341` for the example above) and then confirm you can now see the `/dev/ttyUSBx` device .
12) You are now ready to start the container with the `--device` option:
```Shell
docker run -d --device /dev/ttyUSBx:/dev/ttyUSB0 -p 6901:6901 -p 5901:5901 -p 12080:12080 -p 12090:12090 -v jmri-home:/home/jmri --name jmri jsa1987/jmri-docker:stable
```

## DockerHub

DockerHub link of the images:

- [https://hub.docker.com/r/jsa1987/jmri-docker](https://hub.docker.com/r/jsa1987/jmri-docker)

## Image Contents

- [Xvfb](http://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml) - X11 in a virtual framebuffer
- [TigerVNC](https://github.com/TigerVNC/tigervnc) - A VNC server that scrapes the above X11 server
- [noVNC](https://github.com/novnc/noVNC) - A HTML5 canvas vnc viewer
- [xfce4](https://www.xfce.org/) - A small desktop environment
- [openjdk-17-jre](https://packages.debian.org/sid/openjdk-17-jre) - Full Java runtime environment
- [JMRI](https://www.jmri.org/) - Java Model Railroad Interface

## Maintainers

[JSa1987](https://github.com/JSa1987)
