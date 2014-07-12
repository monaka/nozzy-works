#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables -F INPUT
iptables -F FORWARD
iptables -F OUTPUT
iptables -F -t nat

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -m limit --limit 5/min -p tcp -j LOG --log-prefix '[Drop input]'
service netfilter-persistent save
service netfilter-persistent start
exit 0

