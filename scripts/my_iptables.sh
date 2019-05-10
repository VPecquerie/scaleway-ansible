#!/bin/bash

iptables -P INPUT ACCEPT
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD

iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -A INPUT -i lo -j ACCEPT

# Scaleway NBD ==> Allow to mount network drives.
if [ -f /usr/local/bin/oc-metadata ]; 
then
    nbdip=$(/usr/local/bin/oc-metadata | grep VOLUMES_0_EXPORT_URI=nbd:// | sed "s/VOLUMES_0_EXPORT_URI=nbd:\/\///" | awk -F ":" '{ print $1 }')
    iptables -A INPUT -i eth0 -s $nbdip -j ACCEPT
fi 

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Prevent iptables DNS Amplication attack
iptables -A INPUT -p udp --dport 53 -m string --from 40 --algo bm --hex-string '|0000FF0001|' -m recent --set --name dnsanyquery 
iptables -A INPUT -p udp --dport 53 -m string --from 40 --algo bm --hex-string '|0000FF0001|' -m recent --name dnsanyquery --rcheck --seconds 60 --hitcount 3 -j DROP
iptables -A INPUT -p tcp --dport 53 -m string --from 52 --algo bm --hex-string '|0000FF0001|' -m recent --set --name dnsanyquery 
iptables -A INPUT -p tcp --dport 53 -m string --from 52 --algo bm --hex-string '|0000FF0001|' -m recent --name dnsanyquery --rcheck --seconds 60 --hitcount 3 -j DRO
# ---------------------------------------

#--- règles perso ici ----
iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
#-------------------------------

iptables -P INPUT DROP
