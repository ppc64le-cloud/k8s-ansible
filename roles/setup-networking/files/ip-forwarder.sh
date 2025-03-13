#!/bin/bash -x

set -x

PRIVATE_INT=$1
PUBLIC_INT=$2

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A FORWARD -i $PRIVATE_INT -o $PUBLIC_INT -j ACCEPT
iptables -A FORWARD -i $PUBLIC_INT -o $PRIVATE_INT -m state --state ESTABLISHED,RELATED \
         -j ACCEPT
iptables -t nat -A POSTROUTING -o $PUBLIC_INT -j MASQUERADE

iptables -A FORWARD -i $PRIVATE_INT -j ACCEPT
iptables -A FORWARD -o $PRIVATE_INT -j ACCEPT

ethtool --offload $PRIVATE_INT rx off tx off
ethtool --offload $PUBLIC_INT rx off tx off
ethtool -K $PUBLIC_INT tso off
ethtool -K $PRIVATE_INT tso off
ethtool -K $PRIVATE_INT gso off
