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
VAR_J=${10}

if [ "$VAR_A" = "" ]; then
    ./tekbase
fi

LOGDAY=$(date +"%Y-%m-%d")

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

if [ "$VAR_A" = "start" ]; then
    if [ -f $LOGP/restart/$VAR_B-$VAR_E-$VAR_C ]; then
	rm $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    fi
    echo "#! /bin/bash" >> $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    echo "if [ -f /home/$VAR_B/streams/$VAR_D/$VAR_E.pid ]; then" >> $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    echo "pid=\`cat /home/$VAR_B/streams/$VAR_D/$VAR_E.pid\`" >> $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    echo "check=\`ps -p \$pid | grep -i "$VAR_E"\`" >> $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    echo "fi" >> $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    echo "if [ ! -n \"\$check\" ]; then" >> $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    echo "cd $LOGP;sudo -u $VAR_B ./streams 'start' '$VAR_B' '$VAR_C' '$VAR_D' '$VAR_E' '$VAR_F' '$VAR_G' '$VAR_H' '$VAR_I' '$VAR_J'" >> $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    echo "fi" >> $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    echo "exit 0" >> $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    chmod 0755 $LOGP/restart/$VAR_B-$VAR_E-$VAR_C

    cd /home/$VAR_B/streams/$VAR_D

    if [ "$VAR_E" = "ices" ]; then
	if [ -f ices.pid ]; then
	    check=$(ps -p $(grep -i "ices" ices.pid))
	    if [ -n "$check" ]; then
	        kill -9 $(cat ices.pid)
	    fi
	    check=$(ps -p $(grep -i "ices" ices.pid))
	    rm ices.pid
        fi
	if [ -f ices2.pid ]; then
	    check=$(ps -p $(grep -i "ices2" ices2.pid))
	    if [ -n "$check" ]; then
	        kill -9 $(cat ices2.pid)
	    fi
	    check=$(ps -p $(grep -i "ices2" ices2.pid))
	    rm ices2.pid
        fi
    else
	if [ -f $VAR_E.pid ]; then
	    check=$(ps -p $(grep -i "$VAR_E" $VAR_E.pid))
	    if [ -n "$check" ]; then
		kill -9 $(cat $VAR_E.pid)
	    fi
	    check=$(ps -p $(grep -i "$VAR_E" $VAR_E.pid))
	    rm $VAR_E.pid
	fi
    fi

    if [ ! -n "$check" ]; then
	if [ "$VAR_E" = "sc_serv" ]; then   
	    sed -i '/PortBase=/Ic\PortBase='$VAR_G'' sc_serv.conf
	    sed -i '/MaxUser=/Ic\MaxUser='$VAR_H'' sc_serv.conf
	fi
	if [ "$VAR_E" = "sc_trans" ]; then
	    let VAR_K=$VAR_J+5
	    sed -i '/ServerPort=/Ic\ServerPort='$VAR_G'' sc_trans.conf
	    sed -i '/AdminPort=/Ic\AdminPort='$VAR_I'' sc_trans.conf
	    sed -i '/DjPort=/Ic\DjPort='$VAR_J'' sc_trans.conf
	    sed -i '/DjPort2=/Ic\DjPort2='$VAR_K'' sc_trans.conf
	    sed -i '/Bitrate=/Ic\Bitrate='$VAR_H'' sc_trans.conf
	    sed -i '/bitrate_1=/Ic\bitrate_1='$VAR_H'' sc_trans.conf
	    sed -i '/serverport_1=/Ic\serverport_1='$VAR_G'' sc_trans.conf
	    sed -i '/^Port=/Ic\Port='$VAR_G'' sc_trans.conf
	fi
	if [ "$VAR_E" = "icecast" ]; then
	    sed -i '/<port>/Ic\<port>'$VAR_G'</port>' icecast.xml
	    sed -i '/<clients>/Ic\<clients>'$VAR_H'</clients>' icecast.xml
	fi
	if [ "$VAR_E" = "ices" ]; then
	    sed -i '/<port>/Ic\<port>'$VAR_G'</port>' ices.xml
	    sed -i '/<bitrate>/Ic\<bitrate>'$VAR_H'</bitrate>' ices.xml
	fi
	if [ "$VAR_E" = "ices2" ]; then
	    sed -i '/<port>/Ic\<port>'$VAR_G'</port>' ices2.xml
	    sed -i '/<nominal-bitrate>/Ic\<nominal-bitrate>'$VAR_H'</nominal-bitrate>' ices2.xml
	fi

	$VAR_F &
	echo $! > $VAR_E.pid

	if [ -f $VAR_E.pid ]; then
            if [ -f sc_serv_$VAR_G.pid ]; then
                rm sc_serv_$VAR_G.pid
            fi
	    echo "$(date) - Stream /home/$VAR_B/streams/$VAR_D was started ($VAR_F)" >> $LOGP/logs/$LOGF.txt
	    echo "ID1"
	else
	    echo "$(date) - Stream /home/$VAR_B/streams/$VAR_D cant be started ($VAR_F)" >> $LOGP/logs/$LOGF.txt
	    echo "ID2"
	fi
    else
	echo "$(date) - Stream /home/$VAR_B/streams/$VAR_D cant be stopped and restarted ($VAR_F)" >> $LOGP/logs/$LOGF.txt
	echo "ID3"
    fi
fi

if [ "$VAR_A" = "stop" ]; then
    if [ -f $LOGP/restart/$VAR_B-$VAR_E-$VAR_C ]; then
        rm $LOGP/restart/$VAR_B-$VAR_E-$VAR_C
    fi

    cd /home/$VAR_B/streams/$VAR_D
    if [ "$VAR_E" = "ices" ]; then
	if [ -f ices.pid ]; then
	    check=$(ps -p $(grep -i "ices" ices.pid))
	    if [ -n "$check" ]; then
	        kill -9 $(cat ices.pid)
	    fi
	    check=$(ps -p $(grep -i "ices" ices.pid))
	    rm ices.pid
        fi
	if [ -f ices2.pid ]; then
	    check=$(ps -p $(grep -i "ices2" ices2.pid))
	    if [ -n "$check" ]; then
	        kill -9 $(cat ices2.pid)
	    fi
	    check=$(ps -p $(grep -i "ices2" ices2.pid))
        fi
    else
	if [ -f $VAR_E.pid ]; then
	    check=$(ps -p $(grep -i "$VAR_E" $VAR_E.pid))
	    if [ -n "$check" ]; then
	        kill -9 $(cat $VAR_E.pid)
	    fi
	    check=$(ps -p $(grep -i "$VAR_E" $VAR_E.pid))
	    rm $VAR_E.pid
        fi
    fi

    if [ ! -n "$check" ]; then
	echo "$(date) - Stream /home/$VAR_B/streams/$VAR_D was stopped" >> $LOGP/logs/$LOGF.txt
	echo "ID1"
    else
	echo "$(date) - Stream /home/$VAR_B/streams/$VAR_D cant be stopped" >> $LOGP/logs/$LOGF.txt
	echo "ID2"
    fi
fi

if [ "$VAR_A" = "rewrite" ]; then
    cd /home/$VAR_B/streams/$VAR_D
    if [ "$VAR_C" = "ic" ]; then
	if [ "$VAR_F" != "" ]; then
	    sed -i '/'$VAR_F'/Ic\'$VAR_G'' $VAR_E
	    check=$(grep -i "$VAR_G" VAR_E)
	    if [ ! -n "$check" ]; then
		echo "" >> $VAR_E
		echo "$VAR_G" >> $VAR_E
	    fi
	fi
    else
	if [ "$VAR_F" != "" ]; then
	    sed -i '/'$VAR_F'/Ic\'$VAR_G'' $VAR_E
	    check=$(grep -i "$VAR_G" VAR_E)
	    if [ ! -n "$check" ]; then
		echo "" >> $VAR_E
		echo "$VAR_G" >> $VAR_E
	    fi
	fi
    fi
fi

if [ "$VAR_A" = "update" ]; then
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i "$VAR_B$VAR_D-X")
    if [ ! -n "$startchk" ]; then
	screen -A -m -d -S b$VAR_B$VAR_D-X ./streams updaterun "$VAR_B" "$VAR_C" "$VAR_D"
    	echo "ID1"
    else
        echo "$(date) - Update of /home/$VAR_B/streams/$VAR_D cant be installed" >> $LOGP/logs/$LOGF.txt
        echo "ID2"
    fi
fi

if [ "$VAR_A" = "updaterun" ]; then
    sleep 2
    cd /home/$VAR_B/streams/$VAR_D
    comlist=$(echo "$VAR_E" | sed -e 's/;/\n/g')
    while read LINE
    do
    	if [ "$LINE" != "" ]; then
	    $LINE
	fi
    done < <(echo "$comlist")
    echo "$(date) - Update of /home/$VAR_B/streams/$VAR_D was installed" >> $LOGP/logs/$LOGF.txt
fi

if [ "$VAR_A" = "playlist" ]; then
    cd /home/$VAR_B/streams/$VAR_D
    if [ "$VAR_C" = "ic" ]; then
	find /home/$VAR_B/streams/$VAR_D/mp3/ -type f -name "*.mp3" > /home/$VAR_B/streams/$VAR_D/mp3_playlist.lst
	if [ -f mp3_playlist.lst ]; then
	    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/mp3_playlist.lst was created" >> $LOGP/logs/$LOGF.txt
	else
	    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/mp3_playlist.lst cant be created" >> $LOGP/logs/$LOGF.txt
	fi
	find /home/$VAR_B/streams/$VAR_C/ogg/ -type f -name "*.ogg" > /home/$VAR_B/streams/$VAR_C/ogg_playlist.lst
	if [ -f ogg_playlist.lst ]; then
	    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_C/ogg_playlist.lst was created" >> $LOGP/logs/$LOGF.txt
	else
	    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_C/ogg_playlist.lst cant be created" >> $LOGP/logs/$LOGF.txt
	fi
    else
	if [ -f playlist.plo ]; then
	    echo "#Mode=Basic" > /home/$VAR_B/streams/$VAR_D/playlist.plo
	    find /home/$VAR_B/streams/$VAR_D/videos/ -type f -name "*.nsv" >> /home/$VAR_B/streams/$VAR_D/playlist.plo
	    if [ -f playlist.plo ]; then
		echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/playlist.plo was created" >> $LOGP/logs/$LOGF.txt
	    else
		echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/playlist.plo cant be created" >> $LOGP/logs/$LOGF.txt
	    fi
	fi
	if [ "$VAR_E" != "" ]; then
	    if [ "$VAR_F" != "" ]; then
		cd songs
	        mkdir -p $VAR_F
   		cd /home/$VAR_B/streams/$VAR_D
	    	find /home/$VAR_B/streams/$VAR_D/songs/$VAR_F/ -maxdepth 1 -type f \( -name "*.mp3" -o -name "*.acc" \) > /home/$VAR_B/streams/$VAR_D/playlists/$VAR_E.lst
		if [ -f $VAR_E.lst ]; then
		    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/playlists/$VAR_E.lst was created" >> $LOGP/logs/$LOGF.txt
		else
		    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/playlists/$VAR_E.lst cant be created" >> $LOGP/logs/$LOGF.txt
		fi
	    else
	    	find /home/$VAR_B/streams/$VAR_D/songs/ -maxdepth 1 -type f -name "*.mp3" > /home/$VAR_B/streams/$VAR_D/playlists/$VAR_E.lst
		if [ -f $VAR_F/$VAR_E.lst ]; then
		    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/playlists/$VAR_E.lst was created" >> $LOGP/logs/$LOGF.txt
		else
		    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/playlists/$VAR_E.lst cant be created" >> $LOGP/logs/$LOGF.txt
		fi
	    fi
	else
	    if [ -f playlist.lst ]; then
		find /home/$VAR_B/streams/$VAR_D/songs/ -type f -name "*.mp3" > /home/$VAR_B/streams/$VAR_D/playlist.lst
		if [ -f playlist.lst ]; then
		    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/playlist.lst was created" >> $LOGP/logs/$LOGF.txt
	    	else
		    echo "$(date) - Playlist /home/$VAR_B/streams/$VAR_D/playlist.lst cant be created" >> $LOGP/logs/$LOGF.txt
		fi
    	    fi
	fi
    fi
fi

if [ "$VAR_A" = "content" ]; then
    cd /home/$VAR_B/streams/$VAR_D
    check=$(cat $VAR_E)
    for LINE in $check
    do
    	echo "$LINE%TEND%"
    done
fi

if [ "$VAR_A" = "streamstats" ]; then
    check=$(php -f php/stream_check.php)
    chkbitrate=$(echo "$check" | awk '{print $1}')
    chkslots=$(echo "$check" | awk '{print $2}')
    chktitle=$(echo "$check" | awk '{for (i=3;i<=NF;i++) {
	printf("%s ", $i);
    }}')
    cd /home/$VAR_B/streams/$VAR_C/stats
    checktwo=$(grep -i "$chktitle" $LOGF.txt | awk '{print $3, $4}')
    if [ "$checktwo" != "" ]; then
	listeners=$(echo "$checktwo" | awk '{print $2}')
	if [ "$listeners" == "" ]; then
	    listeners="0"
	fi
    	if [ $listeners -lt $chkslots ]; then
	    sed -i '/'$chktitle'/Ic\'$LOGDAY' | Listeners '$chkslots' | Title '$chktitle'' $LOGF.txt
    	fi
    else
	echo "$LOGDAY | Listeners $chkslots | Title $chktitle" >> $LOGF.txt
    fi
fi

if [ "$VAR_A" = "status" ]; then
    check=$(ps aux | grep -v grep | grep -i screen | grep -i "$VAR_E$VAR_B$VAR_D-X")
    if [ ! -n "$check" ]; then
	echo "ID1"
    else
	echo "ID2"
    fi
fi


exit 0
