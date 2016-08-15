#!/bin/bash

ip="None";
mask="None";
available=0;
masIP;
masMAC;

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
	echo "		Lab 11. Find hosts";
	echo;
	echo "1. Find hosts";
	echo "2. Show prev hosts";
	echo "3. Exit";
	echo;
	echo -n "Choose point menu: ";
	Input 1 3;
	return $?;
}

MinHost() {
	oct1=`echo "$ip" | awk -F \. '{ printf $1 }'`;
	oct2=`echo "$ip" | awk -F \. '{ printf $2 }'`;
	oct3=`echo "$ip" | awk -F \. '{ printf $3 }'`;
	oct4=`echo "$ip" | awk -F \. '{ printf $4 }'`;
	msk1=`echo "$mask" | awk -F \. '{ printf $1 }'`;
	msk2=`echo "$mask" | awk -F \. '{ printf $2 }'`;
	msk3=`echo "$mask" | awk -F \. '{ printf $3 }'`;
	msk4=`echo "$mask" | awk -F \. '{ printf $4 }'`;
	ipMin[1]=`echo $(( $oct1 & $msk1 ))`;
	ipMin[2]=`echo $(( $oct2 & $msk2 ))`;
	ipMin[3]=`echo $(( $oct3 & $msk3 ))`;
	ipMin[4]=`echo $((( ($oct4 & $msk4) + 1 )))`;
}

MaxHost() {
	ipMax[1]=$(($oct1+(255-($oct1 | $msk1))));
	ipMax[2]=$(($oct2+(255-($oct2 | $msk2))));
	ipMax[3]=$(($oct3+(255-($oct3 | $msk3))));
	ipMax[4]=$(($oct4+(254-($oct4 | $msk4))));
}

HostCounts() {
	if [[ $mask == "None" ]]; then
		return 1;
	fi
	msk1=`echo "$mask" | awk -F \. '{ printf $1 }'`;
	msk2=`echo "$mask" | awk -F \. '{ printf $2 }'`;
	msk3=`echo "$mask" | awk -F \. '{ printf $3 }'`;
	msk4=`echo "$mask" | awk -F \. '{ printf $4 }'`;
	hs=$(((256-$msk1)*(256-$msk2)*(256-$msk3)*(256-$msk4)-2));
}

ChooseIntreface() {
	clear;
	countFace=`ifconfig | grep -v lo | grep "Link encap" | wc -l`;
	if [[ $countFace -gt 1 ]]; then
		listFace=`ifconfig | grep -v lo | grep "Link encap" | awk '{ print $1 }'`;
		number=1;
		echo "№ IFace IP Mask" | awk '{ printf( " %2s ||%12s ||%15s ||%15s\n", $1, $2, $3, $4 ) }'
		for i in $listFace
		do
			name[$number]=$i;
			ip[$number]=`ifconfig $i | grep "inet addr" | awk '{ print $2 }' | awk -F: '{ print $2 }'`;
			mask[$number]=`ifconfig $i | grep "inet addr" | awk '{ print $4 }' | awk -F: '{ print $2 }'`;
			echo "$number ${name[$number]} ${ip[$number]} ${mask[$number]}" | awk '{ printf( "%2d ||%12s ||%15s ||%15s\n", $1, $2, $3, $4 ) }';
			number=$(($number+1));
		done
		echo;
		echo -n "Choose interface: ";
		Input 1 $countFace;
		faceNum=$?;
		ip=${ip[$faceNum]};
		mask=${mask[$faceNum]};
	elif [[ $countFace -eq 1 ]]; then
		face=`ifconfig | grep -v lo | grep "Link encap" | awk '{ print $1 }'`;
		ip[$number]=`ifconfig $face | grep "inet addr" | awk '{ print $2 }' | awk -F: '{ print $2 }'`;
		mask[$number]=`ifconfig $face | grep "inet addr" | awk '{ print $4 }' | awk -F: '{ print $2 }'`;
	else
		ip="None";
		mask="None";
		return 1;
	fi
	return 0;
}

FindHosts() {
	clear;
	ChooseIntreface;
	if [[ $? -ne 0 ]]; then
		echo "Error, interface not available!";
		read;
		return 1;
	fi

	HostCounts;
	MaxHosts=$hs;
	if [[ $MaxHosts -eq 1 ]]; then
		echo "Mask not set!";
		read;
		return 1;
	fi

	CurrentHost=0;
	tmpfile=.tmp.$$;
	touch $tmpfile;
	echo -n > $tmpfile;

	MinHost;	# обязательно вызвывать первым
	MaxHost;

	for (( a = ${ipMin[1]}; a <= ${ipMax[1]}; a++ ))
	do
		for (( b = ${ipMin[2]}; b <= ${ipMax[2]}; b++ ))
		do
			for (( c = ${ipMin[3]}; c <= ${ipMax[3]}; c++ ))
			do
				for (( d = ${ipMin[4]}; d <= ${ipMax[4]}; d++ ))
				do
					(ping -c 1 -W 1 "$a.$b.$c.$d" | grep -B 1 "1 received" | grep "ping statistics" | awk '{ print $2 }') >> $tmpfile &
					CurrentHost=$(($CurrentHost+1));
					echo -ne "Progress = $(($CurrentHost*100/$MaxHosts))%\r";
				done
			done
		done
	done
	wait;

	ipList=`cat $tmpfile | sort`;
	rm $tmpfile;
	available=0;

	clear;
	echo "IP HWaddr" | awk '{ printf( "%16s %18s\n", $1, $2 ) }';
	for i in $ipList
	do
		if [[ $i = $ip ]]; then
			continue;
		fi
		available=$(($available+1));
		masIP[$available]=$i;
		masMAC[$available]=`arp -a $i | awk '{ print $4 }'`;
		echo "${masIP[$available]} ${masMAC[$available]}" | awk '{ printf( "%16s %18s\n", $1, $2 ) }';
	done

	echo -n "Press any key...";
	read;
	return 0;
}

ShowPrevHosts() {
	clear;
	echo "IP HWaddr" | awk '{ printf( "%16s %18s\n", $1, $2 ) }';
	for (( i = 1; i <= $available; i++ ))
	do
		echo "${masIP[$i]} ${masMAC[$i]}" | awk '{ printf( "%16s %18s\n", $1, $2 ) }';
	done

	echo -n "Press any key...";
	read;
	return 0;
}

isDone=0;
while [[ $isDone -ne 1 ]]; do
	Menu;
	case "$?" in
		1)
			FindHosts;
			;;
		2)
			ShowPrevHosts;
			;;
		3)
			isDone=1
			clear;
			;;
	esac
done
exit 0
