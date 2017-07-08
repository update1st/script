#!/bin/bash  
### BEGIN INIT INFO  
#  
# Provides:  Program A  
# Required-Start:   $local_fs  $remote_fs  
# Required-Stop:    $local_fs  $remote_fs  
# Default-Start:    2 3 4 5  
# Default-Stop:     0 1 6  
# Short-Description:    initscript  
# Description:  This file should be used to construct scripts to be placed in /etc/init.d.  
#  
### END INIT INFO  

#awk -F '[_ -]' '{for(i=1;i<=NF;++i) printf $i "\n";printf "\n"}'
#if  ls /etc/ |grep -E '*_version|*-release' | grep -q -E -i "debian" ; then echo yes;else echo no; fi


# User Info
OSKEY="centos fedora debian ubuntu kali ";
PACKAGE="curl wget git make aria2 unzip gcc";


# System Info
DATE=$(date +%Y%m%d);
DIR=$(cd "$(dirname "$0")"; pwd);
IP=$(ip a | grep inet | sed -n '3p' |awk '{print $2}' |awk -F '/' '{print $1}');
BIT=$(uname -m);

# Progarm Info
PROG="";
PROG_PATH="";
PROG_ARGS_PREFIX="";
PROG_ARGS="";
PROG_PID_KEY="";

# GET Progarm PID 
PID=`ps -ef | grep $PROG_PID_KEY| grep -v grep|awk '{print $2}'`;

# OUTPUT log or /dev/null
PROG_LOG_DIR=""; # $DIR/log
xDIR=$(ls -ll $0 | grep $0 | awk -F '->' '{print $2}');
if [ "$xDIR" = "" ]; then
    PROG_LOG_DIR=$DIR/log;
else 
    PROG_LOG_DIR=${xDIR%/*}/log;
fi
PROG_LOG="$PROG_LOG_DIR/$PROG-$DATE.log";
#PROG_LOG="/dev/null";


install() {
    CheckOS_Install_Package;
    # Create log directory ,if u don't need it, annotations here.
    if [ ! -d "$PROG_LOG_DIR" ]; then
      echo -e "[\033[32m INFO \033[0m] Create $PROG_LOG_DIR $PROG log directory";
      mkdir $PROG_LOG_DIR && chmod -R 777 $PROG_LOG_DIR;
    else  
      echo -e "[\033[31m ERRO \033[0m] $PROG_LOG_DIR already exists!";
    fi
    # End of create log directory.
    # How to install the program ?





}

config() {
}

start() {
    echo -e "\033[31m Start $PROG\033[0m";
    if [ "$PID" != "" ]; then 
       echo -e "[\033[31m ERRO \033[0m] $PROG is Running!";
       echo -e "[\033[31m PID:\033[0m ] $PID";
       exit 1
    else 
       $PROG_PATH/$PROG $PROG_ARGS_PREFIX $PROG_ARGS > $PROG_LOG 2>&1 &
       echo -e "[\033[32m INFO \033[0m] Starting $PROG......";
       PID=`ps -ef | grep $PROG_PID_KEY| grep -v grep|awk '{print $2}'`;
       echo -e "[\033[31m PID:\033[0m ] $PID";
    fi
}

stop() {
    echo -e "\033[31m Stop $PROG\033[0m";
    echo -e "[\033[32m INFO \033[0m] Check $PROG \033[31m PID \033[0m information......";
    if [ "$PID" != "" ]; then
       kill $PID;
       echo -e "[\033[32m INFO\033[0m ] $PROG Stopped";
    else 
       echo -e "[\033[31m ERRO\033[0m ] $PROG isn't Running!";
       #exit 1
    fi
}

status() {
    echo -e "\033[31m Check $PROG Run information\033[0m";
    if [ "$PID" != "" ]; then 
       echo -e "[\033[31m ERRO \033[0m] $PROG is Running!";
       echo -e "[\033[31m PID:\033[0m ] $PID";
       exit 1
    else if [ "$(ls $PROG_PATH | grep $PROG)" = "$PROG" ]; then
       echo -e "[\033[31m INFO \033[0m] $PROG is stopped!"; else
       echo -e "[\033[31m INFO\033[0m ] Please install $PROG first! Run as root \033[31m 'sh $0 install'\033[0m. ";fi
    fi    
}

remove() {
    stop
    echo -e "[\033[31m INFO:\033[0m ] Del bin file \033[31m $PROG_PATH/$PROG \033[0m ";
    rm -rf $PROG_PATH/$PROG $PROG_LOG_DIR/$PROG-*;
    if [ -f "$PROG_ARGS" ]; then
        echo -e "[\033[31m INFO:\033[0m ] Del config file \033[31m $PROG_ARGS \033[0m ";
        rm -rf $PROG_ARGS;
    fi
    echo -e "[\033[31m INFO:\033[0m ] END";
}


# Check run as root.
if [ "$(id -u)" != "0" ]; then  
    echo -e "[\033[31m ERRO\033[0m ] This script must be run as root!" 1>&2;
    exit 1  
fi  

# CheckOS && install package.
CheckOS_Install_Package() {
    INSTALL_BIN="";
    #  checkos && getOS install command.
    for x in $(echo $OSKEY | awk  '{for(i=1;i<=NF;++i) printf $i "\n";printf "\n"}'); do 
        if  ls /etc/ |grep -E '*_version|*-release' | grep -q -E -i "$x" ; then 

            if [ "$x" = "centos" ]; then  INSTALL_BIN="yum";
            elif  [ "$x" = "fedora" ]; then  INSTALL_BIN="yum";
            elif  [ "$x" = "debian" ]; then  INSTALL_BIN="apt-get";
            elif  [ "$x" = "ubuntu" ]; then  INSTALL_BIN="apt-get";
            elif  [ "$x" = "kali" ]; then  INSTALL_BIN="apt-get";  
            fi

            echo -e "Operating system: \033[31m $x \033[0m ";
            echo -e "Install command: \033[31m $INSTALL_BIN \033[0m ";
            echo -e "CPU: \033[31m $BIT \032[0m ";
        fi; 
    done;
    #echo -e "Install command: \033[31m $INSTALL_BIN \033[0m ";
    #echo -e "CPU: \033[31m $BIT \032[0m ";
    
    # install softpackage.
    if [ "$INSTALL_BIN" != "" ]; then
        $INSTALL_BIN update;
        $INSTALL_BIN install $PACKAGE -y;
    else 
        echo -e "Operating system: \033[31m Unsupported operating system \033[0m ";    
        exit 1
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
        #PID=`ps -ef | grep $PROG| grep -v grep|awk '{print $2}'`
        status     
        exit 1
        ;;
esac






