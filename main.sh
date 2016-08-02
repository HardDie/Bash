#!/bin/bash

Menu() {
	clear;
	echo "		Lab 10. Htop";
	echo;
	echo "1 - Show memory";
	echo "2 - Show swap";
	echo "3 - Show CPU";
	echo "4 - Show load average";
	echo "5 - Process info";
	echo "6 - Exit";
	echo
	echo -n "Choose point menu: "

	Input 1 6
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

	str=`top -n1 | grep "%Cpu(s)"`;

	echo -n "User CPU time       : ";
	echo $str | awk '{ print $2 }';

	echo -n "System CPU time     : ";
	echo $str | awk '{ print $4 }';

	echo -n "Nice CPU time       : ";
	echo $str | awk '{ print $6 }';

	echo -n "Idle CPU time       : ";
	echo $str | awk '{ print $8 }';

	echo -n "Iowait              : ";
	echo $str | awk '{ print $10 }';

	echo -n "Hardware IRQ        : ";
	echo $str | awk '{ print $12 }';

	echo -n "Software Interrupts : ";
	echo $str | awk '{ print $14 }';

	echo -n "Steal Time          : ";
	echo $str | awk '{ print $16 }';

	echo -n "Press any key...";
	read;
}

ShowLoadAverage() {
	clear;
	echo "Show load average";
	echo;

	str=`top -n1 | grep "load average"`;

	echo -n "Average 1 minute  : ";
	echo $str | awk '{ print $10 }' | egrep -o '[0-9],[0-9][0-9]';

	echo -n "Average 5 minute  : ";
	echo $str | awk '{ print $11 }' | egrep -o '[0-9],[0-9][0-9]';

	echo -n "Average 15 minute : ";
	echo $str | awk '{ print $12 }';

	echo -n "Press any key...";
	read;
}

ShowProcessInfo() {
	clear;
	echo "Show process info";
	echo;

	str=`top -n1 | grep "Tasks"`;

	echo -n "Total    : ";
	echo $str | awk '{ print $2 }';

	echo -n "Running  : ";
	echo $str | awk '{ print $4 }';

	echo -n "Sleeping : ";
	echo $str | awk '{ print $6 }';

	echo -n "Stopped  : ";
	echo $str | awk '{ print $8 }';

	echo -n "Zombie   : ";
	echo $str | awk '{ print $10 }';

	echo -n "Press any key...";
	read;
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
			ShowCpu;
			;;
		4)
			ShowLoadAverage;
			;;
		5)
			ShowProcessInfo;
			;;
		6)
			isDone=1
			clear;
			;;
	esac
done

exit 0
