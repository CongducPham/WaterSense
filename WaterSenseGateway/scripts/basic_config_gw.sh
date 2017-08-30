#!/bin/bash

#------------------------------------------------------------
# Copyright 2016-2017 Congduc Pham, University of Pau, France.
# 
# Congduc.Pham@univ-pau.fr
#
# This file is part of the low-cost LoRa gateway developped at University of Pau
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with the program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------

#
# example: ./basic_config_gw.sh

board=`cat /proc/cpuinfo | grep "Revision" | cut -d ':' -f 2 | tr -d " \t\n\r"`

#get the last 5 bytes of the eth0 MAC addr
gwid=`ifconfig | grep 'eth0' | awk '{print $NF}' | sed 's/://g' | awk '{ print toupper($1) }' | cut -c 3-`

#get the last 5 bytes of the wlan0 MAC addr
if [ "$gwid" = "" ]
	then
		gwid=`ifconfig | grep 'wlan0' | awk '{print $NF}' | sed 's/://g' | awk '{ print toupper($1) }' | cut -c 3-`
fi

#set a default value
if [ "$gwid" = "" ]
	then
		gwid="XXXXXXDEF0"
fi

echo "Creating /home/pi/lora_gateway/gateway_id.txt file"
echo "Writing 000000$gwid"
echo "000000$gwid" > /home/pi/lora_gateway/gateway_id.txt
echo "Done"

echo "Replacing gw id in /home/pi/lora_gateway/gateway_conf.json"
sed -i -- 's/"000000.*"/"000000'"$gwid"'"/g' /home/pi/lora_gateway/gateway_conf.json
echo "Done"

echo "Creating /home/pi/Dropbox/LoRa-test"
mkdir -p /home/pi/Dropbox/LoRa-test
echo "Done"

rm /home/pi/lora_gateway/log
echo "Creating log -> /home/pi/Dropbox/LoRa-test"
ln -s /home/pi/Dropbox/LoRa-test /home/pi/lora_gateway/log
echo "Done"	

echo "Replacing hot-spot ssid in /etc/hostapd/hostapd.conf"
sudo sed -i 's/^ssid.*/ssid=WS_PI_GW_'"$gwid"'/g' /etc/hostapd/hostapd.conf
echo "Done"
echo "Gateway WiFi ssid is WS_PI_GW_$gwid"
		
echo "Setting wpa_passphrase in /etc/hostapd/hostapd.conf"
sudo sed -i 's/^wpa_passphrase.*/wpa_passphrase=loragateway/g' /etc/hostapd/hostapd.conf
echo "Done"
echo "Gateway WiFi wpa_passphrase is loragateway"		

echo "Setting gateway to run at boot"
# we always remove so that there will be no duplicate lines
echo "Removing /home/pi/lora_gateway/scripts/start_gw.sh in /etc/rc.local if any"
sudo sed -i 's/\/home\/pi\/lora_gateway\/scripts\/start_gw.sh//g' /etc/rc.local
echo "Done"

echo "Add /home/pi/lora_gateway/scripts/start_gw.sh in /etc/rc.local"
sudo sed -i 's/^exit 0/\/home\/pi\/lora_gateway\/scripts\/start_gw.sh\nexit 0/g' /etc/rc.local
echo "Done"

echo "Compile lora_gateway executable"

pushd /home/pi/lora_gateway/

if [ "$board" = "a01041" ] || [ "$board" = "a21041" ] || [ "$board" = "a22042" ]
	then
		echo "You have a Raspberry 2"
		echo "Compiling for Raspberry 2 and 3"
		make lora_gateway_pi2
elif [ "$board" = "a02082" ] || [ "$board" = "a22082" ]
	then
		echo "You have a Raspberry 3"
		echo "Compiling for Raspberry 2 and 3"
		make lora_gateway_pi2
elif [ "$board" = "900092" ] || [ "$board" = "900093" ] || [ "$board" = "9000C1" ]
	then
		echo "You have a Raspberry Zero"
		echo "Compiling for Raspberry 1"
		make lora_gateway
else
	echo "You have a Raspberry 1"		
	echo "Compiling for Raspberry 1"
	make lora_gateway
fi
		
popd

echo "You should reboot your Raspberry"
echo "Bye."
