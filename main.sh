#!/bin/bash

Menu() {
	clear;
	echo "		Lab 10. Htop";
	echo;
	echo "1 - Show memory";
	echo "2 - Show swap";
	echo "3 - Show CPU";
	echo "4 - Show load average";
	echo "5 - Exit";
	echo
	echo -n "Choose point menu: "

	Input 1 5
	return "$?"
}

Input() {
	temp=-1
	while [[ $temp -eq -1 ]]; do
		read temp
		case "$temp" in
			[0-9] | [0-9][0-9])
				if [[ $temp -lt $1 || $temp -gt $2 ]]; then
					echo -n "Wrong input, try again: "
					temp=-1
				fi;;
			*)
				echo -n "Wrong input, try again: "
				temp=-1;;
		esac
	done
	return "$temp"
}

ShowMemory() {
	clear;
	echo "Show memory";
	echo;

	str=`top -n1 | grep "KiB Mem"`;

	echo -n "Total : ";
	tmp=`echo $str | awk '{ print $4 }'`;
	tmp=$(($tmp/1024));
	echo "$tmp"M;

	echo -n "Used  : ";
	tmp=`echo $str | awk '{ print $6 }'`;
	tmp=$(($tmp/1024));
	echo "$tmp"M;

	echo -n "Free  : ";
	tmp=`echo $str | awk '{ print $8 }'`;
	tmp=$(($tmp/1024));
	echo "$tmp"M;

	echo -n "Press any key...";
	read;
}

ShowSwap() {
	clear;
	echo "Show swap";
	echo;

	str=`top -n1 | grep "KiB Swap"`;

	echo -n "Total : ";
	tmp=`echo $str | awk '{ print $3 }'`;
	tmp=$(($tmp/1024));
	echo "$tmp"M;

	echo -n "Used  : ";
	tmp=`echo $str | awk '{ print $5 }'`;
	tmp=$(($tmp/1024));
	echo "$tmp"M;

	echo -n "Free  : ";
	tmp=`echo $str | awk '{ print $7 }'`;
	tmp=$(($tmp/1024));
	echo "$tmp"M;

	echo -n "Press any key...";
	read;
}

ShowCpu() {
	clear;
	echo "Show cpu";
	echo;
	echo "User CPU time : ";
	top -n1
}

isDone=0
while [[ $isDone -ne 1 ]]; do
	Menu
	case "$?" in
		1)
			ShowMemory;
			;;
		2)
			ShowSwap;
			;;
		3)

			;;
		5)
			isDone=1
			clear;
			;;
	esac
done

exit 0
