#!/bin/bash
while [[ $# > 1 ]]
do
  key="$1"

  case $key in
    -p|--rootPassword)
    PASSWORD="$2"
    shift
    ;;
    -n|--nodeNetwork)
    NETWORK="$2"
    shift
    ;;
    *)
    # unknown option
    ;;
  esac
  shift
done

case "$(uname -r)" in
  *el6*)
    sysctl -p kernel.shmmax=209715200
    yum install numactl libaio -y
    ;;
  *el7*)
    yum install numactl libaio -y
    ;;
esac

# allow RootLogin and PasswordAuthentication for VPC network
echo -e "\nMatch Address ${NETWORK}*" | sudo tee --append /etc/ssh/sshd_config
echo -e "    PasswordAuthentication yes" | sudo tee --append /etc/ssh/sshd_config
echo -e "    PermitRootLogin yes" | sudo tee --append /etc/ssh/sshd_config

systemctl restart sshd

# set root password - ScaleIO installation manager require root login
echo -e "${PASSWORD}\n${PASSWORD}" | (sudo passwd --stdin root)

# install fio
sudo yum -y install epel-release
sudo yum -y install fio

# create dummy file
truncate -s 100GB /home/scaleio1
# create device
losetup /dev/loop0 /home/scaleio1

if [[ -n $1 ]]; then
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 $1
fi
