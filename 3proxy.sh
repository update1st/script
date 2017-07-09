#!/bin/bash  
### BEGIN INIT INFO  
#  
# Provides:  HTTP PROXY  
# Required-Start:   $local_fs  $remote_fs  
# Required-Stop:    $local_fs  $remote_fs  
# Default-Start:    2 3 4 5  
# Default-Stop:     0 1 6  
# Short-Description:    initscript  
# Description:  This file should be used to construct scripts to be placed in /etc/init.d.  
#  
### END INIT INFO  

PACKAGE="curl wget git make aria2 unzip gcc";

DATE=$(date +%Y%m%d);
DIR=$(cd "$(dirname "$0")"; pwd);
IP=$(ip a | grep inet | sed -n '3p' |awk '{print $2}' |awk -F '/' '{print $1}');

PROG="3proxy";
PROG_PATH="/usr/local/bin"; 
PROG_ARGS="$DIR/proxy3.cfg";
PID_PATH="/var/run/";  
LOG_DIR="$DIR/log";


PID=`ps -ef | grep $PROG_PATH/$PROG| grep -v grep|awk '{print $2}'`; 


if [ "$(id -u)" != "0" ]; then  
    echo -e "[\033[31m ERRO\033[0m ] This script must be run as root!" 1>&2;
    exit 1  
fi  



check_sys() {
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
        elif cat /etc/issue | grep -q -E -i "kali"; then
                release="kali"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}




install() {

    check_sys;
    if [ ${release} == "centos" ]; then
    yum update -y;
    yum install $PACKAGE -y;
    else if [ ${release} == "debian" ]; then
        apt-get update -y;
        apt-get install $PACKAGE -y; 
        else if [ ${release} == "ubuntu" ]; then
            apt-get update -y;
            apt-get install $PACKAGE -y;
            else if [ ${release} == "kali" ]; then
                apt-get update -y;
                apt-get install $PACKAGE -y;
                else echo "Unknown operating system";
                fi
            fi
        fi 
    fi

    if [ ! -d "$LOG_DIR" ]; then
      echo -e "[\033[32m INFO \033[0m] Create $LOG_DIR 3proxy_log directory";
      mkdir $LOG_DIR && chmod -R 777 $LOG_DIR;
    else  
      echo -e "[\033[31m ERRO \033[0m] $LOG_DIR already exists!";
    fi
    echo "Install $PROG.";
    cd /tmp && wget https://github.com/z3APA3A/3proxy/archive/0.8.10.tar.gz;
    tar -zxf 0.8.10.tar.gz && cd 3proxy-0.8.10;
    make -f Makefile.Linux && make -f Makefile.Linux install;
    cd $DIR;
    echo "
      timeouts 1 5 30 60 180 1800 15 60
      users mm:CL:mmm nn:CL:nnn

      service
      log $LOG_DIR/proxy.log D
      #logformat "- +_L%t.%.  %N.%p %E %U %C:%c %R:%r %O %I %h %T"
      #logformat "L%d-%m-%Y %H:%M:%S %z %N.%p %E %U %C:%c %R:%r %O %I %h %T"
      rotate 30
      internal 0.0.0.0

      auth strong
      allow nn 
      parent 1000 socks5 127.0.0.1 11111
      #parent 1000 http 127.0.0.1 11111
      proxy -a -p22222
      #----------
      auth strong
      allow mm
      parent 1000 http 127.0.0.1 33333
      proxy -a -p44444
         "> $PROG_ARGS;
    start;
}

remove() {
    stop
    echo -e "[\033[32m INFO \033[0m] Del 3proxy config: $PROG_ARGS "
    echo -e "[\033[32m INFO \033[0m] Del 3proxy bin: $PROG_PATH/$PROG "
    echo -e "[\033[32m INFO \033[0m] Check 3proxy log: \n$(ls $LOG_DIR/proxy.log*) "
    rm -rf $PROG_PATH/$PROG $PROG_ARGS $LOG_DIR/proxy.log*;
}

start() {
    echo  "Start $PROG."
    if [ "$PID" != "" ]; then 
       echo -e "[\033[31m ERRO \033[0m] $PROG is running!";
       echo -e "[\033[31m PID:\033[0m ] $PID";
       exit 1
    else 
       $PROG_PATH/$PROG $PROG_ARGS >/dev/null 2>&1 &
       echo -e "[\033[32m INFO \033[0m] Starting 3proxy......";
       #echo -e "[\033[32m PID:\033[0m ] $PID";
       #echo "$PROG_PATH/$PROG $PROG_ARGS"
    fi
}

stop() {
    echo  "Stop $PROG.";
    echo -e "[\033[32m INFO \033[0m] Check $PROG \033[31m PID \033[0m information......";
    if [ "$PID" != "" ]; then
       echo -e "[\033[32m PID:\033[0m ] $PID";
       kill $PID;
       echo -e "[\033[32m INFO\033[0m ] $PROG stopped";
    else 
       echo -e "[\033[31m ERRO\033[0m ] $PROG isn't running!";
       #exit 1
    fi
}


case "$1" in  
    start)  
       start
       exit 0
       ;;
    stop)  
       stop
       exit 0
       ;;
    reload|restart|force-reload)  
       stop
       start
       exit 0
       ;;
    install)  
       install
       exit 0
       ;;
    remove)  
       remove
       exit 0
       ;;
    **)  
       echo -e "\033[32m  Usage: \033[0m $0 {\033[32m install|remove|start|stop|reload \033[0m}" 1>&2;
       echo -e "[\033[32m INFO \033[0m] Check $PROG  information......";
       #PID=`ps -ef | grep $PROG| grep -v grep|awk '{print $2}'`
       if [ "$PID" != "" ]; then 
          echo -e "[\033[32m INFO \033[0m] $PROG is running!";
          echo -e "[\033[32m PID:\033[0m ] $PID";
       else if [ "$(ls $PROG_PATH | grep $PROG)" = "$PROG" ]; then
          echo -e "[\033[31m INFO \033[0m] $PROG is stopped!"; else
          echo -e "[\033[31m INFO\033[0m ] Please install $PROG first! Run 'sudo sh $0 install'. ";fi
       fi       
          exit 1
       ;;
esac

