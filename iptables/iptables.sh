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
# GCM to google using chrome
iptables -A OUTPUT -p tcp --dport 5228:5230 --syn -j ACCEPT
# for usb0 ethernet for nook color
iptables -A OUTPUT -p udp --dport 67:68 -o usb0 -j ACCEPT
# for eth0 ethernet for eth0
iptables -A OUTPUT -p udp --dport 67:68 -o eth0 -j ACCEPT
# for gmail
iptables -A OUTPUT -p tcp --dport 993 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 465 --syn -j ACCEPT
iptables -A OUTPUT -p tcp --dport 587 --syn -j ACCEPT
# for armitage radio station in finland
iptables -A OUTPUT -p tcp --dst 198.27.80.17 --dport 8010 --syn -j ACCEPT
# for animaze radio station
iptables -A OUTPUT -p tcp --dst 72.233.93.160 --dport 10007 --syn -j ACCEPT
# for animNfo
iptables -A OUTPUT -p tcp --dst 69.60.255.236 --dport 8888 --syn -j ACCEPT
# for radio hbr1.com
iptables -A OUTPUT -p tcp --dst 93.94.83.52 --dport 19800 --syn -j ACCEPT
# for radio paradice
iptables -A OUTPUT -p tcp --dst 8.25.37.138 --dport 9000 --syn -j ACCEPT
# for radio GFM
iptables -A OUTPUT -p tcp --dst 195.138.247.90 --dport 8000 --syn -j ACCEPT
# for absolute transe EURO
iptables -A OUTPUT -p tcp --dst 205.164.62.15 --dport 7014 --syn -j ACCEPT
# for trance.fm
iptables -A OUTPUT -p tcp --dst 5.63.150.167 --dport 8002 --syn -j ACCEPT
# for irc
iptables -A OUTPUT -p tcp --dport 6667 --syn -j ACCEPT
# for git 
iptables -A OUTPUT -p tcp --dport 9418 --syn -j ACCEPT
# for pgp server
iptables -A OUTPUT -p tcp --dport 11371 --syn -j ACCEPT
# for gnome-shell?
iptables -A OUTPUT -p tcp --dst 192.168.0.1 --dport 4713 --syn -j ACCEPT
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
# for lan
iptables -A OUTPUT -p tcp -d 172.16.52.10/32 --dport 8000 -j ACCEPT
iptables -A INPUT  -s 10.22.117.33/32 -j ACCEPT
iptables -A OUTPUT -d 10.22.117.33/32 -j ACCEPT
## for ftp
iptables -A OUTPUT -p tcp --dport 21 -j ACCEPT
# vultr
iptables -A OUTPUT -p tcp --dport 42653 -j ACCEPT
# mosh to vultr
iptables -A OUTPUT -m state --state NEW -m udp -p udp --dport 60001:60010 -j ACCEPT
# iptables -A OUTPUT -p tcp -d cyanogen0001 --dport 12653 -j ACCEPT
# another service
iptables -A INPUT -m limit --limit 5/min -p tcp -j LOG --log-prefix '[Drop input]'
iptables -A INPUT -m limit --limit 5/min -p udp -j LOG --log-prefix '[Drop input]'
# sqex dhcp
iptables -A INPUT -p udp --dport 5353 --sport 5353 -i wlan0 -j ACCEPT
iptables -A OUTPUT -p udp --dport 5353 --sport 5353 -o wlan0 -j ACCEPT
# test for sip
iptables -A OUTPUT -p udp --dport 3478  -j ACCEPT
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
	iptables -A FORWARD -j LOG --log-prefix '[Drop forward]'
fi

service netfilter-persistent save
service netfilter-persistent start
exit 0
