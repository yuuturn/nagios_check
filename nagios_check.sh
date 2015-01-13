#!/bin/bash

## base info
DIR=~/
HOSTALIAS=remothost.example.com
HOSTADDRESS=192.0.2.10
SERVICEDESC=nagios
LONGDATETIME=`LANG=en_US.UTF-8 date`

## nagios stat check
CHECK_ARG=`/usr/lib64/nagios/plugins/check_nrpe -H ${HOSTADDRESS} -c check_nagios_procs`
CHECK_STAT=`/bin/echo ${CHECK_ARG} | /bin/awk '{print $2}' | /usr/bin/tr -d ":"`

## mail
critical_mail(){
    NOTIFICATIONTYPE=PROBLEM
    SERVICESTATE=critical
    SERVICEOUTPUT=${CHECK_ARG}
    FROM=from@example.com
    TO=to@example.com
    SUBJECT="[Nagios] ${NOTIFICATIONTYPE} Service Alert ${HOSTALIAS} ${SERVICEDESC} is ${SERVICESTATE}"
    BODY="Nagios on example.net \n\nNotification Type ${NOTIFICATIONTYPE}\n\nService ${SERVICEDESC}\nHost ${HOSTALIAS}\nAddress ${HOSTADDRESS}\nState ${SERVICESTATE}\n\nDate/Time ${LONGDATETIME}\n\nAdditional Info\n\n${CHECK_ARG}\n\nthis mail is send by `uname -n` $0"

    /usr/bin/printf "%b${BODY}" | /bin/mail -s "${SUBJECT}" -r ${FROM} ${TO}
}

recovery_mail(){
    NOTIFICATIONTYPE=RECOVERY
    SERVICESTATE=ok
    SERVICEOUTPUT=${CHECK_ARG}
    FROM=from@example.com
    TO=to@example.com
    SUBJECT="[Nagios] ${NOTIFICATIONTYPE} Service Alert ${HOSTALIAS} ${SERVICEDESC} is ${SERVICESTATE}"
    BODY="Nagios on example.net \n\nNotification Type ${NOTIFICATIONTYPE}\n\nService ${SERVICEDESC}\nHost ${HOSTALIAS}\nAddress ${HOSTADDRESS}\nState ${SERVICESTATE}\n\nDate/Time ${LONGDATETIME}\n\nAdditional Info\n\n${CHECK_ARG}\n\nthis mail is send by `uname -n` $0"

    /usr/bin/printf "%b${BODY}" | /bin/mail -s "${SUBJECT}" -r ${FROM} ${TO}
}

## if $CHECK_STAT is NG
if [ ${CHECK_STAT} != "OK" ]; then
    ## check previous nagios status
    if [ -e /root/bin/.nagios_check_NG ];then
        ## notification interval
        ERORRO_COUNT=`/usr/bin/wc -l ${DIR}.nagios_check_NG | /bin/awk '{print $1}'`
        /bin/echo ${LONGDATETIME} >> ${DIR}.nagios_check_NG
        if [ `expr ${ERORRO_COUNT} % 6` = 0 ];then
            critical_mail
        fi
    else
        critical_mail
        ## create critical evidence
        /bin/touch /root/bin/.nagios_check_NG
        /bin/echo "${LONGDATETIME}\n" >> ${DIR}.nagios_check_NG
    fi
else
    ## if $CHECK_STAT is OK, but previous check is NG, then send recovery mail
    if [ -e /root/bin/.nagios_check_NG ];then
        recovery_mail
        ## remove critical evedence
        /bin/rm -f ${DIR}.nagios_check_NG
    fi
fi
