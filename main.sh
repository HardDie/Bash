#!/bin/bash

menu() {
	echo "--------------------[Главное меню]--------------------"
	echo "1 - Добавить будильник"
	echo "2 - Посмотреть список будильников"
	echo "3 - Удалить будильник"
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
	hi=$(crontab -l | awk -F# '/#alarm/ {print $1}' | awk -F* '{print $1, $4}')
	echo "$hi"

	return 0
}

deleteAlarm() {
	echo "--------------------[Удалить будильник]--------------------"
	return 0
}

clear
echo "			Bash лабораторная №3, Будильник с crontab"
echo

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
esac

exit 0
