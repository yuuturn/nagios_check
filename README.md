check_nagios
====

Overview
only "nagios-plugins-procs" and "nagios-plugins-nrpe" installed, 
can check nagios alive.

of course, nrpe installed on remotehost.

## Install
on checked server, install nrpe, and set nrpe.cfg like bellow.
command[check_nagios_procs]=/usr/lib64/nagios/plugins/check_procs -c 1: -a /usr/sbin/nagios

on checking server, install nagios-plugins-procs, agios-plugins-nrpe
and place nagios_check.sh on directory you like, then set cron

## Author

[yuuturn](https://github.com/yuuturn)
