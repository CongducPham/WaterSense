#!/bin/sh

echo "updating gateway"
cd /home/pi/

echo "removing any existing WaterSenseGateway folder (from previous update)"
rm -rf WaterSenseGateway

if [ -d local_gw_full_latest ]
then
	echo "Installing from local_gw_full_latest folder"
	mv local_gw_full_latest WaterSenseGateway
else
	wget -q --spider http://google.com

	if [ $? -eq 0 ]
		then
			#online
			echo "getting new WaterSenseGateway from github"
			svn checkout https://github.com/CongducPham/WaterSense/trunk/WaterSenseGateway
		else
			echo "No Internet connection, exiting"
			exit
	fi			
fi

if [ ! -d WaterSenseGateway ]
then
	echo "Failed to find a valid WaterSenseGateway folder for installation, exiting"
	exit
fi

if [ -d lora_gateway ]
	then
		echo "detecting an existing lora_gateway folder"
		cd WaterSenseGateway
		echo "preserving your key files"
		rm key_*
		echo "preserving your configuration files"
		rm gateway_conf.json clouds.json radio.makefile
		echo "copying new distrib into /home/pi/lora_gateway"
		cp --preserve -r * /home/pi/lora_gateway
	else
		echo "new installation"
		echo "simply renaming WaterSenseGateway in lora_gateway"
		mv WaterSenseGateway lora_gateway	
fi
	
cd /home/pi/lora_gateway

echo "compiling the gateway program"

board=`cat /proc/cpuinfo | grep "Revision" | cut -d ':' -f 2 | tr -d " \t\n\r"`

downlink=`jq ".gateway_conf.downlink" gateway_conf.json`
 
if [ "$downlink" != "0" ]
then
	echo "Detecting downlink timer, will compile with downlink support"
fi	
		
if [ "$board" = "a01041" ] || [ "$board" = "a21041" ] || [ "$board" = "a22042" ]
	then
		echo "You have a Raspberry 2"
		echo "Compiling for Raspberry 2 and 3"
		if [ "$downlink" = "0" ]
			then 
				make lora_gateway_pi2
			else
				make lora_gateway_pi2_downlink 
		fi		
elif [ "$board" = "a02082" ] || [ "$board" = "a22082" ]
	then
		echo "You have a Raspberry 3"
		echo "Compiling for Raspberry 2 and 3"
		if [ "$downlink" = "0" ]
			then 
				make lora_gateway_pi2
			else
				make lora_gateway_pi2_downlink 
		fi	
elif [ "$board" = "900092" ] || [ "$board" = "900093" ]
	then
		echo "You have a Raspberry Zero"
		echo "Compiling for Raspberry Zero (same as Raspberry 1)"
		if [ "$downlink" = "0" ]
			then 
				make lora_gateway
			else
				make lora_gateway_downlink 
		fi	
elif [ "$board" = "9000c1" ]
	then
		echo "You have a Raspberry Zero W"
		echo "Compiling for Raspberry Zero W (same as Raspberry 1)"
		if [ "$downlink" = "0" ]
			then 
				make lora_gateway
			else
				make lora_gateway_downlink 
		fi	
else
	echo "You have a Raspberry 1"		
	echo "Compiling for Raspberry 1"
	if [ "$downlink" = "0" ]
		then 
			make lora_gateway
		else
			make lora_gateway_downlink 
	fi	
fi

echo "update of gateway done."
sudo chown -R pi:pi /home/pi/lora_gateway/
echo "if it is a new installation, go into lora_gateway/scripts folder"
echo "and run ./basic_config_gw.sh"
