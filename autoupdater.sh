#! /bin/bash

# TekLabs TekBase
# Copyright since 2005 TekLab
# Christian Frankenstein
# Website: teklab.de
#          teklab.net

LOGF=$(date +"%Y_%m")
LOGP=$(pwd)

if [ ! -d $LOGP/logs ]; then
    mkdir logs
fi

if [ ! -f "$LOGP/logs/$LOGF.txt" ]; then
    echo "***TekBASE Script Log***" >> $LOGP/logs/$LOGF.txt
    chmod 0666 $LOGP/logs/$LOGF.txt
fi

chkgit=$(which git)
if [ "$chkgit" = "" ]; then
    check=$(grep -i "CentOS" /etc/*-release)
    if [ -n "$check" ]; then
        yum install git -y
    fi
    
    check=$(grep -i "Debian" /etc/*-release)
    if [ -n "$check" -a "$os_install" = "" ]; then
        apt-get install git -y
    fi
    
    check=$(grep -i "Fedora" /etc/*-release)
    if [ -n "$check" -a "$os_install" = "" ]; then
        yum install git -y
    fi
    
    check=$(grep -i "Red Hat" /etc/*-release)
    if [ -n "$check" ] && [ "$os_install" = "" ]; then
        yum install git -y
    fi
    
    check=$(grep -i "SUSE" /etc/*-release)
    if [ -n "$check" ] && [ "$os_install" = "" ]; then
        zypper install git -y
    fi
    
    check=$(grep -i "Ubuntu" /etc/*-release)
    if [[ -n "$check" ] && [ "$os_install" = "" ]] || [[ -n "$check" ] && [ "$os_name" = "Debian" ]]; then
        apt-get install git -y
    fi
fi

if [ ! -d ".git" ]; then
    git clone https://github.com/teklab-de/tekbase-scripts-linux.git
    cd tekbase-scripts-linux
    mv * ../
    mv .git ../
    cd ..
    rm -R tekbase-scripts-linux
    newversion=2
    version=1
else
    version=$(git rev-parse HEAD)

    git fetch
    git reset --hard origin/master

    newversion=$(git rev-parse HEAD)
fi


if [ "$version" != "$newversion" ]; then
    echo "$(date) - The scripts have been updated" >> $LOGP/logs/$LOGF.txt
else
    echo "$(date) - There are no script updates available" >> $LOGP/logs/$LOGF.txt
fi


##############################
# TekBASE 8.x compatibility  #
##############################
for FILE in $(find ./*.sh)
do
    cp $FILE ${FILE%.sh}
done


exit 0
