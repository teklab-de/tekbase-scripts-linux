#! /bin/bash

# TekLabs TekBase
# Copyright since 2005 TekLab
# Christian Frankenstein
# Website: teklab.de
#          teklab.net

VAR_A=$1
VAR_B=$2
VAR_C=$3

if [ "$VAR_A" = "" ]; then
    ./tekbase
fi

LOGF=$(date +"%Y_%m")
LOGP=$(pwd)

if [ ! -d logs ]; then
    mkdir logs
    chmod 0777 logs
fi
if [ ! -d restart ]; then
    mkdir restart
    chmod 0777 restart
fi

if [ ! -f "logs/$LOGF.txt" ]; then
    echo "***TekBASE Script Log***" >> $LOGP/logs/$LOGF.txt
    chmod 0666 $LOGP/logs/$LOGF.txt
fi


if [ "$VAR_A" = "info" ]; then
    memall=$(free -k | grep -i mem | awk '{print $2,$3,$4,$6,$7}')
    memt=$(echo "$memall" | awk '{print $1}')
    memu=$(echo "$memall" | awk '{print $2}')
    memf=$(echo "$memall" | awk '{print $3}')
    memb=$(echo "$memall" | awk '{print $4}')
    memc=$(echo "$memall" | awk '{print $5}')
    let memb=$memb+$memc
    let memf=$memf+$memb
    let memu=$memu-$memb		
    memall="$memt $memu $memf"    
    swapall=$(free -k | grep -i swap | awk '{print $2,$3,$4}')
    traffic=$(vnstat -m | grep -i "$VAR_B" | awk '{print $9,$10}')
    runtime=$(uptime | awk '{print $3,$4}')
    hddall=$(df -h | grep /dev/[hsmx][abcdefgv] | awk '{print $1,$2,$3,$4}')
    echo "$memall%TD%$swapall%TD%$traffic%TD%$runtime%TD%$hddall"
fi

if [ "$VAR_A" = "list" ]; then
    cd /etc/init.d
    echo "$(ls -l | awk '{print $1"%TD%"$NF"%TEND%"}')"
fi

if [ "$VAR_A" = "process" ]; then
    kill -9 $VAR_B
    check=$(ps -p $VAR_B | grep -v "PID TTY")
    if [ ! -n "$check" ]; then
	echo "$(date) - Process $VAR_B was killed" >> $LOGP/logs/$LOGF.txt
	echo "ID1"
    else
	echo "$(date) - Process $VAR_B cant be killed" >> $LOGP/logs/$LOGF.txt
	echo "ID2"
    fi
fi

if [ "$VAR_A" = "psaux" ]; then
    echo "$(ps aux --sort pid | grep -v "ps aux" | grep -v "awk {printf" | grep -v "tekbase" | grep -v "perl -e use MIME::Base64" | awk '{printf($1"%TD%")
    printf($2"%TD%")
    printf($3"%TD%")
    printf($4"%TD%")
    for (i=11;i<=NF;i++) {
	printf("%s ", $i);
    }
    print("%TEND%")}')"
fi

if [ "$VAR_A" = "service" ]; then
    cd /etc/init.d
    if [ -f $VAR_B ]; then
	./$VAR_B $VAR_C
	echo "ID1"
    fi
fi

if [ "$VAR_A" = "traffic" ]; then
    traffic=$(vnstat -m | grep -i "$VAR_B" | awk '{print $9,$10}')
    traffictwo=$(vnstat -m | grep -i "$VAR_C" | awk '{print $9,$10}')
    echo "$traffic-$traffictwo"
fi

if [ "$VAR_A" = "reboot" ]; then
    reboot
fi

if [ "$VAR_A" = "shutdown" ]; then
    shutdown -h now
fi

exit 0
