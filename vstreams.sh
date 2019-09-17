#! /bin/bash

# TekLabs TekBase
# Copyright since 2005 TekLab
# Christian Frankenstein
# Website: teklab.de
#          teklab.net

VAR_A=$1
VAR_B=$2
VAR_C=$3
VAR_D=$4
VAR_E=$5
VAR_F=$6
VAR_G=$7

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

#VAR_A typ
#VAR_B USER
#VAR_C ID
#VAR_D PATH
#VAR_E APP
#VAR_F STARTSCRIPT
#VAR_G PORT

if [ "$VAR_A" = "start" ]; then
    if [ -f $LOGP/restart/$VAR_B-vstreams-$VAR_C ]; then
	rm $LOGP/restart/$VAR_B-vstreams-$VAR_C
    fi
    echo "#! /bin/bash" >> $LOGP/restart/$VAR_B-vstreams-$VAR_C
    echo "check=\`ps aux | grep -v grep | grep -i screen | grep -i \"vstreams$VAR_C-X\"\`" >> $LOGP/restart/$VAR_B-server-$VAR_C
    echo "if [ ! -n \"\$check\" ]; then" >> $LOGP/restart/$VAR_B-vstreams-$VAR_C
    echo "cd $LOGP;sudo -u $VAR_B ./vstreams 'start' '$VAR_B' '$VAR_C' '$VAR_D' '$VAR_E' '$VAR_F' '$VAR_G'" >> $LOGP/restart/$VAR_B-vstreams-$VAR_C
    echo "fi" >> $LOGP/restart/$VAR_B-vstreams-$VAR_C
    echo "exit 0" >> $LOGP/restart/$VAR_B-vstreams-$VAR_C
    chmod 0755 $LOGP/restart/$VAR_B-vstreams-$VAR_C

    cd /home/$VAR_B/vstreams/$VAR_D

    kill -9 $(ps aux | grep -v grep | grep -i screen | grep -i "$VAR_F$VAR_B-X" | awk '{print $2}')
    check=$(ps aux | grep -v grep | grep -i screen | grep -i "$VAR_F$VAR_B-X")
    screen -wipe
    if [ ! -n "$check" ]; then
	let httpp=$VAR_G+40
	let httpsp=$VAR_G+30
	let rtmptp=$VAR_G+20
	let mrtmpp=$VAR_G+10
	let proxyp=$VAR_G+1
	cd conf
	sed -e '/http.port=/Ic\http.port='$httpp'' red5.properties > red5.backup
	sed -e '/rtmp.port=/Ic\rtmp.port='$VAR_G'' red5.backup > red5.properties
	sed -e '/rtmpt.port=/Ic\rtmpt.port='$rtmptp'' red5.properties > red5.backup
	sed -e '/mrtmp.port=/Ic\mrtmpp.port='$mrtmpp'' red5.backup > red5.properties
	sed -e '/proxy.source_port=/Ic\proxy.source_port='$proxyp'' red5.properties > red5.backup
	sed -e '/proxy.destination_port=/Ic\proxy.destination_port='$VAR_G'' red5.backup > red5.properties
	sed -e '/https.port=/Ic\https.port='$httpsp'' red5.properties > red5.backup
	rm red5.properties
	mv red5.backup red5.properties
	cd /home/$VAR_C/vstreams/$VAR_D
    
    	screen -A -m -d -S vstreams$VAR_C-X $VAR_F
	check=$(ps aux | grep -v grep | grep -i screen | grep -i "vstreams$VAR_C-X")

	if [ -n "$check" ]; then
	    echo "$(date) - Stream /home/$VAR_B/vstreams/$VAR_D was started ($VAR_F)" >> $LOGP/logs/$LOGF.txt
	    echo "ID1"
	else
	    echo "$(date) - Stream /home/$VAR_B/vstreams/$VAR_D cant be started ($VAR_F)" >> $LOGP/logs/$LOGF.txt
	    echo "ID2"
	fi
    else
	echo "$(date) - Stream /home/$VAR_B/vstreams/$VAR_D cant be stopped and restarted ($VAR_F)" >> $LOGP/logs/$LOGF.txt
	echo "ID3"
    fi
fi

if [ "$VAR_A" = "stop" ]; then
    if [ -f $LOGP/restart/$VAR_B-vstreams-$VAR_C ]; then
	rm $LOGP/restart/$VAR_B-vstreams-$VAR_C
    fi

    kill -9 $(ps aux | grep -v grep | grep -i screen | grep -i "vstreams$VAR_C-X" | awk '{print $2}')
    check=$(ps aux | grep -v grep | grep -i screen | grep -i "vstreams$VAR_C-X")
    screen -wipe

    if [ ! -n "$check" ]; then
	echo "$(date) - Stream /home/$VAR_B/vstreams/$VAR_D was stopped" >> $LOGP/logs/$LOGF.txt
	echo "ID1"
    else
	echo "$(date) - Stream /home/$VAR_B/vstreams/$VAR_D cant be stopped" >> $LOGP/logs/$LOGF.txt
	echo "ID2"
    fi
fi


if [ "$VAR_A" = "content" ]; then
    cd /home/$VAR_B/vstreams/$VAR_D
    check=$(cat $VAR_E)
    for LINE in $check
    do
    	echo "$LINE%TEND%"
    done
fi


exit 0
