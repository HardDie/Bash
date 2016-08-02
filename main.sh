#!/bin/bash

clear;
echo "		Lab 7. Firewall";
echo;

if [[ !( $USER = root ) ]]; then
	echo "Permision denied, run as root";
	read;
	clear;
	exit 0;
fi

# Очищаем iptables, добавляем в разрешения loopback и уже созданные соединения
iptables -F;
iptables -A INPUT -i lo -j ACCEPT;
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT;

masConfig=(`cat config`);
len=`cat config | wc -l`;

for (( i = 0; i < len; i++ ))
do
	packageInstall=`dpkg -l | grep ${masConfig[$(($i * 2))]} | wc -l`;
	port=`echo ${masConfig[$(($i * 2 + 1))]} | egrep '^[0-9]{1,5}$'`;
	if [[ $packageInstall -ne 0 && -n $port ]]; then
		iptables -A INPUT -p tcp --dport $port -j ACCEPT;
		echo "Open $port port";
	fi
done

iptables -A INPUT -p tcp -j DROP;

read;
clear;
exit 0
