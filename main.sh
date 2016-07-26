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
	echo "4. Git";
	echo "5. Work with crontab";
	echo "6. Exit";
	echo;
	echo -n "Choose point menu: ";
	Input 1 6;
	return $?;
}

SetSource() {
	if [[ $# -eq 1 && $1 = "human" ]]; then
		clear;
		echo -n "Set source path: ";
		read srcPath;
	fi

	if [[ !( -d $srcPath ) && !( -f $srcPath ) && !( -b $srcPath ) ]]; then
		srcPath="None";
		if [[ $# -eq 1 && $1 = "human" ]]; then
			echo "Error. Wrong source path.";
			read;
		fi
		return 1;
	fi

	if [[ !(-r $srcPath) ]]; then
		srcPath="None";
		if [[ $# -eq 1 && $1 = "human" ]]; then
			echo "Soucer file permission denied.";
			read;
		fi
		return 1;
	fi

	endChar=`echo $srcPath | awk -F'/' '{ printf"%s\n", substr($0,length,1) }'`;
	if [[ !($endChar = '/') && (-d $srcPath) ]]; then
		srcPath="$srcPath/";
	fi
	return 0;
}

SetDestination() {
	if [[ $# -eq 1 && $1 = "human" ]]; then
		clear;
		echo -n "Set destination path: ";
		read dstPath;
	fi

	if [[ !( -e $dstPath ) ]]; then
		dstPath="None";
		if [[ $# -eq 1 && $1 = "human" ]]; then
			echo "Error. Wrong destination path.";
			read;
		fi
		return 1;
	elif [[ !( -d $dstPath ) ]]; then
		dstPath="None";
		if [[ $# -eq 1 && $1 = "human" ]]; then
			echo "Error. Destination path should be a folder.";
			read;
		fi
		return 1;
	fi

	if [[ !(-w $dstPath) ]]; then
		dstPath="None";
		if [[ $# -eq 1 && $1 = "human" ]]; then
			echo "Destination file permission denied.";
			read;
		fi
		return 1;
	fi

	endChar=`echo $dstPath | awk -F'/' '{ printf"%s\n", substr($0,length,1) }'`;
	if [[ !($endChar = '/') ]]; then
		dstPath="$dstPath/";
	fi
	return 0;
}

Backup() {
	if [[ $# -eq 1 && $1 = "human" ]]; then
		clear;
		echo "Backup...";
	fi

	if [[ $srcPath = "None" || $dstPath = "None" ]]; then
		if [[ $# -eq 1 && $1 = "human" ]]; then
			echo "Error. Source and destination path not set.";
			read;
		fi
		return 1;
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
		archName=`echo $srcPath | awk -F'/' '{ print $(NF-1) }'`;
		`tar -P -czf $dstPath$archName.tar.gz $srcPath`;

	#
	#	Block device
	#
	elif [[ -b $srcPath ]]; then
		archName=`echo $srcPath | awk -F'/' '{ print $NF }'`;
		`dd status=none if=$srcPath of=$dstPath$archName.img`;
	fi

	if [[ $# -eq 1 && $1 = "human" ]]; then
		echo "Backup end, press any key...";
		read;
	fi
	return 0;
}

Git() {
	if [[ $# -eq 1 && $1 = "human" ]]; then
		clear;
		echo "Git...";
	fi

	if [[ $srcPath = "None" ]]; then
		if [[ $# -eq 1 && $1 = "human" ]]; then
			echo "Error. Setup source and destination path not set.";
			read;
		fi
		return 1;
	fi

	#
	#	File
	#
	if [[ -f $srcPath ]]; then
		dir=`echo $srcPath | awk -F'/' '{print substr($0,0,length-length($NF)+1)}'`;
		cd $dir;
		checkGit=`ls -al $dir | grep .git`;
		if [[ -z $checkGit ]]; then
			git init > /dev/null 2>&1;
		fi
		fileName=`echo $srcPath | awk -F'/' '{ print $NF }'`;
		git add $fileName > /dev/null 2>&1;
		git commit -m "`date`" > /dev/null 2>&1;

	#
	#	Folder
	#
	elif [[ -d $srcPath ]]; then
		dir=`echo $srcPath`;
		cd $dir;
		checkGit=`ls -al $dir | grep .git`;
		if [[ -z $checkGit ]]; then
			git init > /dev/null 2>&1;
		fi
		git add . > /dev/null 2>&1;
		git commit -m "`date`" > /dev/null 2>&1;
	fi
	if [[ $# -eq 1 && $1 = "human" ]]; then
		echo "Commit was created";
		read;
	fi
}

CrontabMenu() {
	clear;
	echo "Work with crontab";
	echo;
	echo "1. Add";
	echo "2. Show";
	echo "3. Delete";
	echo "4. Back";
	echo;
	echo -n "Choose point menu: ";
	Input 1 4;
	return $?;
}

CrontabCycle() {
isCronDone=0;
	while [[ $isCronDone -ne 1 ]]; do
		CrontabMenu;
		case "$?" in
			1)
				AddInCrontab;
				case "$?" in
					1)
						AddGit;
						;;
					2)
						AddBackup;
						;;
				esac
				;;
			2)
				ShowJobs;
				;;
			3)
				DeleteJobs;
				;;
			4)
				isCronDone=1
				;;
		esac
	done
	return 0;
}

AddInCrontab() {
	clear;
	echo "Add new job in crontab";
	echo "1. Add git";
	echo "2. Add backup";
	echo;
	echo -n "Choose point menu: ";
	Input 1 2;
	return $?;
}

AddGit() {
	clear;
	echo "Add git";

	if [[ $srcPath = "None" ]]; then
		echo "Error. Source path not set.";
		read;
		return 1;
	fi

	if [[ !( -d $srcPath ) && !( -f $srcPath ) ]]; then
		echo "Error. Source not available for git";
		read;
		return 1;
	fi

	echo "1. Minutes";
	echo "2. Hours";
	echo;
	echo -n "Choose pereodicity: ";
	Input 1 2;
	answer=$?;

	tmpVal=$$;
	tmpPath=`pwd`/.tmp.$tmpVal;
	`crontab -l > $tmpPath`;

	case "$answer" in
		1)
			echo -n "Repeat every ... minutes: ";
			Input 1 30;
			echo "*/$? * * * * `pwd`/`basename "$0"` $srcPath #gitBackup" >> $tmpPath;
			;;
		2)
			echo -n "Repeat every ... hours: ";
			Input 1 12;
			echo "0 */$? * * * `pwd`/`basename "$0"` $srcPath #gitBackup" >> $tmpPath;
			;;
	esac
	crontab $tmpPath;
	`rm $tmpPath`;
}

AddBackup() {
	clear;
	echo "Add backup";

	if [[ $srcPath = "None" || $dstPath = "None" ]]; then
		echo "Error. Source and destination path not set.";
		read;
		return 1;
	fi

	echo "1. Minutes";
	echo "2. Hours";
	echo;
	echo -n "Choose pereodicity: ";
	Input 1 2;
	answer=$?;

	tmpVal=$$;
	tmpPath=`pwd`/.tmp.$tmpVal;
	`crontab -l > $tmpPath`;

	case "$answer" in
		1)
			echo -n "Repeat every ... minutes: ";
			Input 1 30;
			echo "*/$? * * * * `pwd`/`basename "$0"` $srcPath $dstPath #Backup" >> $tmpPath;
			;;
		2)
			echo -n "Repeat every ... hours: ";
			Input 1 12;
			echo "0 */$? * * * `pwd`/`basename "$0"` $srcPath $dstPath #Backup" >> $tmpPath;
			;;
	esac
	crontab $tmpPath;
	`rm $tmpPath`;
}

ShowJobs() {
	if [[ $# -eq 0 ]]; then
		clear;
		echo "Backup";
		echo;
		crontab -l | grep '#Backup' | awk '{ print NR") Src:"$7"; Dst:"$8"; Hour:"$2"; Min:"$1 }';

		echo;
		echo "Git";
		echo;
		crontab -l | grep '#gitBackup' | awk '{ print NR") Src:"$7"; Hour:"$2"; Min:"$1 }';

		echo -n "Press any key...";
		read;
	elif [[ $# -eq 1 && $1 = "Backup" ]]; then
		crontab -l | grep '#Backup' | awk '{ print NR") Src:"$7"; Dst:"$8"; Hour:"$2"; Min:"$1 }';
	elif [[ $# -eq 1 && $1 = "Git" ]]; then
		crontab -l | grep '#gitBackup' | awk '{ print NR") Src:"$7"; Hour:"$2"; Min:"$1 }';
	fi
	return 0;
}

DeleteJobs() {
	clear;
	echo "Delete job";
	echo "1. Git";
	echo "2. Crontab";
	echo;
	echo -n "Choose point menu: ";
	Input 1 2;
	case "$?" in
		1)
			clear;
			echo "Delete git from crontab";
			echo;
			ShowJobs Git;
			echo;
			echo -n "Choose point for delete(0 - exit): ";
			Input 0 `crontab -l | grep -c '#gitBackup'`;
			point=$?;
			if [[ $point -eq 0 ]]; then
				return 1;
			fi

			tmpVal=$$;
			tmpPath=`pwd`/.tmp.$tmpVal;
			`crontab -l > $tmpPath`;

			counter=1;
			for i in `crontab -l | grep -n '#gitBackup' | awk -F':' '{ print $1 }'`
			do
				if [[ $counter -eq $point ]]; then
					sed "${i}d" $tmpPath -i;
					break;
				fi
				counter=$(($counter+1));
			done
			;;
		2)
			clear;
			echo "Delete backup from crontab";
			echo;
			ShowJobs Backup;
			echo;
			echo -n "Choose point for delete(0 - exit): ";
			Input 0 `crontab -l | grep -c '#Backup'`;
			point=$?;
			if [[ $point -eq 0 ]]; then
				return 1;
			fi

			tmpVal=$$;
			tmpPath=`pwd`/.tmp.$tmpVal;
			`crontab -l > $tmpPath`;

			counter=1;
			for i in `crontab -l | grep -n '#Backup' | awk -F':' '{ print $1 }'`
			do
				if [[ $counter -eq $point ]]; then
					sed "${i}d" $tmpPath -i;
					break;
				fi
				counter=$(($counter+1));
			done
			;;
	esac
	crontab $tmpPath;
	`rm $tmpPath`;
}

if [[ $# -eq 1 ]]; then		# Git
	srcPath=$1;
	SetSource;
	if [[ $? -ne 0 ]]; then
		return 1;
	fi
	Git;
	if [[ $? -ne 0 ]]; then
		return 1;
	fi
elif [[ $# -eq 2 ]]; then	# Backup
	srcPath=$1;
	dstPath=$2;
	SetSource;
	if [[ $? -ne 0 ]]; then
		return 1;
	fi
	SetDestination;
	if [[ $? -ne 0 ]]; then
		return 1;
	fi
	Backup;
	if [[ $? -ne 0 ]]; then
		return 1;
	fi
else						# Human
	isDone=0;
	while [[ $isDone -ne 1 ]]; do
		Menu;
		case "$?" in
			1)
				SetSource human;
				;;
			2)
				SetDestination human;
				;;
			3)
				Backup human;
				;;
			4)
				Git human;
				;;
			5)
				CrontabCycle;
				;;
			6)
				isDone=1
				clear;
				;;
		esac
	done
fi
exit 0
