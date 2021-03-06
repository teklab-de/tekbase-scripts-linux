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
  
LOGF=$(date +"%Y_%m")
LOGC=$(date +"%Y_%m-%H_%M_%S")
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

#PVEVERSION=$(pveversion | cut -d"/" -f2 | cut -d"." -f1)
if [ "$VAR_C" == "kvm" ]; then
    pvefolder="/etc/pve/qemu-server"
    pvetype="KVM"
    pveimagefolder="/var/lib/vz/template/iso"
    pveext="iso"
fi
if [ "$VAR_C" == "lxc" ]; then
    pvefolder="/etc/pve/lxc"
    pvetype="LXC"
    pveimagefolder="/var/lib/vz/template/cache"
    pveext="tar.gz"
fi


if [ "$VAR_A" = "install" ]; then
    # VAR_B=ID, VAR_C=Type, VAR_D=Image, VAR_G=Imageserver
    startchk=$(ps aux | grep -v grep | grep -i screen | grep -i p$VAR_A$VAR_B-X)
    if [ ! -n "$startchk" ]; then
        screen -A -m -d -S v$VAR_A$VAR_B-X ./proxmox installrun "$VAR_B" "$VAR_C" "$VAR_D" "$VAR_E" "$VAR_F" "$VAR_G" "$VAR_H" "$VAR_I"
        check=$(ps aux | grep -v grep | grep -i screen | grep -i p$VAR_A$VAR_B-X)
    fi
    if [ ! -n "$check" ]; then
        if [ "$VAR_C" == "kvm" ]; then
            runcheck=$(qm status $VAR_B | grep -i "running")
        fi
        if [ "$VAR_C" == "lxc" ]; then
            runcheck=$(pct list | grep -v "stopped" | grep -i $VAR_B | awk '{print $2}')
        fi  
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
        if [ "$VAR_C" == "kvm" ]; then
            check=$(qm status $VAR_B | grep -v "running")
            if [ -n "$check" ]; then
                qm stop $VAR_B
            fi
            sleep 5
            qm destroy $VAR_B
	fi
        if [ "$VAR_C" == "lxc" ]; then
            check=$(pct list | grep -i "stopped" | grep -i $VAR_B | awk '{print $2}')
            if [ -n "$check" ]; then
                pct stop $VAR_B
            fi
            sleep 5
            pct destroy $VAR_B
        fi        
        sleep 10	
	if [ ! -f $pvefolder/$VAR_B.conf ]; then
                echo "$(date) - $pvetype VServer $VAR_B was deleted" >> $LOGP/logs/$LOGF.txt
            else
                echo "$(date) - $pvetype VServer $VAR_B cant be deleted" >> $LOGP/logs/$LOGF.txt
            fi
            cd $pvefolder
            rm $VAR_B.conf.destroyed
        fi
    fi
  
    if [ ! -f $pvefolder/$VAR_B.conf ]; then
        cd $pveimagefolder
    	if [ ! -f $VAR_D.$pveext ]; then
            mkdir $LOGC
            cd $LOGC
            wget $VAR_G/$VAR_D.$pveext
            mv $VAR_D.$pveext $pveimagefolder/$VAR_D.$pveext
            cd ..
            rm -r $LOGC
    	else
            if [ -f $VAR_C-$VAR_D.md5 ]; then
                rm $VAR_C-$VAR_D.md5
            fi
            wget -O $VAR_C$-VAR_D.md5 $VAR_G/$VAR_D.$pveext.md5
            if [ -f $VAR_C$-VAR_D.md5 ]; then
                dowmd5=$(cat $VAR_C-$VAR_D.md5 | awk '{print $1}')
                rm $VAR_C-$VAR_D.md5
            else
                dowmd5="ID2"
            fi
            chkmd5=$(md5sum $VAR_D.$pveext | awk '{print $1}')
            if [ "$dowmd5" != "$chkmd5" ]; then
                mkdir $LOGC
                cd $LOGC
                wget $VAR_G/$VAR_D.$pveext
                dowmd5=$(md5sum $VAR_D.$pveext | awk '{print $1}')
                if [ "$dowmd5" != "$chkmd5" ]; then
                    mv $VAR_D.$pveext $pveimagefolder/$VAR_D.$pveext
                fi
	        cd ..
                rm -r $LOGC
	    fi
        fi
    	if [ ! -f $VAR_D.$pveext ]; then
            echo "$(date) - $pvetype Image $VAR_D.$pveext cant be downloaded" >> $LOGP/logs/$LOGF.txt
        else
            echo "$(date) - $pvetype Image $VAR_D.$pveext was downloaded" >> $LOGP/logs/$LOGF.txt
    	fi	
        if [ "$VAR_C" == "kvm" ]; then
	    qm create $VAR_B "$VAR_F"
        fi
        if [ "$VAR_C" == "lxc" ]; then
	    pct create $VAR_B "$VAR_F"
        fi
        if [ ! -f $pvefolder/$VAR_B.conf ]; then
            echo "$(date) - $pvetype VServer $VAR_B cant be created" >> $LOGP/logs/$LOGF.txt
        else
            echo "$(date) - $pvetype VServer $VAR_B was created" >> $LOGP/logs/$LOGF.txt
	    VAR_A="changerun"
	    VAR_E="install"
        fi
    else
	echo "$(date) - $pvetype VServer $VAR_B cant be created" >> $LOGP/logs/$LOGF.txt
    fi
fi

if [ "$VAR_A" = "statuscheck" ]; then
    checka=$(ps aux | grep -v grep | grep -i pbackup$VAR_B-X)
    checkb=$(ps aux | grep -v grep | grep -i prestore$VAR_B-X)
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
	if [ -f $pvefolder/$VAR_B.conf ]; then
	    echo "ID3"
	else
	    echo "ID2"
	fi
    else
	echo "ID1"
    fi
fi

if [ "$VAR_A" = "deleterun" ]; then
    # break
    if [ "$VAR_C" == "kvm" ]; then
        #
    fi
    if [ "$VAR_C" == "lxc" ]; then
        #
    fi
fi

exit 0
