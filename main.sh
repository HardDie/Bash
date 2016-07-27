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
		echo -n "Press any key to continue...";
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
	echo;
	echo -n "Enter mask: ";
	read mask;
	CheckMask $mask;
	res=$?;
	if [[ $res -eq 1 ]]; then
		echo "Wrong mask";
		mask="None";
		echo -n "Press any key to continue...";
		read;
	elif [[ $res -eq 2 ]]; then
		for (( i=1; i <= 32; i++ ))
		do
			if [[ $i -le $mask ]]; then
				mas[$i]=1;
			else
				mas[$i]=0;
			fi
		done
		BinToDec;
		mask=$address;
	fi
}

CheckMask() {
	temp1=`echo $1 | egrep '^[0-9]{1,2}$'`;
	temp2=`echo $1 | egrep '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$'`;
	if [[ -z $temp1 && -z $temp2 ]]; then
		return 1;
	fi

	if [[ -n $temp1 ]]; then
			# Проверка значения на максимальную величину
		if [[ $temp1 -lt 0 || $temp1 -gt 32 ]]; then
			return 1;
		else
			return 2;
		fi
	elif [[ -n $temp2 ]];then
			# Проверка первого значения
		temp2=`echo $1 | awk -F'\.' '{ print $1 }'`;
		if [[ $temp2 -lt 0 || $temp2 -gt 255 ]]; then
			return 1;
		fi

			# Проверка второго значения
		temp2=`echo $1 | awk -F'\.' '{ print $2 }'`;
		if [[ $temp2 -lt 0 || $temp2 -gt 255 ]]; then
			return 1;
		fi

			# Проверка третьего значения
		temp2=`echo $1 | awk -F'\.' '{ print $3 }'`;
		if [[ $temp2 -lt 0 || $temp2 -gt 255 ]]; then
			return 1;
		fi

			# Проверка четвертого значения
		temp2=`echo $1 | awk -F'\.' '{ print $4 }'`;
		if [[ $temp2 -lt 0 || $temp2 -gt 255 ]]; then
			return 1;
		fi
	fi
	return 0;
}

BinToDec() {
	for (( i=0; i < 4; i++ ))
	do
		val=0;
		for (( j=0; j < 8; j++ ))
		do
			if [[ ${mas[$(( 1 + $j + ( 8 * $i ) ))]} -eq 1 ]]; then
				case "$j" in
					0)
						val=$(( $val + 128 ));
						;;
					1)
						val=$(( $val + 64 ));
						;;
					2)
						val=$(( $val + 32 ));
						;;
					3)
						val=$(( $val + 16 ));
						;;
					4)
						val=$(( $val + 8 ));
						;;
					5)
						val=$(( $val + 4 ));
						;;
					6)
						val=$(( $val + 2 ));
						;;
					7)
						val=$(( $val + 1 ));
						;;
				esac
			fi
		done
		if [[ $i -eq 0 ]]; then
			address=$val;
		else
			address=$address.$val;
		fi
	done
}

DecToBin() {
	temp[0]=`echo $1 | awk -F'\.' '{print $1}'`;
	temp[1]=`echo $1 | awk -F'\.' '{print $2}'`;
	temp[2]=`echo $1 | awk -F'\.' '{print $3}'`;
	temp[3]=`echo $1 | awk -F'\.' '{print $4}'`;
	for (( i=3; i >= 0; i-- ))
	do
		for (( j=0; j < 8; j++ ))
		do
			if [[ $((${temp[$i]} % 2)) -eq 0 ]]; then
				mas[$(( 32 - $j - ( 8 * ( 3 - $i ) ) ))]=0;
			else
				mas[$(( 32 - $j - ( 8 * ( 3 - $i ) ) ))]=1;
			fi
			temp[$i]=$((${temp[$i]} / 2));
		done
	done
}

Calculate() {
	clear;
	echo "Calculate";
	if [[ $ip = "None" || $mask = "None" ]]; then
		echo "Mask or IP not set";
		read;
		return 1;
	fi

	echo "IP        : $ip";
	echo "Mask      : $mask";

	#
	# Получаем адресс подсети
	#
	DecToBin $mask;		# Переводим маску в двоичный код
	for (( i=1; i < 33; i++ ))
	do
		tmpmas[$i]=${mas[$i]};
	done

	DecToBin $ip;		# Переводим IP в двоичный код

	for (( i=1; i < 33; i++ ))	# Делаем побитовое умножение маски и IP
	do
		if [[ ${tmpmas[$i]} -eq 0 || ${mas[$i]} -eq 0 ]]; then
			mas[$i]=0;
		else
			mas[$i]=1;
		fi
	done
	BinToDec;
	echo "Network   : $address";

	mas[32]=1;	# Вычисляем минимального хоста
	BinToDec;
	minHost=$address;

	#
	# Получаем broadcast
	#
	DecToBin $ip;		# Переводим IP в двоичный код
	for (( i=1; i < 33; i++ ))
	do
		if [[ ${tmpmas[$i]} -eq 0 ]]; then
			mas[$i]=1;
		fi
	done
	BinToDec;
	echo "Broadcast : $address";

	#
	# Получаем минимального и максимального хоста
	#
	echo "Min host  : $minHost";
	mas[32]=0;	# Вычисляем максимаьлного хоста
	BinToDec;
	echo "Max host  : $address";

	echo -n "Press any key to continue...";
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
