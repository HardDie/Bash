#!/bin/bash

Menu() {
	clear;
	echo "			Bash lab №4, Process control";
	echo "--------------------[Main menu]--------------------";
	echo "1 - Add process control";
	echo "2 - Delete process control";
	echo "3 - Show list";
	echo "4 - Exit";
	echo;
	echo -n "Choose point menu: ";

	Input 1 4;
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

AddProcess() {
	clear;
	echo "--------------------[Add process control]--------------------";
	echo "1 - Pereodicity minutes";
	echo "2 - Pereodicity hours";
	echo "3 - Back";
	echo;
	echo -n "Choose menu point: ";
	Input 1 3;

	case "$?" in
		1)
			echo -n "Every ... minutes: ";
			Input 1 30;
			per=$?;
			echo -n "Input process name: ";
			read process;
			tmp_val=$$;
			touch .tmp.$tmp_val;
			crontab -l > .tmp.$tmp_val;
			echo "*/$per * * * * /home/harddie/bash_project/Bash/main.sh $process #process_control" >> .tmp.$tmp_val;
			crontab .tmp.$tmp_val;
			rm .tmp.$tmp_val;
			;;
		2)
			echo -n "Every ... hours: ";
			Input 1 30;
			per=$?;
			echo -n "Input process name: ";
			read process;
			tmp_val=$$;
			touch .tmp.$tmp_val;
			crontab -l > .tmp.$tmp_val;
			echo "0 */$per * * * /home/harddie/bash_project/Bash/main.sh $process #process_control" >> .tmp.$tmp_val;
			crontab .tmp.$tmp_val;
			rm .tmp.$tmp_val;
			;;
		3)
			return 0;
			;;
	esac

	return 0;
}

DeleteProcess() {
	clear;
	ProcessList;
	echo "--------------------[Delete process control]--------------------";
	echo;
	echo -n "Choose process for delete(0 back): ";
	processCount=`crontab -l | grep \#process_control | wc -l`;
	if [[ $processCount -eq 0 ]]; then
		clear;
		echo "No process control"
		echo -n "Press any key...";
		read;
		return 0;
	fi
	Input 0 $processCount;
	processForDelete=$?;
	if [[ $processForDelete -eq 0 ]]; then
		return 0;
	fi
	processList=`crontab -l | grep \#process_control -n | awk -F: '{ print $1 }'`;
	tmp_val=$$;
	touch .tmp.$tmp_val;
	crontab -l > .tmp.$tmp_val;
	j=1;
	for i in $processList
	do
		if [[ $j -eq $processForDelete ]]; then
			sed -i "${i}d" .tmp.$tmp_val;
		fi
		j=$(($j+1));
	done
	crontab .tmp.$tmp_val;
	rm .tmp.$tmp_val;
	return 0;
}

ProcessList() {
	echo " №    hour  min    process";
	crontab -l | grep \#process_control | awk -F# '{ print $1 }' | awk '{ printf "%2d) %5s %5s    %s\n", NR, $2, $1, $7 }';
	return 0;
}

if [[ $# -eq 1 ]]; then
	if [ `ps -ax | grep $1 | grep -v grep | grep -v main.sh | wc -l` -eq 0 ]; then
		DISPLAY=:0.0 $1;
	fi
else
	isDone=0;
	while [[ $isDone -ne 1 ]]; do
		Menu;
		case "$?" in
			1)
				AddProcess;
				;;
			2)
				DeleteProcess;
				;;
			3)
				clear;
				echo "--------------------[Process list]--------------------";
				ProcessList;
				echo -n "Press any key...";
				read;
				;;
			4)
				isDone=1
				clear;
				;;
		esac
	done
fi

exit 0
