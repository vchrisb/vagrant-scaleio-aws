#!/bin/bash
while [[ $# > 1 ]]
do
  key="$1"

  case $key in
    -p|--gwPassword)
    PASSWORD="$2"
    shift
    ;;
    *)
    # unknown option
    ;;
  esac
  shift
done

# install EPEL
yum -y install epel-release

cd /tmp/ScaleIO/ScaleIO_1.32_Gateway_for_Linux_Download
yum install java-1.7.0-openjdk git python-pip -y
GATEWAY_ADMIN_PASSWORD=${PASSWORD} rpm -Uv EMC-ScaleIO-gateway-*.rpm

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
