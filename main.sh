#!/bin/bash

ip="None";
mask="None";

Input() {
	temp=-1;
	while [[ $temp -eq -1 ]]; do
		read temp;
		case "$temp" in
			[0-9] | [0-9][0-9])
				if [[ $temp -lt $1 || $temp -gt $2 ]]; then
					echo -n "Wrong input, try again: ";
					temp=-1;
				fi;;
			*)
				echo -n "Wrong input, try again: ";
				temp=-1;;
		esac
	done
	return "$temp";
}

Menu() {
	clear;
	echo "		Lab 9. IP Calculator";
	echo;
	echo "IP   : $ip";
	echo "Mask : $mask";
	echo;
	echo "1. Set ip";
	echo "2. Set mask";
	echo "3. Calculate";
	echo "4. Exit";
	echo;
	echo -n "Choose point menu: ";
	Input 1 4;
	return $?;
}

SetIp() {
	clear;
	echo "Set IP";
	echo;
	echo -n "Enter IP: ";
	read ip;
	CheckIp $ip;
	if [[ $? -ne 0 ]]; then
		echo "Wrong ip address";
		ip="None";
		read;
	fi
}

CheckIp() {
		# Проверка на верный формат строки
	temp=`echo $1 | egrep '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$'`;
	if [[ -z $temp ]]; then
		return 1;
	fi

		# Проверка первого значения
	temp=`echo $1 | awk -F'\.' '{ print $1 }'`;
	if [[ $temp -lt 0 || $temp -gt 255 ]]; then
		return 1;
	fi

		# Проверка второго значения
	temp=`echo $1 | awk -F'\.' '{ print $2 }'`;
	if [[ $temp -lt 0 || $temp -gt 255 ]]; then
		return 1;
	fi

		# Проверка третьего значения
	temp=`echo $1 | awk -F'\.' '{ print $3 }'`;
	if [[ $temp -lt 0 || $temp -gt 255 ]]; then
		return 1;
	fi

		# Проверка четвертого значения
	temp=`echo $1 | awk -F'\.' '{ print $4 }'`;
	if [[ $temp -lt 0 || $temp -gt 255 ]]; then
		return 1;
	fi

	return 0;
}

SetMask() {
	clear;
	echo "Set mask";
	read;
}

Calculate() {
	clear;
	echo "Calculate";
	read;
}

isDone=0;
while [[ $isDone -ne 1 ]]; do
	Menu;
	case "$?" in
		1)
			SetIp;
			;;
		2)
			SetMask;
			;;
		3)
			Calculate;
			;;
		4)
			isDone=1
			clear;
			;;
	esac
done
exit 0
