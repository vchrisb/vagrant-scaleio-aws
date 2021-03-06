vagrant-scaleio-aws
---------------

# Description

Vagrant script to deploy ScaleIO on AWS

# Configuration

### `Vagrantfile`

at least 3 nodes (an extra node for the Gateway will be added)  
with more than ~10 nodes you need to switch to `--non-parallel` provisioning due to provider limitations  
`nodes = 3` 

use "/dev/loop0" as dummy device  
use "/dev/xvd[b-z]" e.g. "/dev/xvdb" for any additional EBS or ephemeral devices  
`device = "/dev/loop0"`  
free tier: "t2.micro"  
`gw_instance_type = "t2.micro"`  
cheapest instance with local disk > 100GB = r3.2xlarge  
`instance_type = "t2.micro"`  
if ephemeral storage is available for your instance type, add it by {'DeviceName' => '/dev/sdb','VirtualName' => 'ephemeral0'} and {'DeviceName' => '/dev/sdc','VirtualName' => 'ephemeral1'}  
for more EBS based storage add {'DeviceName' => device, 'Ebs.VolumeSize' => 100, 'Ebs.VolumeType' => 'gp2', 'Ebs.DeleteOnTermination' => 'true'}  
`block_device_mapping = []`  
`region = "us-east-1"`    
required ports from VPC network: 6611,9011,7072,443,9099  
required ports from external network: 22  
optional ports from external to connect to IM and MDM: 443,6611  
`keypair_name = "vagrant-scaleio"`  
`private_key_path = "vagrant-scaleio.pem"`  
`network = "172.31.0."`  
if you have a VPN connection to your VDC, you should be able to omnit assigning elastic ip addresses to each node (the gateway will always get one)  
`elastic_ip = true`  

### `aws.yaml`

```
---
access_key_id: "ABCDERFGHIJKLMNOPQRS"
secret_access_key: "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcd"
subnet_id: "subnet-12345678"
security_groups:
 - "sg-12345678"
 - "sg-12345678"
 ```


# Usage

This Vagrant setup will automatically deploy a configurable number of CentOS 7 nodes, download the ScaleIO software and install a full ScaleIO cluster.

To use this, you'll need to complete a few steps:

1. `git clone https://github.com/vchrisb/vagrant-scaleio-aws.git`
2. Modify `Vagrantfile` and `aws.yaml`
3. `vagrant up --provider=aws`
4. each node has `fio` installed and a 8GB device attached  
Performance testing can be done on each node with e.g.:  
`sudo fio --filename=/dev/scinia --direct=1 --rw=randrw --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=8k --rwmixread=70 --iodepth=16 --runtime=120 --group_reporting --name=8krandom70r30w`
5. connect to the ScaleIO installtion manger `https://public-gateway-ip` and/or to the MDM using a local ScaleIO GUI  
`vagrant ssh-config gateway` and `vagrant ssh-config node-1` can be used to get the public IP adresses

# Troubleshoot

If you are facing a deployment error in the ScaleIO Installation phase, connect to the installtion manger `https://public-gateway-ip` and look at the `Monitor` tab. 
