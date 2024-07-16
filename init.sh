#!/bin/bash

# Update and install the necessary packages
sudo apt update
sudo apt install -y inotify-tools sed curl

# Declaring variables
CONFIG_MAIN="suricata.yaml"
CONFIG_VARS="suricata_vars.yaml"
CONFIG_LOGS="suricata_logs.yaml"

# We get the IP address of the server and the network interface
INTERFACE=$(ip route | grep default | awk '{print $5}')
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Updating the Suricata configuration file 
sed -i "s/change_to_your_ip_address/$IP_ADDRESS/" $CONFIG_MAIN

# Creating configuration directory
sudo mkdir -p logs etc run

# Moving the configuration files to a folder
sudo mv ../$CONFIG_MAIN etc/
sudo mv ../$CONFIG_LOGS etc/
sudo mv ../$CONFIG_VARS etc/

# Determine absolute paths for directories
LOGS_DIR=$(realpath logs)
ETC_DIR=$(realpath etc)
RUN_DIR=$(realpath run)
SURICATA_SCRIPT=$(realpath update_suricata.sh)
SURICATA_RULES_SCRIPT=$(realpath update_suricata_rules.sh)
MONITOR_SCRIPT=$(realpath monitor.sh)

# Puling Suricata image
sudo docker pull jasonish/suricata:latest

# Run Suricata
sudo docker run --rm -d --net=host --name suricata --cap-add=net_admin --cap-add=net_raw --cap-add=sys_nice \
  -v $LOGS_DIR:/var/log/suricata \
  -v $ETC_DIR:/etc/suricata \
  -v $RUN_DIR:/var/run \
  jasonish/suricata:latest -i $INTERFACE

#Update rules
sudo docker exec -it --user suricata suricata suricata-update update-sources
sudo docker exec -it --user suricata suricata suricata-update -f

# Grant execution rights to all scripts in the working directory
sudo find . -type f -name "*.sh" -exec chmod +x {} \;

# Addins a task to update Suricata
(sudo crontab -l 2>/dev/null; echo "0 3 1 * * $SURICATA_SCRIPT $LOGS_DIR $ETC_DIR $RUN_DIR") | crontab -

# Adding a task to update Suricata rules
(sudo crontab -l 2>/dev/null; echo "0 3 * * 1 $SURICATA_RULES_SCRIPT") | crontab -

# Running the log monitoring script
sudo nohup $MONITOR_SCRIPT $LOGS_DIR &
