#!/bin/bash

echo "			Bash лабораторная №2, создание папок с возможностью выбора места, количества и имени"
echo
echo -n "Введите директорию в которой создавать папки: "

read mainDir

echo -n "Введите количество папок на первом уровне: "
read firstLevel
echo -n "Введите их имя: "
read nameFirst

echo -n "Введите количество папок на втором уровне: "
read secondLevel
echo -n "Введите их имя: "
read nameSecond

echo -n "Введите количество файлов: "
read thirdLevel
echo -n "Введите их имя: "
read nameThird

if [ -d $mainDir ]; then
	cd $mainDir
	i=0	#Инициализация переменной цикла
	while [ $i -lt $firstLevel  ]; do

		mkdir "$nameFirst$i"
		if [ $? -eq 1 ]; then
			echo "Не удалось создать папку \"folder$i\" в директории \"$PWD\""
			exit 1
		fi
		cd "$nameFirst$i"
		j=0	#Инициализация переменной цикла
		while [ $j -lt $secondLevel ]; do

			mkdir "$nameSecond$j"
			if [ $? -eq 1 ]; then
				echo "Не удалось создать папку \"folder$i$j\" в директории \"$PWD\""
				exit 1
			fi
			cd "$nameSecond$j"
			k=0	#Инициализация переменной цикла
			while [ $k -lt $thirdLevel ]; do

				touch "$nameThird$k"
				k=$(($k + 1))

			done
			cd ..
			j=$(($j + 1))

		done
		cd ..
		i=$(($i + 1))

	done
else
	echo "Такой директории не существует!"
	exit 1
fi

exit 0
