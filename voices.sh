#! /bin/bash

# TekLabs TekBase
# Copyright since 2005 TekLab
# Christian Frankenstein
# Website: www.teklab.de
#          www.teklab.us

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
    if [ -f $LOGP/restart/$VAR_B-voice-$VAR_C ]; then
	rm $LOGP/restart/$VAR_B-voice-$VAR_C
    fi
    echo "#! /bin/bash" >> $LOGP/restart/$VAR_B-voice-$VAR_C
    if [ "$VAR_F" = "ventrilo" ]; then
	echo "check=\`ps aux | grep -v grep | grep -i screen | grep -i \"voice$VAR_C-X\"\`" >> $LOGP/restart/$VAR_B-voice-$VAR_C
    fi
    if [ "$VAR_F" = "mumble" ]; then
	echo "if [ -f /home/$VAR_B/voice/$VAR_C/murmur.pid ]; then" >> $LOGP/restart/$VAR_B-voice-$VAR_C
	echo "check=\`ps -p \`cat /home/$VAR_B/voice/$VAR_C/murmurd.pid\`\`" >> $LOGP/restart/$VAR_B-voice-$VAR_C
	echo "fi" >> $LOGP/restart/$VAR_B-voice-$VAR_C
    fi
    echo "if [ ! -n \"\$check\" ]; then" >> $LOGP/restart/$VAR_B-voice-$VAR_C
    echo "cd $LOGP;sudo -u $VAR_B ./voices 'start' '$VAR_B' '$VAR_C' '$VAR_D' '$VAR_E' '$VAR_F' '$VAR_G' '$VAR_H' '$VAR_I' '$VAR_J'" >> $LOGP/restart/$VAR_B-voice-$VAR_C
    echo "fi" >> $LOGP/restart/$VAR_B-voice-$VAR_C
    echo "exit 0" >> $LOGP/restart/$VAR_B-voice-$VAR_C
    chmod 0755 $LOGP/restart/$VAR_B-voice-$VAR_C

    cd /home/$VAR_B/voice/$VAR_D

    if [ "$VAR_E" = "mumble" ]; then
	if [ -f murmurd.pid ]; then
	    check=$(ps -p $(grep -i "mumble" murmurd.pid))
	    if [ -n "$check" ]; then
		kill -9 $(cat murmurd.pid)
	    fi
	    check=$(ps -p $(grep -i "mumble" murmurd.pid))
	    rm murmurd.pid
	fi
	if [ ! -n "$check" ]; then
	    sed -i '/port=/Ic\port='$VAR_F'' mumble-server.ini
	    sed -i '/users=/Ic\users='$VAR_G'' mumble-server.ini
	    sed -i '/host=/Ic\host='$VAR_H'' mumble-server.ini
	    sed -i '/bandwidth=/Ic\bandwidth='$VAR_I'' mumble-server.ini

	    ./mumble-server -ini mumble-server.ini
	    sleep 2

	    if [ -f murmurd.pid ]; then
		echo "$(date) - Voice /home/$VAR_B/voice/$VAR_D was started (./mumble-server -ini mumble-server.ini)" >> $LOGP/logs/$LOGF.txt
		echo "ID1"
	    else
		echo "$(date) - Voice /home/$VAR_B/voice/$VAR_D cant be started (./mumble-server -ini mumble-server.ini)" >> $LOGP/logs/$LOGF.txt
		echo "ID2"
	    fi
	else
	    echo "$(date) - Voice /home/$VAR_B/voice/$VAR_D cant be stopped and restarted (./mumble-server -ini mumble-server.ini)" >> $LOGP/logs/$LOGF.txt
	    echo "ID3"
	fi
    fi
    if [ "$VAR_E" = "ventrilo" ]; then
	kill -9 $(ps aux | grep -v grep | grep -i screen | grep -i "voice$VAR_C-X" | awk '{print $2}')
	check=$(ps aux | grep -v grep | grep -i screen | grep -i "voice$VAR_C-X")
	screen -wipe
	if [ ! -n "$check" ]; then
	    sed -i '/Port=/Ic\Port='$VAR_F'' ventrilo_srv.ini
	    sed -i '/MaxClients=/Ic\MaxClients='$VAR_G'' ventrilo_srv.ini

	    screen -A -m -d -S voice$VAR_B-X ./ventrilo_srv
	    check=$(ps aux | grep -v grep | grep -i screen | grep -i "voice$VAR_C-X")

	    if [ -n "$check" ]; then
		echo "$(date) - Voice /home/$VAR_B/voice/$VAR_D was started (./ventrilo_srv)" >> $LOGP/logs/$LOGF.txt
		echo "ID1"
	    else
		echo "$(date) - Voice /home/$VAR_B/voice/$VAR_D cant be started (./ventrilo_srv)" >> $LOGP/logs/$LOGF.txt
		echo "ID2"
	    fi
	else
	    echo "$(date) - Voice /home/$VAR_B/voice/$VAR_D cant be stopped and restarted (./ventrilo_srv)" >> $LOGP/logs/$LOGF.txt
	    echo "ID3"
	fi
    fi
fi

if [ "$VAR_A" = "stop" ]; then
    if [ -f $LOGP/restart/$VAR_B-voice-$VAR_C ]; then
	rm $LOGP/restart/$VAR_B-voice-$VAR_C
    fi

    cd /home/$VAR_B/voice/$VAR_D

    if [ "$VAR_E" = "mumble" ]; then
	if [ -f murmurd.pid ]; then
	    check=$(ps -p $(grep -i "mumble" murmurd.pid))
	    if [ -n "$check" ]; then
	        kill -9 $(cat murmurd.pid)
	    fi
	    check=$(ps -p $(grep -i "mumble" murmurd.pid))
	    rm murmurd.pid
        fi
    fi
    if [ "$VAR_E" = "ventrilo" ]; then
	if [ "$VAR_C" = "vstreams" ]; then
	    kill -9 $(ps aux | grep -v grep | grep -i screen | grep -i "voice$VAR_C-X" | awk '{print $2}')
	    check=$(ps aux | grep -v grep | grep -i screen | grep -i "voice$VAR_C-X")
	    screen -wipe
	fi
    fi

    if [ ! -n "$check" ]; then
	echo "$(date) - Voice /home/$VAR_B/voice/$VAR_D was stopped" >> $LOGP/logs/$LOGF.txt
	echo "ID1"
    else
	echo "$(date) - Voice /home/$VAR_B/voice/$VAR_D cant be stopped" >> $LOGP/logs/$LOGF.txt
	echo "ID2"
    fi
fi

if [ "$VAR_A" = "muserlist" ]; then
    cd /home/$VAR_B/voice/$VAR_D
    userlist=$(sqlite3 -html mumble-server.sqlite "SELECT user_id, name FROM users ORDER BY name ASC")
    echo "$userlist"
fi

if [ "$VAR_A" = "museradd" ]; then
    cd /home/$VAR_B/voice/$VAR_D
    password=$(echo -n $VAR_F | sha1sum | awk '{print $1}')
    usercount=$(sqlite3 mumble-server.sqlite "SELECT user_id FROM users ORDER BY user_id DESC LIMIT 1")
    let newid=$usercount+1
    sqlite3 mumble-server.sqlite "INSERT INTO users (server_id, user_id, name, pw) VALUES (1, \"$newid\", \"$VAR_E\", \"$password\")"
    echo "ID1"
fi

if [ "$VAR_A" = "musermod" ]; then
    cd /home/$VAR_B/voice/$VAR_D
    password=$(echo -n $VAR_E | sha1sum |awk '{print $1}')
    sqlite3 mumble-server.sqlite "UPDATE users SET pw=\"$password\" WHERE user_id=\"$VAR_F\""
    echo "ID1"
fi

if [ "$VAR_A" = "muserdel" ]; then
    cd /home/$VAR_B/voice/$VAR_D
    sqlite3 mumble-server.sqlite "DELETE FROM users WHERE user_id=\"$VAR_E\""
    echo "ID1"
fi

if [ "$VAR_A" = "tuserlist" ]; then
    cd /home/user-webi/$VAR_D
    serverid=$(sqlite server.dbs "SELECT i_server_id FROM ts2_servers WHERE i_server_udpport=\"$VAR_F\"")
    userlist=$(sqlite -html server.dbs "SELECT i_client_id, s_client_name, b_client_privilege_serveradmin FROM ts2_clients WHERE i_client_server_id=\"$serverid\" ORDER BY s_client_name ASC")
    userlist=$(echo ${userlist//&/_})
    tscounter=0
    tsnewline=""
    for LINE in $userlist
    do
	if [ "$tscounter" != "4" ]; then
    	    tsnewline="$tsnewline$LINE"
	    let tscounter=$tscounter+1
	fi
	if [ "$tscounter" = "4" ]; then
	    echo "$tsnewline%TEK%"
	    tsnewline=""
	    tscounter=0
	fi
    done
fi

if [ "$VAR_A" = "tuseradd" ]; then
    cd /home/user-webi/$VAR_D
    adddate="$(date +"%d%m%Y%H%M%S")00000"
    serverid=$(sqlite server.dbs "SELECT i_server_id FROM ts2_servers WHERE i_server_udpport=\"$VAR_F\"")
    sqlite server.dbs "INSERT INTO ts2_clients (i_client_server_id, b_client_privilege_serveradmin, s_client_name, s_client_password, dt_client_created) VALUES (\"$serverid\", \"$VAR_I\", \"$VAR_G\", \"$VAR_H\", \"$adddate\")"
    echo "ID1"
fi

if [ "$VAR_A" = "tusermod" ]; then
    cd /home/user-webi/$VAR_D
    serverid=$(sqlite server.dbs "SELECT i_server_id FROM ts2_servers WHERE i_server_udpport=\"$VAR_F\"")
    sqlite server.dbs "UPDATE ts2_clients SET b_client_privilege_serveradmin=\"$VAR_I\", s_client_password=\"$VAR_H\" WHERE i_client_id=\"$VAR_G\" AND i_client_server_id=\"$serverid\""
    echo "ID1"
fi

if [ "$VAR_A" = "tuserdel" ]; then
    cd /home/user-webi/$VAR_D
    serverid=$(sqlite server.dbs "SELECT i_server_id FROM ts2_servers WHERE i_server_udpport=\"$VAR_F\"")
    sqlite server.dbs "DELETE FROM ts2_clients WHERE i_client_id=\"$VAR_G\" AND i_client_server_id=\"$serverid\""
    echo "ID1"
fi

if [ "$VAR_A" = "tserverchg" ]; then
    cd /home/user-webi/$VAR_D
    sqlite server.dbs "UPDATE ts2_servers SET i_server_maxusers=\"$VAR_H\", i_server_udpport=\"$VAR_G\" WHERE i_server_udpport=\"$VAR_F\""
    echo "ID1"
fi

if [ "$VAR_A" = "tservermod" ]; then
    cd /home/user-webi/$VAR_D
    sqlite server.dbs "UPDATE ts2_servers SET s_server_name=\"$VAR_C\", s_server_welcomemessage=\"$VAR_E\", s_server_password=\"$VAR_G\", b_server_clan_server=\"$VAR_H\", s_server_webposturl=\"$VAR_I\", s_server_weblinkurl=\"$VAR_J\" WHERE i_server_udpport=\"$VAR_F\""
    echo "ID1"
fi

if [ "$VAR_A" = "tserverdel" ]; then
    cd /home/user-webi/$VAR_D
    serverid=$(sqlite server.dbs "SELECT i_server_id FROM ts2_servers WHERE i_server_udpport=\"$VAR_F\"")
    sqlite server.dbs "DELETE FROM ts2_server_privileges WHERE i_sp_server_id=\"$serverid\""
    sqlite server.dbs "DELETE FROM ts2_channels WHERE i_channel_server_id=\"$serverid\""
    sqlite server.dbs "DELETE FROM ts2_channel_privileges WHERE i_cp_server_id=\"$serverid\""
    sqlite server.dbs "DELETE FROM ts2_clients WHERE i_client_server_id=\"$serverid\""
    sqlite server.dbs "DELETE FROM ts2_bans WHERE i_ban_server_id=\"$serverid\""
    sqlite server.dbs "DELETE FROM ts2_servers WHERE i_server_id=\"$serverid\""
    echo "ID1"
fi

if [ "$VAR_A" = "tserverread" ]; then
    cd /home/user-webi/$VAR_D
    serverid=$(sqlite -separator %TD% server.dbs "SELECT s_server_name, s_server_welcomemessage, s_server_password, b_server_clan_server, s_server_webposturl, s_server_weblinkurl FROM ts2_servers WHERE i_server_udpport=\"$VAR_F\"")
    echo "$serverid"
fi

if [ "$VAR_A" = "content" ]; then
    cd /home/$VAR_B/voice/$VAR_D
    check=$(cat $VAR_E)
    for LINE in $check
    do
    	echo "$LINE%TEND%"
    done
fi

if [ "$VAR_A" = "tsdns" ]; then
  cd /home/tsdns
  if [ -f tsdns_settings.ini ]; then
      sed -i '/'$VAR_B'/d' tsdns_settings.ini
  fi
  if [ "$VAR_C" != "" ]; then
      echo -e "\n$VAR_C=$VAR_B" >> tsdns_settings.ini
  fi
  check=$(ps aux | grep -v grep | grep -i "tsdnsserver_linux")
  if [ ! -n "$check" ]; then
      if [ -f tsdnsserver_linux_86 ]; then
          ./tsdnsserver_linux_x86 &
      fi
      if [ -f tsdnsserver_linux_amd64 ]; then
          ./tsdnsserver_linux_amd64 &
      fi
  else
      if [ -f tsdnsserver_linux_x86 ]; then
          ./tsdnsserver_linux_x86 --update
      fi
      if [ -f tsdnsserver_linux_amd64 ]; then
          ./tsdnsserver_linux_amd64 --update
      fi
  fi
  echo "ID1"
fi


exit 0
