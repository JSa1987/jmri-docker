FROM debian:trixie-slim

ENV JMRI_DOWNLOAD_URL=https://builds.jmri.org/jenkins/job/testreleases/job/5.15.10/lastSuccessfulBuild/artifact/dist/release/JMRI.5.15.10+Re5fcc00c8a.tgz \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    VNC_COL_DEPTH=32 \
    VNC_RESOLUTION=1360x768 \
    USER_ID=61000 \
    GROUP_ID=61000
    
ENV DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm

# disable shared memory X11 affecting Chromium
ENV QT_X11_NO_MITSHM=1 \
    _X11_NO_MITSHM=1 \
    _MITSHM=0
    
# Language/locale settings
# replace en_US by your desired locale setting, 
# for example de_DE for german.
ENV LANG=en_US.UTF-8

# In order:
# Install system basics: dbus-x11 procps psmisc kmod
# Install DE essentials: xdg-utils xdg-user-dirs menu-xdg desktop-file-utils
# Install LXQT desktop: lxqt-core qtwayland5 xfwm4 featherpad lxqt-about lxqt-config lxqt-qtplugin oxygen-icon-theme lxqt-system-theme qlipper qterminal
# Install environment for noVNC: sudo git ca-certificates xvfb xauth tigervnc-standalone-server tigervnc-common python3
# Install Environment for JMRI and install additional software: wget bzip2 openjdk-21-jre usbutils vim firefox-esr nano
# Clean up

RUN apt-get update && \
    apt-get install -y \
    dbus-x11 procps psmisc kmod && \
    apt-get install -y --no-install-recommends \
    xdg-utils xdg-user-dirs menu-xdg desktop-file-utils && \
    echo $LANG UTF-8 > /etc/locale.gen && \
    apt-get install -y locales && \
    update-locale --reset LANG=$LANG && \
    apt-get install -y --no-install-recommends \
    lxqt-core qtwayland5 xfwm4 featherpad lxqt-about lxqt-config lxqt-qtplugin oxygen-icon-theme lxqt-system-theme qlipper qterminal && \   
    apt-get install --no-install-recommends -y \
    sudo git ca-certificates xvfb xauth tigervnc-standalone-server tigervnc-common python3 && \ 
    apt-get install --no-install-recommends -y \
    wget bzip2 openjdk-21-jre usbutils vim firefox-esr nano && \
    rm -vf /opt/lib*.deb; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# config lxqt
RUN mkdir -p /etc/skel/.config/lxqt && \
    echo '[General]\n\
__userfile__=true\n\
icon_follow_color_scheme=true\n\
icon_theme=oxygen\n\
single_click_activate=false\n\
theme=light\n\
tool_bar_icon_size=24\n\
tool_button_style=ToolButtonTextBesideIcon\n\
wallpaper_override=true\n\
\n\
[Qt]\n\
doubleClickInterval=400\n\
font="Sans,11,-1,5,50,0,0,0,0,0"\n\
style=Fusion\n\
wheelScrollLines=3\n\
' >/etc/skel/.config/lxqt/lxqt.conf && \
    echo '[General]\n\
__userfile__=true\n\
[Environment]\n\
TERM=qterminal\n\
' >/etc/skel/.config/lxqt/session.conf

# config pcmanfm-qt
RUN mkdir -p /etc/skel/.config/pcmanfm-qt/lxqt && \
    echo '[Behavior]\n\
QuickExec=true\n\
[Desktop]\n\
ShowHidden=true\n\
Wallpaper=/usr/share/lxqt/wallpapers/waves-logo.png\n\
WallpaperMode=stretch\n\
' >/etc/skel/.config/pcmanfm-qt/lxqt/settings.conf

# config panel / add some launchers
RUN mkdir -p /etc/xdg/lxqt && echo '[quicklaunch]\n\
alignment=Left\n\
apps\\1\desktop=/usr/share/applications/pcmanfm-qt.desktop\n\
apps\\2\desktop=/usr/share/applications/qterminal.desktop\n\
apps\\3\desktop=/usr/share/applications/firefox-esr.desktop\n\
apps\\4\desktop=/home/jmri/.local/share/applications/DecoderPro.desktop\n\
apps\\5\desktop=/home/jmri/.local/share/applications/PanelPro.desktop\n\
apps\size=5\n\
type=quicklaunch\n\
\n\
[fancymenu]\n\
alignment=Left\n\
favorites\\1\desktopFile=/home/jmri/.local/share/applications/DecoderPro.desktop\n\
favorites\\2\desktopFile=/home/jmri/.local/share/applications/PanelPro.desktop\n\
favorites\size=2\n\
ownIcon=true\n\
icon=/usr/share/lxqt/graphics/helix_60.png\n\
type=fancymenu\n\
' >> /etc/xdg/lxqt/panel.conf

# Install NOVNC.
RUN     git clone --branch v1.6.0 --single-branch https://github.com/novnc/noVNC.git /opt/noVNC; \
        git clone --branch v0.13.0 --single-branch https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify; \
        ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Give every user read write access to the "/root" folder where the binary is cached
RUN ls -la /root
RUN chmod 777 /root && mkdir /src
RUN groupadd -g $GROUP_ID jmri; \
    useradd -g $GROUP_ID -l -m -s /bin/bash -u $USER_ID jmri
RUN adduser jmri sudo;\
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN adduser jmri dialout

# Download and extract JMRI
RUN wget -nv $JMRI_DOWNLOAD_URL -O - | tar xz -C /opt && \
    chown -R jmri:jmri /opt/JMRI

#Add JMRI to Application Menu
RUN sed -i '/<!-- Accessories submenu -->/i \
\
        <!-- JMRI submenu -->\
        <Menu>\
                <Name>JMRI</Name>\
                <Include>\
                        <And>\
                                <Category>jmri</Category>\
                            </And>\
                </Include>\
        </Menu> <!-- End JMRI -->\
' /etc/xdg/menus/lxqt-applications.menu

#Set user
USER jmri
# Versions of local tools
RUN echo  "debian version:  $(cat /etc/debian_version) \n" \
          "user:            $(whoami) \n"

#Expose port 5901 to view display using VNC Viewer, 6901 for noVNC, 12080 for WebServer, 12090 for WiThrottle, 1234 for LoconetOverTCP, 2056 for JSON server, 4303 doe SRCP server and 2048 for simple server
EXPOSE $VNC_PORT $NO_VNC_PORT $WEBSERVER_PORT 12080 12090 1234 2056 4303 2048

#Copy default jmri configurations to /var/opt
COPY --chmod=755 --chown=jmri:jmri assets/ /var/opt
#Copy entrypoint.sh and set it as entrypoint
COPY --chmod=755 --chown=jmri:jmri scripts/entrypoint.sh /src/entrypoint.sh
ENTRYPOINT ["/src/entrypoint.sh"]
