#!/bin/bash

echo Hello Dear,
echo kindly choice one option from the list below 
echo 

 select choice in "create database" "list database" "connect to database" "drop database"
 do
 
 case $REPLY in 
 
1)
echo kindly type the name if the database
read $REPLY
cd ~/Desktop/bashproject/database
ls database > list


;;
2)
echo 2
;;
3)
echo 3
;;
4)
echo 4
;;
*)
echo $REPLY in not one of the optiones.
;;

esac
done




