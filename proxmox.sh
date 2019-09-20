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

#VAR_C TYP KVM / LXC
if [ "$VAR_A" = "" ]; then
    ./tekbase
fi

PVEVERSION=$(pveversion | cut -d"/" -f2 | cut -d"." -f1)
  
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

if [ "$VAR_A" = "install" ]; then
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
            sleep 10
	          if [ ! -f /etc/pve/qemu-server/$VAR_B.conf ]; then
	              echo "$(date) - KVM VServer $VAR_B was deleted" >> $LOGP/logs/$LOGF.txt
	          else
	              echo "$(date) - KVM VServer $VAR_B cant be deleted" >> $LOGP/logs/$LOGF.txt
	          fi
            cd /etc/pve/qemu-server
	          rm $VAR_B.conf.destroyed
        fi
        if [ "$VAR_C" == "lxc" ]; then
            check=$(pct list | grep -i "stopped" | grep -i $VAR_B | awk '{print $2}')
            if [ -n "$check" ]; then
	              pct stop $VAR_B
	          fi
            sleep 5
            pct destroy $VAR_B
            sleep 10
	          if [ ! -f /etc/pve/lxc/$VAR_B.conf ]; then
	              echo "$(date) - LXC VServer $VAR_B was deleted" >> $LOGP/logs/$LOGF.txt
	          else
	              echo "$(date) - LXC VServer $VAR_B cant be deleted" >> $LOGP/logs/$LOGF.txt
	          fi
            cd /etc/pve/lxc
	          rm $VAR_B.conf.destroyed
        fi
    fi
    
fi


exit 0
