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
VAR_H=$8
VAR_I=$9

if [ "$VAR_A" = "" ]; then
    ./tekbase
fi

LOGF=$(date +"%m_%Y")
LOGC=$(date +"%m_%Y-%H_%M_%S")
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

if [ -f settings.ini ]; then
    vzconf=$(grep -i vzconf settings.ini | awk '{print $2}')
    if [ ! -n "$vzconf" ]; then
    	vzconf="vz/conf"
    fi
fi


if [ "$VAR_A" = "install" ]; then
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    if [ ! -n "$startchk" ]; then
	screen -A -m -d -S v$VAR_A$VAR_B-X ./vserver installrun "$VAR_B" "$VAR_C" "$VAR_D" "$VAR_E" "$VAR_F" "$VAR_G" "$VAR_H" "$VAR_I"
	check=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    fi
    if [ ! -n "$check" ]; then
	runcheck=$(vzctl status $VAR_B | grep -i running)
	if [ -n "$runcheck" ]; then
	    echo "ID3"
	else
	    echo "ID2"
	fi
    else
	echo "ID1"
    fi
fi

if [ "$VAR_A" = "installrun" ]; then
    if [ "$VAR_E" = "delete" ]; then
	check=$(vzctl status $VAR_B | grep -i running)
	if [ -n "$check" ]; then
	    vzctl stop $VAR_B
	    if [ -f "/var/lib/vz/root/$VAR_B" ]; then
                umount -l "/var/lib/vz/root/$VAR_B"
            fi
	fi
	sleep 5
	vzctl destroy $VAR_B
	sleep 10
	if [ ! -f /etc/$vzconf/$VAR_B.conf ]; then
	    echo "$(date) - VServer $VAR_B was deleted" >> $LOGP/logs/$LOGF.txt
	else
	    echo "$(date) - VServer $VAR_B cant be deleted" >> $LOGP/logs/$LOGF.txt
	fi
	cd /etc/$vzconf
	rm $VAR_B.conf.destroyed
    fi
    if [ ! -f /etc/$vzconf/$VAR_B.conf ]; then
        cd $LOGP
	mkdir -p cache 	
    	cd /vz/template/cache
    	if [ ! -f $VAR_C.tar.gz ]; then
            mkdir $LOGC
            cd $LOGC
            wget $VAR_G/$VAR_C.tar.gz
            mv $VAR_C.tar.gz /vz/template/cache/$VAR_C.tar.gz
            cd $LOGP/cache
            rm -r $LOGC
    	else
            if [ -f $VAR_B$VAR_C.md5 ]; then
                rm $VAR_B$VAR_C.md5
            fi
            wget -O $VAR_B$VAR_C.md5 $VAR_G/$VAR_C.tar.gz.md5
            if [ -f $VAR_B$VAR_C.md5 ]; then
                dowmd5=$(cat $VAR_B$VAR_C.md5 | awk '{print $1}')
                rm $VAR_B$VAR_C.md5
            else
                dowmd5="ID2"
            fi
            chkmd5=$(md5sum $VAR_C.tar.gz | awk '{print $1}')
            if [ "$dowmd5" != "$chkmd5" ]; then
                mkdir $LOGC
                cd $LOGC
                wget $VAR_G/$VAR_C.tar.gz
                dowmd5=$(md5sum $VAR_C.tar.gz | awk '{print $1}')
                if [ "$dowmd5" != "$chkmd5" ]; then
                    mv $VAR_C.tar.gz /vz/template/cache/$VAR_C.tar.gz
                fi
                cd $LOGP/cache
                rm -r $LOGC
            fi
    	fi
    	if [ ! -f $VAR_C.tar.gz ]; then
            echo "$(date) - Image $VAR_C.tar.gz cant be downloaded" >> $LOGP/logs/$LOGF.txt
        else
            echo "$(date) - Image $VAR_C.tar.gz was downloaded" >> $LOGP/logs/$LOGF.txt
    	fi	
        vzctl create $VAR_B --ostemplate $VAR_C
        if [ ! -f /etc/$vzconf/$VAR_B.conf ]; then
            echo "$(date) - VServer $VAR_B cant be created" >> $LOGP/logs/$LOGF.txt
        else
            echo "$(date) - VServer $VAR_B was created" >> $LOGP/logs/$LOGF.txt
	    VAR_A="changerun"
	    VAR_E="install"
        fi
    else
	echo "$(date) - VServer $VAR_B cant be created" >> $LOGP/logs/$LOGF.txt
    fi
fi

if [ "$VAR_A" = "statuscheck" ]; then
    checka=$(ps aux | grep -v grep | grep -i vbackup$VAR_B-X)
    checkb=$(ps aux | grep -v grep | grep -i vrestore$VAR_B-X)
    if [ ! -n "$checka" ] && [ ! -n "$checkb" ]; then
	echo "ID1"
    else
	echo "ID2"
    fi
fi

if [ "$VAR_A" = "delete" ]; then
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    if [ ! -n "$startchk" ]; then
	screen -A -m -d -S v$VAR_A$VAR_B-X ./vserver deleterun "$VAR_B" "$VAR_C" "$VAR_D" "$VAR_E" "$VAR_F" "$VAR_G" "$VAR_H" "$VAR_I"
	check=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    fi
    if [ ! -n "$check" ]; then
	if [ -f /etc/$vzconf/$VAR_B.conf ]; then
	    echo "ID3"
	else
	    echo "ID2"
	fi
    else
	echo "ID1"
    fi
fi

if [ "$VAR_A" = "deleterun" ]; then
    check=$(vzctl status $VAR_B | grep -i running)
    if [ -n "$check" ]; then
	vzctl stop $VAR_B
	if [ -f "/var/lib/vz/root/$VAR_B" ]; then
            umount -l "/var/lib/vz/root/$VAR_B"
        fi
    fi
    sleep 5
    vzctl destroy $VAR_B
    sleep 10
    if [ ! -f /etc/$vzconf/$VAR_B.conf ]; then
	echo "$(date) - VServer $VAR_B was deleted" >> $LOGP/logs/$LOGF.txt
    else
	echo "$(date) - VServer $VAR_B cant be deleted" >> $LOGP/logs/$LOGF.txt
    fi
    cd /etc/$vzconf
    rm $VAR_B.conf.destroyed
    if [ -d /usr/vz/$VAR_B ]; then
	cd /usr/vz
	rm -r $VAR_B
    fi
fi


if [ "$VAR_A" = "start" ]; then
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    if [ ! -n "$startchk" ]; then
	screen -A -m -d -S v$VAR_A$VAR_B-X ./vserver startrun "$VAR_B" "$VAR_C" "$VAR_D" "$VAR_E" "$VAR_F" "$VAR_G" "$VAR_H" "$VAR_I"
	check=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    fi
    if [ ! -n "$check" ]; then
	vzctl status $VAR_B | grep -i running
	if [ -n "$runcheck" ]; then
	    echo "ID3"
	else
	    echo "ID2"
	fi
    else
	echo "ID1"
    fi
fi

if [ "$VAR_A" = "startrun" ]; then
	check=$(vzctl status $VAR_B | grep -i running)
	if [ -n "$check" ]; then
	    vzctl stop $VAR_B
	    if [ -f "/var/lib/vz/root/$VAR_B" ]; then
                umount -l "/var/lib/vz/root/$VAR_B"
            fi
	fi
	sleep 2
	vzctl start $VAR_B
	runcheck=$(vzctl status $VAR_B | grep -i running)
	if [ ! -n "$runcheck" ]; then
	    echo "$(date) - VServer $VAR_B cant be started" >> $LOGP/logs/$LOGF.txt
	else
	    echo "$(date) - VServer $VAR_B was started" >> $LOGP/logs/$LOGF.txt
	fi
    fi

if [ "$VAR_A" = "stop" ]; then
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    if [ ! -n "$startchk" ]; then
	screen -A -m -d -S v$VAR_A$VAR_B-X ./vserver stoprun "$VAR_B" "$VAR_C" "$VAR_D" "$VAR_E" "$VAR_F" "$VAR_G" "$VAR_H" "$VAR_I"
	check=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    fi
    if [ ! -n "$check" ]; then
	runcheck=$(vzctl status $VAR_B | grep -i running)
	if [ ! -n "$runcheck" ]; then
	    echo "ID3"
	else
	    echo "ID2"
	fi
    else
	echo "ID1"
    fi
fi

if [ "$VAR_A" = "stoprun" ]; then
    vzctl stop $VAR_B
    if [ -f "/var/lib/vz/root/$VAR_B" ]; then
        umount -l "/var/lib/vz/root/$VAR_B"
    fi
    sleep 2
    check=$(vzctl status $VAR_B | grep -i running)
    if [ ! -n "$check" ]; then
	echo "$(date) - VServer $VAR_B was stopped" >> $LOGP/logs/$LOGF.txt
    else
	echo "$(date) - VServer $VAR_B cant be stopped" >> $LOGP/logs/$LOGF.txt
    fi
fi

if [ "$VAR_A" = "info" ]; then
    check=$(vzctl status $VAR_B | grep -i running)
    if [ -n "$check" ]; then
	memall=$(vzctl exec $VAR_B free | tail -n 2 | head -1 | awk '{print $2}')
	memused=$(vzctl exec $VAR_B free | tail -n 2 | head -1 | awk '{print $3}')
	hddused=$(vzlist -o diskspace,diskspace.h $VAR_B | tail -1l | awk '{print $1,$2}')
	runtime=$(vzctl exec $VAR_B uptime | awk '{print $3,$4}')
	echo "$memall $memused%TD%$hddused%TD%$runtime"
    fi
fi

if [ "$VAR_A" = "list" ]; then
    check=$(vzctl status $VAR_B | grep -i running)
    if [ -n "$check" ]; then
	vzctl exec $VAR_B ls -l /etc/init.d | awk '{print $1"%TD%"$NF"%TEND%"}'
    fi
fi

if [ "$VAR_A" = "process" ]; then
    vzctl exec $VAR_B kill -9 $VAR_C
    check=$(vzctl exec $VAR_B ps -p $VAR_C | grep -v "PID TTY")
    if [ ! -n "$check" ]; then
	echo "$(date) - VServer $VAR_B process $VAR_C was killed" >> $LOGF/logs/$LOGF.txt
	echo "ID1"
    else
	echo "$(date) - VServer $VAR_B process $VAR_C cant be killed" >> $LOGP/logs/$LOGF.txt
	echo "ID2"
    fi
fi

if [ "$VAR_A" = "psaux" ]; then
    check=$(vzctl status $VAR_B | grep -i running)
    if [ -n "$check" ]; then
	vzctl exec $VAR_B ps aux --sort pid | grep -v "ps aux" | grep -v "awk {printf" | grep -v "tekbase" | grep -v "perl -e use MIME::Base64" | awk '{printf($1"%TD%")
	printf($2"%TD%")
	printf($3"%TD%")
	printf($4"%TD%")
	for (i=11;i<=NF;i++) {
	    printf("%s ", $i);
    	}
    	print("%TEND%")}'
    fi
fi

if [ "$VAR_A" = "service" ]; then
    check=$(vzctl status $VAR_B | grep -i running)
    if [ -n "$check" ]; then
	runcheck=$(vzctl exec $VAR_B find /etc/init.d/$VAR_C)
	if [ -n "$runcheck" ]; then
	    vzctl exec $VAR_B /etc/init.d/$VAR_C $VAR_D
	    echo "ID1"
	fi
    fi
fi

if [ "$VAR_A" = "backuplist" ]; then
    if [ -d /usr/vz/$VAR_B ]; then
        cd /usr/vz/$VAR_B
        check=$(find -name "*.tgz" -o -name "*.lzo" -type f)
	output=""
        for LINE in $check
        do
            output=$(echo "$output$LINE%TEND%")
        done
    fi
    echo "$output"
fi

if [ "$VAR_A" = "backup" ]; then
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    if [ ! -n "$startchk" ]; then
	screen -A -m -d -S v$VAR_A$VAR_B-X ./vserver backuprun "$VAR_B" "$VAR_C" "$VAR_D" "$VAR_E" "$VAR_F" "$VAR_G" "$VAR_H" "$VAR_I"
	check=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    fi
    if [ ! -n "$check" ]; then
	runcheck=$(vzctl status $VAR_B | grep -i running)
	if [ -n "$runcheck" ]; then
	    echo "ID3"
	else
	    echo "ID2"
	fi
    else
	echo "ID1"
    fi
fi

if [ "$VAR_A" = "backuprun" ]; then
    check=$(vzctl status $VAR_B | grep -i running)
    if [ ! -n "$check" ]; then
	vzctl start $VAR_B
    fi
    mkdir -p /usr/vz
    mkdir -p /usr/vz/$VAR_B
    vzdump --compress gzip --maxfiles $VAR_C --bwlimit 30720 --dumpdir /usr/vz/$VAR_B $VAR_B
    cd /usr/vz/$VAR_B
    checkfile=$(find vzdump*)
    if [ -n "$checkfile" ]; then
        echo "$(date) - VServer $VAR_B backup was created" >> $LOGP/logs/$LOGF.txt
    else
        echo "$(date) - VServer $VAR_B backup cant be created" >> $LOGP/logs/$LOGF.txt
    fi
fi

if [ "$VAR_A" = "remove" ]; then
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    if [ ! -n "$startchk" ]; then
	screen -A -m -d -S v$VAR_A$VAR_B-X ./vserver removerun "$VAR_B" "$VAR_C" "$VAR_D" "$VAR_E" "$VAR_F" "$VAR_G" "$VAR_H" "$VAR_I"
	check=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    fi
    if [ ! -n "$check" ]; then
   	if [ -f /usr/vz/$VAR_B/$VAR_C ]; then
	    echo "ID2"
	else
	    echo "ID3"
	fi
    else
	echo "ID1"
    fi
fi

if [ "$VAR_A" = "removerun" ]; then
   sleep 2
   if [ -f /usr/vz/$VAR_B/$VAR_C ]; then
	cd /usr/vz/$VAR_B
	file=$(echo "$VAR_C" | awk --field-separator=. '{print $1}')
	mv $VAR_C $file.old
	rm $file.log
	rm $file.old
	echo "$(date) - VServer $VAR_B backup $VAR_C was deleted" >> $LOGP/logs/$LOGF.txt
   else
	echo "$(date) - VServer $VAR_B backup $VAR_C cant be founded or was already deleted" >> $LOGP/logs/$LOGF.txt
   fi
fi

if [ "$VAR_A" = "restore" ]; then
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    if [ ! -n "$startchk" ]; then
	screen -A -m -d -S v$VAR_A$VAR_B-X ./vserver restorerun "$VAR_B" "$VAR_C" "$VAR_D" "$VAR_E" "$VAR_F" "$VAR_G" "$VAR_H" "$VAR_I"
	check=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    fi
    if [ ! -n "$check" ]; then
   	if [ -f /usr/vz/$VAR_B/$VAR_C ]; then
	    echo "ID2"
	else
	    echo "ID3"
	fi
    else
	echo "ID1"
    fi
fi

if [ "$VAR_A" = "restorerun" ]; then
    check=$(vzctl status $VAR_B | grep -i running)
    if [ ! -f /usr/vz/$VAR_B/$VAR_C ]; then
	echo "$(date) - VServer $VAR_B backup $VAR_C cant be founded" >> $LOGP/logs/$LOGF.txt
    else
	if [ -n "$check" ]; then
	    vzctl stop $VAR_B
	    if [ -f "/var/lib/vz/root/$VAR_B" ]; then
                umount -l "/var/lib/vz/root/$VAR_B"
            fi
	    sleep 5
	    vzctl destroy $VAR_B
	    sleep 10
	fi
	vzrestore /usr/vz/$VAR_B/$VAR_C $VAR_B
	vzctl start $VAR_B
	runcheck=$(vzctl status $VAR_B | grep -i running)
	if [ ! -n "$runcheck" ]; then
	    echo "$(date) - VServer $VAR_B backup $VAR_C cant be restored" >> $LOGP/logs/$LOGF.txt
	else
	    echo "$(date) - VServer $VAR_B backup $VAR_C was restored" >> $LOGP/logs/$LOGF.txt
	fi
    fi
fi

if [ "$VAR_A" = "change" ]; then
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i v$VAR_A$VAR_B-X)
    if [ ! -n "$startchk" ]; then
	screen -A -m -d -S v$VAR_A$VAR_B-X ./vserver changerun "$VAR_B" "$VAR_C" "$VAR_D"
    fi
    echo "ID1"
fi

if [ "$VAR_A" = "changerun" ]; then
    if [ -f /etc/$vzconf/$VAR_B.conf ]; then
        if [ "$VAR_F" = "1" ]; then
	    vzctl set $VAR_B --devnodes net/tun:rw --save
	    vzctl set $VAR_B --devices c:10:200:rw --save
	    vzctl set $VAR_B --capability net_admin:on --save
	    vzctl exec $VAR_B mkdir -p /dev/net
	    vzctl exec $VAR_B mknod /dev/net/tun c 10 200
	    vzctl exec $VAR_B chmod 600 /dev/net/tun
	    echo "$(date) - VServer $VAR_B Tun & Tap was activated" >> $LOGP/logs/$LOGF.txt
        else
	    echo "$(date) - VServer $VAR_B Tun & Tap was not activated" >> $LOGP/logs/$LOGF.txt
        fi
	if [ -f $LOGP/cache/vsettings_$VAR_B.lst ]; then
	    while read LINE
	    do
	    	if [ "$LINE" != "" ]; then
		    vzctl set $VAR_B $LINE --save
		fi
	    done < $LOGP/cache/vsettings_$VAR_B.lst
	    rm $LOGP/cache/vsettings_$VAR_B.lst
	fi
	echo "$(date) - VServer $VAR_B config was changed" >> $LOGP/logs/$LOGF.txt
    else
	echo "$(date) - VServer $VAR_B config cant be changed" >> $LOGP/logs/$LOGF.txt
    fi
    VAR_A="ipadd"
fi

if [ "$VAR_A" = "ipadd" ]; then
    if [ -f /etc/$vzconf/$VAR_B.conf ]; then
	if [ -f $LOGP/cache/vipadd_$VAR_B.lst ]; then
	    while read LINE
	    do
	    	if [ "$LINE" != "" ]; then
		    vzctl set $VAR_B --ipadd $LINE --save
		fi
	    done < $LOGP/cache/vipadd_$VAR_B.lst
	    rm $LOGP/cache/vipadd_$VAR_B.lst
	fi
	echo "$(date) - VServer $VAR_B new IP was added" >> $LOGP/logs/$LOGF.txt
    else
	echo "$(date) - VServer $VAR_B new IP cant be added" >> $LOGP/logs/$LOGF.txt
    fi
    VAR_A="ipdel"
fi

if [ "$VAR_A" = "ipdel" ]; then
    if [ -f /etc/$vzconf/$VAR_B.conf ]; then
	if [ -f $LOGP/cache/vipdel_$VAR_B.lst ]; then
	    while read LINE
	    do
	    	if [ "$LINE" != "" ]; then
		    vzctl set $VAR_B --ipdel $LINE --save
		fi
	    done < $LOGP/cache/vipdel_$VAR_B.lst
	    rm $LOGP/cache/vipdel_$VAR_B.lst
	fi
	echo "$(date) - VServer $VAR_B IP was removed" >> $LOGP/logs/$LOGF.txt
    else
	echo "$(date) - VServer $VAR_B IP cant be removed" >> $LOGP/logs/$LOGF.txt
    fi
    if [ "$VAR_E" = "install" ]; then
	VAR_A="rootpw"
	VAR_C=$VAR_D
    fi
fi

if [ "$VAR_A" = "online" ]; then
    check=$(vzctl status $VAR_B | grep -i running)
    if [ -n "$check" ]; then
	echo "ID1"
    else
	echo "ID2"
    fi
fi

if [ "$VAR_A" = "settings" ]; then
    echo "$VAR_C" > $LOGP/cache/vsettings_$VAR_B.lst
    if [ "$VAR_D" != "" ]; then
	echo "$VAR_D" > $LOGP/cache/vipadd_$VAR_B.lst
    fi
    if [ "$VAR_E" != "" ]; then
	echo "$VAR_E" > $LOGP/cache/vipdel_$VAR_B.lst
    fi
fi

if [ "$VAR_A" = "rootpw" ]; then
    check=$(vzctl status $VAR_B | grep -i running)
    if [ ! -n "$check" ]; then
	vzctl start $VAR_B
    fi
    vzctl set $VAR_B --userpasswd root:$VAR_C
    echo "ID1"
fi


exit 0
