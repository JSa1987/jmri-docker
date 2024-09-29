# JMRI Docker ![](https://img.shields.io/docker/pulls/jsa1987/jmri-docker.svg?maxAge=60480)

## Overview

Containerized installation of Java Model Railroad Interface (https://www.jmri.org/). The light-weight desktop environment accessible from the browser with NoVNC is based on [piopi/docker-desktop](https://github.com/piopi/docker-desktop).

## Usage

The image comes with noVNC to allow user to view the desktop environment running JMRI with their browsers. You will be able to access the noVNC windows at [http://localhost:6901](http://localhost:6901) or use your VNC viewer with `localhost:5901`.
JMRI WebServer and WiThrottle are enabled in the default configurations. These are accessible respectively at [http://localhost:12080](http://localhost:12080) and `hostname:12090`.

![](/screenshots/Capture.png)
*noVNC view of the Container running JMRI*

## Setup

### Basic Example

```Shell
docker run -d -p 6901:6901 -p 5901:5901 -p 12080:12080 -p 12090:12090 -v home:/home/jmri --name jmri jsa1987/jmri-docker:stable
```

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
      - home:/home/jmri
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

A docker volume or a bind mount should be used for the `/home/jmri` folder. This will allow JMRI setting, preferences etc. to be permanently saved and not to go lost when the container is re-started.

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
