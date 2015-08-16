#
# vagrant-scaleio-aws by Christopher Banck @vchrisb
#

# Require YAML module to load sensitive data
require 'yaml'

# sensitive data is stored in an extra file
aws = YAML.load_file('aws.yaml')

# scaleio admin password
password = "Scaleio123"
rootPassword = "dT59msmderay"

# add your domain here
domain = 'scaleio.local'

# at least 3 nodes (an extra node for the Gateway will be added)
# with more than ~10 nodes you need to switch to --non-parallel provisioning due to provider limitations
nodes = 3

# use "/dev/loop0" as dummy device
# use "/dev/xvd[b-z]" e.g. "/dev/xvdb" for any additional EBS or ephemeral devices
device = "/dev/loop0"
# free tier: "t2.micro"
gw_instance_type = "t2.micro"
# cheapest instance with local disk > 100GB = r3.2xlarge
instance_type = "t2.micro"
# if ephemeral storage is available for your instance type, add it by {'DeviceName' => '/dev/sdb','VirtualName' => 'ephemeral0'} and {'DeviceName' => '/dev/sdc','VirtualName' => 'ephemeral1'}
# for more EBS based storage add {'DeviceName' => device, 'Ebs.VolumeSize' => 100, 'Ebs.VolumeType' => 'gp2', 'Ebs.DeleteOnTermination' => 'true'}
block_device_mapping = []
region = "us-east-1"
access_key_id = aws["access_key_id"]
secret_access_key = aws["secret_access_key"]
# required ports from VPC network: 6611,9011,7072,443,9099
# required ports from external network: 22
# optional ports from external to connect to IM and MDM: 443,6611
security_groups = aws["security_groups"]
keypair_name = "vagrant-scaleio"
private_key_path = "vagrant-scaleio.pem"
subnet_id = aws["subnet_id"]
network = "172.31.0."
# if you have a VPN connection to your VDC, you can omnit assigning elastic ip addresses to the nodes
elastic_ip = true
firstip = 10

Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # node-1 to node-3 are used for MDM and TB
  mdm1IPaddress = "#{network}#{firstip + 1}"
  mdm2IPaddress = "#{network}#{firstip + 2}"
  tbIPaddress = "#{network}#{firstip + 3}"
  gwIPaddress = "#{network}#{firstip}"

  nodeIPaddresses = ""
  config.ssh.private_key_path = private_key_path
  config.ssh.username = "centos"

  ### nodes

  (1..nodes).each do |i|

    nodeIPaddress = "#{network}#{firstip + i}"
    config.vm.define "node-#{i}" do |node|
      node.vm.host_name = "node-#{i}"
      node.vm.provider :aws do |aws|
        aws.access_key_id = access_key_id
        aws.secret_access_key = secret_access_key
        aws.region = region
        aws.ami = "ami-96a818fe"
        aws.private_ip_address = nodeIPaddress
        aws.subnet_id = subnet_id
        aws.security_groups = security_groups
        aws.instance_type = instance_type
        aws.elastic_ip = elastic_ip
        aws.terminate_on_shutdown = true
        aws.block_device_mapping = [{'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 8, 'Ebs.VolumeType' => 'gp2', 'Ebs.DeleteOnTermination' => 'true' }].concat(block_device_mapping)
        aws.keypair_name = keypair_name
        # disable requiretty
        aws.user_data =  "#!/bin/bash\nsed -i -e '/requiretty/d' /etc/sudoers\n"
      end

      node.vm.provision "shell" do |s|
        s.path = "scripts/packages.sh"
        s.args   = "--rootPassword #{rootPassword} --nodeNetwork #{network}"
      end

      nodeIPaddresses += "#{nodeIPaddress} "
    end
  end

  #### gateway

  config.vm.define "gateway" do |node|

    node.vm.host_name = "gateway"
    node.vm.provider :aws do |aws|
      aws.access_key_id = access_key_id
      aws.secret_access_key = secret_access_key
      aws.region = region
      aws.ami = "ami-96a818fe"
      aws.private_ip_address = gwIPaddress
      aws.subnet_id = subnet_id
      aws.security_groups = security_groups
      aws.instance_type = gw_instance_type
      aws.elastic_ip = true
      aws.terminate_on_shutdown = true
      aws.block_device_mapping = [{'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 8, 'Ebs.VolumeType' => 'gp2', 'Ebs.DeleteOnTermination' => 'true' }]
      aws.keypair_name = keypair_name
      # disable requiretty
      aws.user_data =  "#!/bin/bash\nsed -i -e '/requiretty/d' /etc/sudoers\n"
    end

    node.vm.provision "download", type: "shell", path: "scripts/download.sh"
    node.vm.provision "shell" do |s|
      s.path = "scripts/gateway.sh"
      s.args   = "--gwPassword #{password}"
    end
    node.vm.provision "shell" do |s|
      s.path = "scripts/install.py"
      s.args   = "--nodeUsername root --nodePassword #{rootPassword} --mdmPassword #{password} --liaPassword #{password} --gwUsername admin --gwPassword #{password} --gwIPaddress #{gwIPaddress} --packagePath /tmp/ScaleIO/ScaleIO_1.32_RHEL7_Download/ --mdm1IPaddress #{mdm1IPaddress} --mdm2IPaddress #{mdm2IPaddress} --tbIPaddress #{tbIPaddress} --nodeIPaddresses #{nodeIPaddresses} --device #{device}"
    end
    node.vm.provision "shell" do |s|
      s.path = "scripts/config.py"
      s.args   = "--gwIPaddress #{gwIPaddress} --mdmUsername admin --mdmPassword #{password} --nodeIPaddresses #{nodeIPaddresses}"
    end
    node.vm.provision "shell" do |s|
      s.path = "scripts/info.py"
      s.args   = "--gwIPaddress #{gwIPaddress} --mdmUsername admin --mdmPassword #{password}"
    end
  end

end
