#!/bin/bash

yum -y install wget unzip
cd /tmp
wget -N -nv ftp://ftp.emc.com/Downloads/ScaleIO/ScaleIO_RHEL6_Download.zip
unzip -o ScaleIO_RHEL6_Download.zip -d /tmp/ScaleIO/
