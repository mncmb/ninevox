#!/bin/bash

#################################################################
#
#   Download Vagrant Win10Edge VM image (90 day trial) and 
#   add the box to Vagrant
#
#################################################################

FILENAME="vagrantwin10.zip"
VAGRANTIMG="windows/win10-edge"
UNZIPPED="MSEdge - Win10.box"

# download the box image file
python3 downloader.py $FILENAME

if [ $? -eq 0 ];
then
    # download successful
    echo "INFO:Extracting. This might take a bit..."
    unzip $FILENAME
    echo "INFO:Image extracted. Adding box to Vagrant"
    vagrant box add $VAGRANTIMG $UNZIPPED
else
    echo "Download failed. Wrong hashes"
fi