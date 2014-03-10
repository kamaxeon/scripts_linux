#!/bin/bash
set -x
#FLIP1405 - Failover Server Solution
#RUN ON PRIMARY ASTERISK SERVER
#ORIGINAL AUTHOR GREGG HANSEN 20080208 &lt;hansen.gregg@gmail.com&gt;
#MODIFIED BY GREGORY BOEHNLEIN 20090201 &lt;damin@nacs.net&gt;
#DEPENDENCIES: nmap, arping

# Version 1.0 - 2009-03-25
# - Consolidated Master/Slave scripts into a single script
# - Converted hardcoded interface / IP configuration to variable based
# - Forced Asterisk to issue a "reload" to bind to the floating IP
# - Consolidated external rsync-replicate script to be self-contained

# If set to "1" this is the Master server.
# If commented out, or set to anything else, this will act as if it is a slave
MASTER="1"

# The  Master and Slave IP Addresses for HeartBeat
HBMASTERIP="192.168.229.1"
HBSLAVEIP="192.168.229.2"

# The HeartBeat IP address that will float between Master and Slave
HBFLOATIP="192.168.229.3"

# The HeartBeat NetMask
HBMASK="24"

# The HeartBeat interface
HBDEVICE="bond0"

# Interfaces and IP for the cluster
# Use this format "interface:ip:netmask"
# HeartBeat IP and interfaces are includes automatically
# Example for eth0, eth1 and eth2
# INTANDIP="eth0:192.168.220.3:24 eth1:10.50.0.15:16 eth2:192.168.222.3:24"
INTANDIP="eth0:192.168.220.3:24 eth1:10.50.0.15:16 eth2:192.168.222.3:24"

# Port to check Asterisk Status
PORT_CHECK="4569"

# Services 
SERVICES="amportal dhcpd ntpd httpd"


# Directories to sync
DIRS="balala dfdsfasfd"

# Files to sync
FILES="fddsf dflafj"

# Don't change anything from here !!!!!!!!!!!!!!1




# The localhost IP
LOCALHOST="127.0.0.1"


# Change Interfaces
# $1 add or del
function changeInterfaces() {
	ACTION=$1

	# HeartBeat Interface
	addVirtualIPs ${ACTION} ${HBFLOATIP} ${HBMASK} ${HBDEVICE}

	# Rest of interfaces
	for zone in $INTANDIP
	do
		# Getting the values
		TEMPDEVICE=$(echo ${zone} | awk -F ":" '{print $1}')
		TEMPIP=$(echo ${zone} | awk -F ":" '{print $2}')
		TEMPMASK=$(echo ${zone} | awk -F ":" '{print $3}')

		# Configuring the interface
		addVirtualIPs ${ACTION} ${TEMPIP} ${TEMPMASK} ${TEMPDEVICE}

	done

}


# Change Services
# $1 stop, start, restart
function changeServices(){

}


# Check Asterisk Port
# $1 IP of the check
function checkAsteriskPort(){
	RESULT=$(nmap --system-dns -p ${PORT_CHECK} -sU ${1} | awk '{print $2}' | grep open)
	echo $RESULT
}

# Add virtual IP to interfaces
# S1 operation (add or del)
# $2 ip
# $3 netmask
# $4 interface
function addVirtualIPs(){
	/sbin/ip address $1 $2/$3 dev $4
}

# Do an Arp ping
# $1 Device
# $2 FLOATIP
function addArpPing(){
	/sbin/arping -U -c 5 -I $DEVICE $FLOATIP
}

# Activate Asterisk Node
function activateNode(){

}

# Desactivate Asterisk Node
function desactivateNode {

}


MASTERASTERISKSTATUS=$(checkAsteriskPort $HBMASTERIP)
NODEASTERISKSTATUS=$(checkAsteriskPort $LOCALHOST)

#if virtual HeartBeat is not pingable = 'down.'
VIRTUALIPSTATE=$(nmap --system-dns -sP "$HBFLOATIP" | grep down | awk '{print $4}')


#if local node owns HertBeat Virtual IP 
NODEVIRTUALIP=$(/sbin/ip add show "$IFACE" | grep "$HBFLOATIP"/"$HBMASK" | awk '{print $2}' | awk -F "/" '{print $1}')

exit 0
if [ "$MASTER" == "1" ] ; then
	# Configuration File Replication from Master to Slave
	rsync -avzr --rsh=ssh /etc/asterisk/ root@$HBSLAVEIP:/etc/asterisk/
	rsync -avzr --rsh=ssh /var/spool/asterisk/voicemail root@$HBSLAVEIP:/var/spool/asterisk
	rsync -avzr --rsh=ssh /var/lib/asterisk/moh root@$HBSLAVEIP:/var/lib/asterisk
	rsync -avzr --rsh=ssh /var/lib/asterisk/sounds root@$HBSLAVEIP:/var/lib/asterisk
	rsync -avzr --rsh=ssh /var/www/html root@$HBSLAVEIP:/var/www
	rsync -avzr --rsh=ssh /var/www/db root@$HBSLAVEIP:/var/www
	rsync -avzr --rsh=ssh /tftpboot root@$HBSLAVEIP:/
	#rsync -avzr --rsh=ssh /usr/src root@$HBSLAVEIP:/usr/src

	#/root/rsync_replicate > /dev/null 2> /dev/null
	if [ "$NODEASTERISKSTATUS" == "open|filtered" ] ; then  ###is primary asterisk up?
		if [ "$NODEVIRTUALIP" != "$HBFLOATIP" ] ; then  ###does primary not own virtual ip?
			if [ "$VIRTUALIPSTATE" == "down." ] ; then  ###is the virtual IP not pingable?

				# Starting up the virtual IP's
				addVirtualIPs "add" ${HBMASTERIP} ${HBMASK} ${DEVICE}

				# Executing for every interfaces 
				addArpPing $DEVICE $FLOATIP  ###Gratuitous ARP request
				/sbin/service asterisk restart
				/sbin/service httpd restart
				/sbin/service ntpd restart

			fi
		fi
	else
		/sbin/service asterisk start
		/sbin/service httpd restart
		/sbin/service ntpd restart
		/sbin/ifconfig $IFACE down
	fi
else # We must be running as Slave node
	if [ "$MASTERASTERISKSTATUS" != "open|filtered" ] ; then   ###is primary asterisk down?
		if [ "$NODEASTERISKSTATUS" == "open|filtered" ] ; then     ###is secondary asterisk up?
			if [ "$NODEVIRTUALIP" != "$HBFLOATIP" ] ; then   ###does secondary not own virtual ip?
				if [ "$VIRTUALIPSTATE" == "down." ] ; then  ###is the virtual IP not pingable?
					/sbin/ifconfig $IFACE $FLOATIP/24 up
					/sbin/arping -U -c 5 -I $DEVICE $FLOATIP   ###Gratuitous ARP request
					/sbin/service asterisk restart
					/sbin/service httpd restart
					/sbinservice ntpd restart
				fi
			fi
		else
			/sbin/service asterisk start
			/sbin/service httpd restart
			/sbin/service ntpd restart
		fi
	else
		if [ "$SECSTATUS" == "open|filtered" ] ; then ###primary is up, is secondary up? (there can be only one!)
			/sbin/service asterisk stop
		else
			echo
			if [ "$NODEVIRTUALIP" == "$FLOATIP" ] ; then
				# If the Primary is up but we still own the Virtual IP, shut it down
				/sbin/ifconfig $IFACE down
			fi
		fi
	fi
fi