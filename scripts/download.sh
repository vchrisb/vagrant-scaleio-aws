#!/bin/bash
while [[ $# > 1 ]]
do
  key="$1"

  case $key in
    -f|--packagePath)
    packagePath="$2"
    shift
    ;;
    *)
    # unknown option
    ;;
  esac
  shift
done

yum -y install wget unzip
cd /tmp
wget -N -nv ftp://ftp.emc.com/Downloads/ScaleIO/ScaleIO_Linux_SW_Download.zip
unzip ScaleIO_Linux_SW_Download.zip -d ${packagePath}
