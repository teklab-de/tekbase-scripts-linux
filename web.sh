#! /bin/bash

# TekLabs TekBase
# Copyright since 2005 TekLab
# Christian Frankenstein
# Website: teklab.de
#          teklab.net

VAR_A=$1
VAR_C=$3
VAR_D=$4
VAR_E=$5

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


if [ "$VAR_A" = "dbcreate" ]; then
    if [ -f /etc/mysql/settings.ini ]; then
        mysqlpwd=$(grep -i password /etc/mysql/settings.ini | awk '{print $2}')
        mysqlusr=$(grep -i login /etc/mysql/settings.ini | awk '{print $2}')

        Q1="CREATE DATABASE IF NOT EXISTS $VAR_C;"
        Q2="GRANT ALL PRIVILEGES ON $VAR_C.* TO '$VAR_D'@'%' IDENTIFIED BY '$VAR_E' WITH GRANT OPTION;"
        Q3="FLUSH PRIVILEGES;"
        SQL="${Q1}${Q2}${Q3}"

        mysql --user=$mysqlusr --password=$mysqlpwd -e "$SQL"
        echo "ID1"
    else
        echo "ID2"
    fi
fi

if [ "$VAR_A" = "dbdelete" ]; then
    if [ -f /etc/mysql/settings.ini ]; then
        mysqlpwd=$(grep -i password /etc/mysql/settings.ini | awk '{print $2}')
        mysqlusr=$(grep -i login /etc/mysql/settings.ini | awk '{print $2}')

        Q1="DROP DATABASE $VAR_C;"
        Q2="DROP USER $VAR_D@'%';"	
        Q3="FLUSH PRIVILEGES;"
        SQL="${Q1}${Q2}"

        mysql --user=$mysqlusr --password=$mysqlpwd -e "$SQL"
        echo "ID1"
    else
        echo "ID2"			
    fi
fi

if [ "$VAR_A" = "dbrename" ]; then
    if [ -f /etc/mysql/settings.ini ]; then
        mysqlpwd=$(grep -i password /etc/mysql/settings.ini | awk '{print $2}')
        mysqlusr=$(grep -i login /etc/mysql/settings.ini | awk '{print $2}')

        mysqldump --user=$mysqlusr --password=$mysqlpwd $VAR_C > $VAR_C.sql
        Q1="CREATE DATABASE IF NOT EXISTS $VAR_D;"
        SQL="${Q1}"
		
        mysql --user=$mysqlusr --password=$mysqlpwd -e "$SQL"
        mysql --user=$mysqlusr --password=$mysqlpwd $VAR_D < $VAR_C.sql		
				
        Q1="GRANT ALL PRIVILEGES ON $VAR_D.* TO '$VAR_E'@'%';"
        Q2="REVOKE ALL PRIVILEGES ON $VAR_C.* FROM '$VAR_E'@'%';"
        Q3="DROP DATABASE $VAR_C;"
        Q4="FLUSH PRIVILEGES;"
        SQL="${Q1}${Q2}${Q3}${Q4}"

        mysql --user=$mysqlusr --password=$mysqlpwd -e "$SQL"
        rm $VAR_C.sql
        echo "ID1"
    else
        echo "ID2"			
    fi
fi

if [ "$VAR_A" = "dbpasswd" ]; then
    if [ -f /etc/mysql/settings.ini ]; then
        mysqlpwd=$(grep -i password /etc/mysql/settings.ini | awk '{print $2}')
        mysqlusr=$(grep -i login /etc/mysql/settings.ini | awk '{print $2}')

        Q1="UPDATE mysql.user SET Password=PASSWORD('$VAR_D') WHERE User='$VAR_C';"
        Q2="FLUSH PRIVILEGES;"
        SQL="${Q1}${Q2}"

        mysql --user=$mysqlusr --password=$mysqlpwd -e "$SQL"
        echo "ID1"
    else
        echo "ID2"			
    fi
fi

if [ "$VAR_A" = "activate" ]; then
    if [ -f includes/sites/$VAR_B.conf ]; then
        cp includes/sites/$VAR_B.conf /etc/apache2/sites-enabled
	echo "ID1"
    else
        echo "ID2"			
    fi
fi

if [ "$VAR_A" = "deactivate" ]; then
    if [ -f /etc/apache2/sites-enabled/$VAR_B.conf ]; then
        rm /etc/apache2/sites-enabled/$VAR_B.conf
	echo "ID1"
    else
        echo "ID2"			
    fi
fi

if [ "$VAR_A" = "delete" ]; then
    if [ -f includes/sites/$VAR_B.conf ]; then
        rm includes/sites/$VAR_B.conf
	if [ -f /etc/apache2/sites-enabled/$VAR_B.conf ]; then
            rm /etc/apache2/sites-enabled/$VAR_B.conf
	fi
	echo "ID1"
    else
	echo "ID1"
    else
        echo "ID2"			
    fi
fi

if [ "$VAR_A" = "apache" ]; then
    /etc/init.d/apache2 reload
    echo "ID1"
fi

exit 0
