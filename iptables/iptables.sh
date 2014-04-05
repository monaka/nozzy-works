#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

iptables -F INPUT
iptables -F FORWARD
iptables -F OUTPUT
iptables -F -t nat

# iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags FIN,SYN FIN -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags SYN,RST RST -j ACCEPT
# iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp --tcp-flags FIN,SYN FIN -j ACCEPT
iptables -A OUTPUT -p tcp --tcp-flags SYN,RST RST -j ACCEPT
iptables -A INPUT -i lo -s 0/0 -d 0/0 -j ACCEPT
iptables -A OUTPUT -o lo -s 0/0 -d 0/0 -j ACCEPT
iptables -A INPUT -i br0 -s 0/0 -d 0/0 -j ACCEPT
iptables -A OUTPUT -o br0 -s 0/0 -d 0/0 -j ACCEPT
iptables -A INPUT -i usb0 -s 0/0 -d 0/0 -j ACCEPT
iptables -A OUTPUT -o usb0 -s 0/0 -d 0/0 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type any -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type any -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 --syn -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 --syn -j ACCEPT
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 123 --syn -j ACCEPT
# for usb0 ethernet for nook color
iptables -A OUTPUT -p udp --dport 67:68 -o usb0 -j ACCEPT
# for eth0 ethernet for eth0
iptables -A OUTPUT -p udp --dport 67:68 -o eth0 -j ACCEPT
# for gmail
iptables -A OUTPUT -p tcp --dport 993 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 465 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 587 --syn -j ACCEPT
# for armitage radio station in finland
iptables -A OUTPUT -p tcp --dst 143.51.142.148 --dport 8040 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dst 71.178.19.18 --dport 8010 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dst 216.59.35.34 --dport 8004 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dst 91.121.66.35 --dport 8004 --syn -j ACCEPT
# for animaze radio station
iptables -A OUTPUT -p tcp --dst 72.233.93.160 --dport 10007 --syn -j ACCEPT
# Netraji
iptables -A OUTPUT -p tcp --dst 124.35.63.34 --dport 8000 --syn -j ACCEPT
# hbr1.com
iptables -A OUTPUT -p tcp --dst 217.64.173.228 --dport 19800 --syn -j ACCEPT
# wknc 88.1 FM
iptables -A OUTPUT -p tcp --dst 152.1.91.207 --dport 8000 --syn -j ACCEPT
# for animNfo
iptables -A OUTPUT -p tcp --dst 69.60.255.236 --dport 8888 --syn -j ACCEPT
# for irc
iptables -A OUTPUT -p tcp --dport 6667 --syn -j ACCEPT
# for git 
iptables -A OUTPUT -p tcp --dport 9418 --syn -j ACCEPT
# for pgp server
iptables -A OUTPUT -p tcp --dport 11371 --syn -j ACCEPT
# for gobby
iptables -A OUTPUT -p tcp --dport 6522 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 6523 --syn -j ACCEPT
# for gnome-shell?
iptables -A OUTPUT -p tcp --dst 192.168.0.1 --dport 4713 --syn -j ACCEPT
# for gnome-dictionary
iptables -A OUTPUT -p tcp --dport 2628 --syn -j ACCEPT
# for Leek-Radio
iptables -A OUTPUT -p tcp --dport 12000 --syn -j ACCEPT
# for crystal conquest
iptables -A OUTPUT -p tcp --dport 6800 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 843 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 6501 --syn -j ACCEPT
# niconico
iptables -A OUTPUT -p tcp --dport 2525:2528 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 2800:2900 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 1935 --syn -j ACCEPT
# hibiki
iptables -A OUTPUT -p tcp --dport 10102 --syn -j ACCEPT
iptables -A OUTPUT -p udp --dst 125.64.229.144 -j ACCEPT
iptables -A INPUT -p udp --src 125.64.229.144 -j ACCEPT
# downloder
iptables -A OUTPUT -p tcp --dport 182 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 8080 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 8001 --syn -j ACCEPT
# bravely default
iptables -A OUTPUT -p tcp --dport 9290:9300 --syn -j ACCEPT
# for nook color vnc
iptables -A OUTPUT -p tcp --dport 5901 --syn -o usb0 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 123 -j ACCEPT
# for usb0 ethernet for nook color
iptables -A INPUT -p udp --dport 67:68 -i usb0 -j ACCEPT
# for eth0 ethernet for nook color
iptables -A INPUT -p udp --dport 67:68 -i eth0 -j ACCEPT
# for skype
iptables -A OUTPUT -p udp --dport 1900 -j ACCEPT
# for whois
iptables -A OUTPUT -p tcp --dport 43 -j ACCEPT
# for hange
iptables -A OUTPUT -p tcp --dport 10080 -j ACCEPT
# for sqex
iptables -A INPUT --src 10.22.95.25 -j ACCEPT
iptables -A INPUT --src 10.22.95.24 -j ACCEPT
iptables -A OUTPUT --dest 10.22.95.25 -j ACCEPT
iptables -A OUTPUT --src 10.22.95.24 -j ACCEPT
# for vivain shinjuku
iptables -A OUTPUT -p tcp --dest 192.168.0.0/16 --dport 1111 -j ACCEPT
# another service
iptables -A INPUT -m limit --limit 5/min -p tcp -j LOG --log-prefix '[Drop input]'
iptables -A INPUT -m limit --limit 5/min -p udp -j LOG --log-prefix '[Drop input]'
# sqex dhcp
iptables -A INPUT -p udp --dport 5353 --sport 5353 -i wlan0 -j ACCEPT
iptables -A OUTPUT -p udp --dport 5353 --sport 5353 -o wlan0 -j ACCEPT
# test for sip
iptables -A OUTPUT -p udp --dport 3478  -j ACCEPT
# test for animetop
iptables -A OUTPUT -p tcp --dport 8716  -j ACCEPT

iptables -A OUTPUT -p tcp -j LOG --log-prefix '[Drop output]'
iptables -A OUTPUT -p udp -j LOG --log-prefix '[Drop output]'
iptables -A INPUT -p tcp -j DROP 
iptables -A INPUT -p udp -j DROP 
iptables -A OUTPUT -p tcp -j DROP
iptables -A OUTPUT -p udp -j DROP

ppp_enable=`/sbin/ip addr show ppp0 | fgrep ,UP`

if [ "X${ppp_enable}X" != "XX" ]; then
	iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
	iptables -A FORWARD -i br0 -o ppp0 -j ACCEPT
	iptables -A FORWARD -i ppp0 -o br0 -j ACCEPT
fi

/etc/init.d/iptables-persistent save
/etc/init.d/iptables-persistent start
exit 0
