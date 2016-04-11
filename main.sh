#!/bin/bash

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

	crontab -l > .tmp.$$
	echo "$minute $hour * * * export DISPLAY=:0 && xterm -e "dialog --msgbox \'$message\' 234 234" #alarm" >> .tmp.$$
	crontab .tmp.$$
	rm .tmp.$$
}

showAlarm() {
	echo "--------------------[Показать список будильников]--------------------"
	#hi=$(crontab -l | awk -F# '/#alarm/ {print $1}' | awk -F* '{print $1, $4}')
	alarms=$(crontab -l | awk -F# ' /#alarm/ { print $1 } ' | awk -F"'" '{ print $1, " |", $2 }' |  awk ' { gsub("export DISPLAY=:0 && xterm -e dialog --msgbox","",$0); gsub("*","",$0); gsub("  ","",$0); printf "%2d %s %s|%s\n", NR, $2, $1, $0 } ' | awk -F"|" '{ print $1, $3 }')
	echo | awk ' {print "==============================="; print " №  H  M  Message"; print "===============================";} '
	echo "$alarms"
	return 0
}

deleteAlarm() {
	echo "--------------------[Удалить будильник]--------------------"
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
