#!/bin/bash

if [[ $# -eq 1 ]]; then
	#====================
	# Start
	#
	#	Запуск монтирования
	#====================
	if [[ $1 = "start" ]];then
		temp=`df -h | grep "^192.168.1.2:/home/shared.*/media/server" | wc -l`;
		if [[ $temp -eq 0 ]]; then
			sudo mount 192.168.1.2:/home/shared /media/server;
		fi

		temp=`df -h | grep "^192.168.1.2:/home/shared.*/media/server" | wc -l`;
		if [[ $temp -eq 0 ]]; then
			echo "Error mount /home/shared in /media/server" >> /home/harddie/error_mount.log;
			exit;
		fi

		cd /media/server;
		log="main.sh.log";
		ip=`ifconfig eth0 | grep "inet addr:" | awk '{ print $2 }' | awk -F: '{ print $2 }'`;

		echo >> $log;
		echo "[START]" >> $log;
		echo "Name: `whoami`" >> $log;
		echo "IP: $ip" >> $log;
		echo "Start: `date -R`" >> $log;
		echo >> $log;

	#====================
	# Stop
	#
	#	Остановка монтирования
	#====================
	elif [[ $1 = "stop" ]]; then
		temp=`df -h | grep "^192.168.1.2:/home/shared.*/media/server" | wc -l`;
		if [[ $temp -ne 0 ]]; then
			cd /media/server;
			log="main.sh.log";
			ip=`ifconfig eth0 | grep "inet addr:" | awk '{ print $2 }' | awk -F: '{ print $2 }'`;
			echo >> $log;
			echo "[STOP]" >> $log;
			echo "Name: `whoami`" >> $log;
			echo "IP: $ip" >> $log;
			echo "Stop: `date -R`" >> $log;
			echo "Uptime: `uptime -p`" >> $log;
			echo >> $log;
			#sleep 2;
			sudo umount -l /media/server;
		fi
	fi
else
	echo "Usage $0 [start, stop]";
fi


exit 0
