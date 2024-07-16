#!/bin/bash

#Update Suricata
LOGS_DIR=$1
ETC_DIR=$2
RUN_DIR=$3
NTERFACE=$(ip route | grep default | awk '{print $5}')

sudo docker stop suricata
sudo docker pull jasonish/suricata:latest

sudo docker run --rm -d --net=host --name suricata --cap-add=net_admin --cap-add=net_raw --cap-add=sys_nice \
  -v $LOGS_DIR:/logs:/var/log/suricata \
  -v $ETC_DIR:/etc/suricata \
  -v $RUN_DIR:/var/run \
  jasonish/suricata:latest -i $INTERFACE
