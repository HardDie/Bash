#!/bin/bash

Menu() {
	clear;
	echo "			Bash lab №5, Log";
	echo "--------------------[Main menu]--------------------";
	echo "1 - Show log";
	echo "2 - Exit";
	echo;
	echo -n "Choose point menu: ";

	Input 1 2;
	return "$?";
}

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

ProcessList() {
	echo " №    hour  min    process";
	crontab -l | grep \#process_control | awk -F# '{ print $1 }' | awk '{ printf "%2d) %5s %5s    %s\n", NR, $2, $1, $7 }';
	return 0;
}

CheckTime() {
	tmp=`echo $1 | awk -F: {'print $1'}`;
	case "$tmp" in
		[0-9][0-9])
		 	if [[ $tmp -lt 0 || $tmp -gt 23 ]]; then
				return 1;
			fi
			;;
		*)
			return 1;
			;;
	esac

	tmp=`echo $1 | awk -F: {'print $2'}`;
	case "$tmp" in
		[0-9][0-9])
		 	if [[ $tmp -lt 0 || $tmp -gt 59 ]]; then
				return 1;
			fi
			;;
		*)
			return 1;
			;;
	esac

	tmp=`echo $1 | awk -F: {'print $3'}`;
	case "$tmp" in
		[0-9][0-9])
		 	if [[ $tmp -lt 0 || $tmp -gt 59 ]]; then
				return 1;
			fi
			;;
		*)
			return 1;
			;;
	esac

	return 0;
}

InputTime() {
	result=1;
	while [[ $result -eq 1 ]]
	do
		echo -n "Input time start(hh:mm:ss)";
		read timeStart;
		CheckTime $timeStart;
		result=$?;
	done

	result=1;
	while [[ $result -eq 1 ]]
	do
		echo -n "Input time end(hh:mm:ss)";
		read timeEnd;
		CheckTime $timeEnd;
		result=$?;
	done
}

ShowLog() {
	echo -n "Input program name: ";
	read program;
	InputTime;

	cd /var/log
	
}

isDone=0;
while [[ $isDone -ne 1 ]]; do
	Menu;
	case "$?" in
		1)
			ShowLog;
			;;
		2)
			isDone=1
			clear;
			;;
	esac
done

exit 0
