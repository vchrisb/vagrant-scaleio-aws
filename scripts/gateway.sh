#!/bin/bash
while [[ $# > 1 ]]
do
  key="$1"

  case $key in
    -p|--gwPassword)
    PASSWORD="$2"
    shift
    ;;
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

# install EPEL for pip
yum -y install epel-release
yum -y install java-1.7.0-openjdk git python-pip
GATEWAY_ADMIN_PASSWORD=${PASSWORD} rpm -Uv ${packagePath}/ScaleIO_*_Gateway_for_Linux_Download/ScaleIO_*_Gateway_for_Linux_Download/EMC-ScaleIO-gateway-*.rpm

#install required python modules
pip install requests
pip install requests-toolbelt

cd /home
#git clone https://github.com/swevm/scaleio-py.git
git clone -b v04-dev_installerfsm https://github.com/vchrisb/scaleio-py.git
cd scaleio-py
python setup.py install

#echo "Waiting 60 seconds for all nodes to become ready"
#sleep 60

if [[ -n $1 ]]; then
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 $1
fi
