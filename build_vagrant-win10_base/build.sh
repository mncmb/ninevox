#!/bin/bash

FILENAME="vagrantwin10.zip"
VAGRANTIMG="windows/win10-edge"
UNZIPPED="MSEdge - Win10.box"
python3 downloader.py $FILENAME
if [ $? -eq 0 ];
then
    # download successful
    echo "INFO:Extracting. This might take a bit..."
    unzip $FILENAME
    echo "INFO:Image extracted. Adding box to Vagrant"
    vagrant box add $VAGRANTIMG $UNZIPPED
else
    echo else case
fi