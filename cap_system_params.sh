#!/bin/bash

PACKAGE_NAME="com.android.gallery3d"
adb shell ps
pid=`adb shell ps | grep $PACKAGE_NAME | awk '{print $2}'`
echo $pid
#adb root
#adb remount

if [ -f $PACKAGE_NAME-$pid.log ]
then
    echo "file exist"
    rm $PACKAGE_NAME-$pid.log
fi
touch $PACKAGE_NAME-$pid.log

while :
do
    date >> ./$PACKAGE_NAME-$pid.log
    adb shell cat /proc/$pid/status >> ./$PACKAGE_NAME-$pid.log
    adb shell procrank >> ./$PACKAGE_NAME-$pid.log
    adb shell dumpsys meminfo >> ./$PACKAGE_NAME-$pid.log
    adb shell dumpsys meminfo $pid >> ./$PACKAGE_NAME-$pid.log
    echo "================================================================================" >> ./$PACKAGE_NAME-$pid.log
    sleep 30m
done

