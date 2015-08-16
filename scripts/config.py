#!/usr/bin/env python

from scaleiopy import scaleio
from pprint import pprint
import time
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--mdmUsername", metavar='USERNAME', required=True, help="Username for ScaleIO GW")
parser.add_argument("--mdmPassword", metavar='PASSWORD', required=True, help="Password for ScaleIO GW")
parser.add_argument("--gwIPaddress", metavar='IP', required=True, help="IP address for ScaleIO GW")
parser.add_argument("--nodeIPaddresses", metavar='IP', nargs='+', required=True, help="IP addresses for ScaleIO nodes")

args = parser.parse_args()

sio = scaleio.ScaleIO("https://" + args.gwIPaddress + "/api",args.mdmUsername, args.mdmPassword, False, "ERROR") # HTTPS must be used as there seem to be an issue with 302 responses in Requests when using POST

i = 1
for node_ip in args.nodeIPaddresses:
    sio.create_volume('testvol00' + str(i), 8192, sio.get_pd_by_name('default'), sio.get_storage_pool_by_name('default'),thinProvision=False)
    sio.map_volume_to_sdc(sio.get_volume_by_name('testvol00' + str(i)), sio.get_sdc_by_ip(node_ip))
    i += 1
