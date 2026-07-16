#!/bin/bash
echo "Start script"
mkdir -p /home/jmri/Desktop/
cp -n /var/opt/Desktop-default/* /home/jmri/Desktop/
mkdir -p /home/jmri/.local/share/applications/
cp -n /var/opt/Desktop-default/DecoderPro.desktop /home/jmri/.local/share/applications/DecoderPro.desktop
cp -n /var/opt/Desktop-default/PanelPro.desktop /home/jmri/.local/share/applications/PanelPro.desktop
mkdir -p /home/jmri/.jmri/
cp -r -n /var/opt/jmri-default/* /home/jmri/.jmri/

chown -R jmri:jmri /home/jmri
chmod -R 777 /home/jmri

# Give RW access to USB devices passed through
sudo chmod a+rw /dev/ttyUSB* 

# set -e: exit asap if a command exits with a non-zero status

set -e
trap ctrl_c INT
function ctrl_c() {
  exit 0
}
# entrypoint.sh file for starting the xvfb with better screen resolution, configuring and running the vnc server.
rm /tmp/.X1-lock 2> /dev/null &
/opt/noVNC/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &
# Insecure option is needed to accept connections from the docker host.
vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION -SecurityTypes None -localhost no --I-KNOW-THIS-IS-INSECURE &
wait
