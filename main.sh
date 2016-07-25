#!/bin/bash

srcPath="None";
dstPath="None";

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
	echo "		Lab 8. Backup";
	echo;
	echo "Source: $srcPath";
	echo "Destination: $dstPath";
	echo;
	echo "1. Set source";
	echo "2. Set destination";
	echo "3. Backup";
	echo "4. Exit";
	echo;
	echo -n "Choose point menu: ";
	Input 1 4;
	return $?;
}

SetSource() {
	clear;
	echo -n "Set source path: ";
	read srcPath;
	if [[ !( -d $srcPath ) && !( -f $srcPath ) ]]; then
		echo "Error. Wrong source path.";
		srcPath="None";
		read;
		return 0;
	fi
}

SetDestination() {
	clear;
	echo -n "Set destination path: ";
	read dstPath;
	if [[ -f $dstPath ]]; then
		echo "Error. Destination path should be a folder.";
		dstPath="None";
		read;
		return 0;
	fi
	if [[ !( -d $dstPath ) ]]; then
		echo "Error. Wrong destination path.";
		dstPath="None";
		read;
		return 0;
	fi
}

Backup() {
	clear;
	echo "Backup...";
	if [[ $source = "None" || $destination = "None" ]]; then
		echo "Error. Setup source and destination path";
		read;
		return 0;
	fi
}

isDone=0;
while [[ $isDone -ne 1 ]]; do
	Menu;
	case "$?" in
		1)
			SetSource;
			;;
		2)
			SetDestination;
			;;
		3)
			Backup;
			;;
		4)
			isDone=1
			clear;
			;;
	esac
done

exit 0
