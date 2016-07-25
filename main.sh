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
	if [[ !( -d $srcPath ) && !( -f $srcPath ) && !( -b $srcPath ) ]]; then
		echo "Error. Wrong source path.";
		srcPath="None";
		read;
		return 0;
	fi

	endChar=`echo $srcPath | awk -F'/' '{ printf"%s\n", substr($0,length,1) }'`;
	if [[ !($endChar = '/') && (-d $srcPath) ]]; then
		srcPath="$srcPath/";
	fi
}

SetDestination() {
	clear;
	echo -n "Set destination path: ";
	read dstPath;
	if [[ !( -e $dstPath ) ]]; then
		echo "Error. Wrong destination path.";
		dstPath="None";
		read;
		return 0;
	elif [[ !( -d $dstPath ) ]]; then
		echo "Error. Destination path should be a folder.";
		dstPath="None";
		read;
		return 0;
	fi

	endChar=`echo $dstPath | awk -F'/' '{ printf"%s\n", substr($0,length,1) }'`;
	if [[ !($endChar = '/') ]]; then
		dstPath="$dstPath/";
	fi
}

Backup() {
	clear;
	echo "Backup...";
	if [[ $source = "None" || $destination = "None" ]]; then
		echo "Error. Setup source and destination path not set.";
		read;
		return 0;
	fi

	#
	#	File
	#
	if [[ -f $srcPath ]]; then
		archName=`echo $srcPath | awk -F'/' '{ print $NF }'`;
		`tar -P -czf $dstPath$archName.tar.gz $srcPath`;

	#
	#	Folder
	#
	elif [[ -d $srcPath ]]; then
		endChar=`echo $srcPath | awk -F'/' '{ printf"%s\n", substr($0,length,1) }'`;
		if [[ $endChar = '/' ]]; then
			archName=`echo $srcPath | awk -F'/' '{ print $(NF-1) }'`;
		else
			archName=`echo $srcPath | awk -F'/' '{ print $NF }'`;
		fi
		`tar -P -czf $dstPath$archName.tar.gz $srcPath`;

	#
	#	Block device
	#
	elif [[ -b $srcPath ]]; then
		echo "Source block device: $srcPath";
		archName=`echo $srcPath | awk -F'/' '{ print $NF }'`;
		echo "Archive path: $dstPath$archName.tar.gz";

	else
		echo "Error. Wrong source path";
	fi
	
	echo "Backup end, press any key...";
	read;
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
