#! /bin/bash

# TekLabs TekBase
# Copyright 2005-2015 TekLab
# Christian Frankenstein
# Website: www.teklab.de
#          www.teklab.us

VAR_A=$1
VAR_B=$2
VAR_C=$3
VAR_D=$4
VAR_E=$5

if [ "$VAR_A" = "" ]; then
    LOGY=`date +"%Y"`
    clear
fi

LOGF=`date +"%m_%Y"`
LOGC=`date +"%m_%Y-%H_%M_%S"`
LOGP=`pwd`

mysqlpwd=`cat hlstats.ini | grep -i password | awk '{print $2}'`
mysqlusr=`cat hlstats.ini | grep -i login | awk '{print $2}'`
wwwpath=`cat hlstats.ini | grep -i www | awk '{print $2}'`

if [ ! -f "logs/$LOGF.txt" ]; then
   echo "***TekBASE Script Log***" >> $LOGP/logs/$LOGF.txt
   chmod 0666 $LOGP/logs/$LOGF.txt
fi

case "$VAR_A" in
    # HlStats installieren
    1)
    if [ -d /home/$VAR_B ] ; then 
	cd /home
	rm -r $VAR_B
    fi
    cd /home
    mkdir $VAR_B
    cd /home/skripte/hlstats
    cp -r * /home/$VAR_B
    cd /home/$VAR_B/sql
    Q1="CREATE DATABASE IF NOT EXISTS $VAR_B;"
    Q2="GRANT ALL PRIVILEGES ON $VAR_B.* TO '$VAR_B'@'localhost' IDENTIFIED BY '$VAR_C' WITH GRANT OPTION;"
    Q3="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}${Q3}"
    sqlcreate=`mysql --user=$mysqlusr --password=$mysqlpwd -e "$SQL"`
    sqlinsert=`mysql --user=$VAR_B --password=$VAR_C $VAR_B < install.sql`
    sqlupdate=`mysql --user=$VAR_B --password=$VAR_C $VAR_B -e "UPDATE hlstats_Users SET password='$VAR_E' WHERE username='admin' OR acclevel='100'"`
    cd ..
    cd scripts
    sed -e '/DBUsername/Ic\DBUsername "'$VAR_B'"' hlstats.conf > backup.conf
    sed -e '/DBPassword/Ic\DBPassword "'$VAR_C'"' backup.conf > hlstats.conf
    sed -e '/DBName/Ic\DBName "'$VAR_B'"' hlstats.conf > backup.conf
    sed -e '/Port/Ic\Port '$VAR_D'' backup.conf > hlstats.conf
    rm backup.conf
    cd ..
    echo "$VAR_C" > passwd.ini
    cd web
    rm -r updater
    sed -e '/define("DB_NAME/Ic\define("DB_NAME", "'$VAR_B'");' config.php > backup.php
    sed -e '/define("DB_USER/Ic\define("DB_USER", "'$VAR_B'");' backup.php > config.php
    sed -e '/define("DB_PASS/Ic\define("DB_PASS", "'$VAR_C'");' config.php > backup.php
    rm config.php
    mv backup.php config.php
    cd ..
    cp -r web $wwwpath/$VAR_B
    useradd -g users -p `perl -e 'print crypt("'$VAR_C'","Sa")'` -s /bin/bash -m $VAR_B -d /var/www/$VAR_B
    chown -R $VAR_B:users /var/www/$VAR_B
    cd /home/$VAR_B/scripts
    ./run_hlstats start 1 $VAR_D &
    echo "ID1"
    ;;
    # HlStats restarten
    2)
    cd /home/$VAR_B/scripts
    ./run_hlstats stop $VAR_C &
    rm -r logs
    ./run_hlstats start 1 $VAR_C &
    echo "ID1"
    ;;
    # HlStats stoppen
    3)
    cd /home/$VAR_B/scripts
    ./run_hlstats stop $VAR_C &
    echo "ID1"
    ;;
    # FTP Passwort
    4)
    usermod -p `perl -e 'print crypt("'$VAR_C'","Sa")'` $VAR_B
    echo "ID1"
    ;;
    # Admin Passwort
    5)
    passwd=`cat /home/$VAR_B/passwd.ini`
    sqlupdate=`mysql --user=$VAR_B --password=$passwd $VAR_B -e "UPDATE hlstats_Users SET password='$VAR_C' WHERE username='admin' OR acclevel='100'"`
    echo "ID1"
    ;;
    # HlStats löschen
    6)
    cd /home/$VAR_B/scripts
    ./run_hlstats stop $VAR_C &
    sqldeleteusr=`mysql --user=$mysqlusr --password=$mysqlpwd -e "DROP USER $VAR_B@localhost;"`
    sqldeletedb=`mysql --user=$mysqlusr --password=$mysqlpwd -e "DROP DATABASE $VAR_B;"`
    cd $wwwpath
    rm -r $VAR_B
    cd /home
    rm -r $VAR_B
    echo "ID1"
    # Awards
    ;;
    7)
    filelist=`find /home -maxdepth 1 -type d -printf "%f\n"`
    for LINE in $filelist
    do
	if echo "$LINE" | grep -i "hls_" > /dev/null 2>&1 ; then
	    cd /home/$LINE/scripts
	    ./hlstats-awards.pl
	fi
    done
    ;;	
esac
exit 0