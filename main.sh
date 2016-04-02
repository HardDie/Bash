#!/bin/bash

echo "			Bash лабораторная №1, создание папок"
echo
echo -n "Введите директорию в которой создавать папки: "

read mainDir
firstLevel=5
secondLevel=10
thirdLevel=20



k=0

if [ -d $mainDir ]; then
	cd $mainDir
	i=0	#Инициализация переменной цикла
	while [ $i -lt $firstLevel  ]; do

		mkdir "folder$i"
		if [ $? -eq 1 ]; then
			echo "Не удалось создать папку \"folder$i\" в директории \"$PWD\""
			exit 1
		fi
		cd "folder$i"
		j=0	#Инициализация переменной цикла
		while [ $j -lt $secondLevel ]; do

			mkdir "folder$j"
			if [ $? -eq 1 ]; then
				echo "Не удалось создать папку \"folder$i$j\" в директории \"$PWD\""
				exit 1
			fi
			cd "folder$j"
			k=0	#Инициализация переменной цикла
			while [ $k -lt $thirdLevel ]; do

				touch "file$k"
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
