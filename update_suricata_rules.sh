#!/bin/bash

# Update rules
sudo docker exec -it --user suricata suricata suricata-update update-sources
sudo docker exec -it --user suricata suricata suricata-update -f
