#!/bin/bash

alarmCount() {
	return `crontab -l | grep \#alarm | wc -l`
}

menu() {
	echo "--------------------[Главное меню]--------------------"
	echo "1 - Добавить будильник"
	echo "2 - Посмотреть список будильников"
	echo "3 - Удалить будильник"
	echo "4 - Выход"
	echo
	echo -n "Выберите пункт меню: "

	pointMenu=0
	while [ $pointMenu -eq 0 ]; do
		read pointMenu
		case "$pointMenu" in
			1)
				pointMenu=1;;
			2)
				pointMenu=2;;
			3)
				pointMenu=3;;
			4)
				pointMenu=4;;
			*)
				echo -n "Неверный ввоод, повторите попытку: "
				pointMenu=0;;
		esac
	done
	return "$pointMenu"
}

input() {
	temp=-1
	while [[ $temp -eq -1 ]]; do
		read temp
		case "$temp" in
			[0-9] | [0-9][0-9])
				if [[ $temp -lt $1 || $temp -gt $2 ]]; then
					echo -n "Неверный ввод, повторите попытку: "
					temp=-1
				fi;;
			*)
				echo -n "Неверный ввод, повторите попытку: "
				temp=-1;;
		esac
	done
	return "$temp"
}

addAlarm() {
	echo "--------------------[Добавить будильник]--------------------"
	echo -n "Введите час: "
	input 0 23
	hour=$?

	echo -n "Введите минуты: "
	input 0 59
	minute=$?

	echo -n "Введите текст сообщения: "
	read message

	tmp_val=$$
	crontab -l > .tmp.$tmp_val
	echo "$minute $hour * * * export DISPLAY=:0 && xterm -e "dialog --msgbox \'$message\' 234 234" #alarm" >> .tmp.$tmp_val
	crontab .tmp.$tmp_val
	rm .tmp.$tmp_val
}

showAlarm() {
	echo "--------------------[Показать список будильников]--------------------"
	alarms=$(crontab -l | awk -F# ' /#alarm/ { print $1 } ' | awk -F"'" '{ print $1, " |", $2 }' |  awk ' { gsub("export DISPLAY=:0 && xterm -e dialog --msgbox","",$0); gsub("*","",$0); gsub("  ","",$0); printf "%2d %s %s|%s\n", NR, $2, $1, $0 } ' | awk -F"|" '{ print $1, $3 }')
	echo | awk ' {print "==============================="; print " №  H  M  Message"; print "===============================";} '
	echo "$alarms"
	return 0
}

deleteAlarm() {
	echo "--------------------[Удалить будильник]--------------------"
	alarmCount	# Вызываем функция для подсчета текущего количества будильников
	cntAlarm=$?
	if [ $cntAlarm -eq 0 ]; then
		echo "Нет будильников"
		return -1
	fi
	echo -n "Введите номер будильника: "
	input 1 $cntAlarm	# Считываем номер удаляемого будильника, от 1 до количества будильников
	numberAlarm=$?	# Сохраняем номер удаляемого будильника
	temp=$$
	touch .temp.$temp
	crontab -l > .temp.$temp
	tmp=`cat .temp.$temp | grep alarm -n | awk -F: '{ print $1 }'`
	j=1
	for i in $tmp
	do
		if [ $j -eq $numberAlarm ]; then
			strNum=$i
		fi
		j=$(($j+1))
	done
	sed -i "${strNum}d" .temp.$temp
	crontab .temp.$temp
	rm .temp.$temp
	return 0
}

clear
clear
clear
echo "			Bash лабораторная №3, Будильник с crontab"
echo

isDone=0
while [[ $isDone -ne 1 ]]; do
	menu
	case "$?" in
		1)
			addAlarm
			;;
		2)
			showAlarm
			;;
		3)
			deleteAlarm
			;;
		4)
			isDone=1
			;;
	esac
done

exit 0
