#!/bin/bash
### BEGIN INIT INFO
#
# Provides:  dns dnsforwarder (30000+ chinese domain list)
# Required-Start:   $local_fs  $remote_fs
# Required-Stop:    $local_fs  $remote_fs
# Default-Start:    2 3 4 5
# Default-Stop:     0 1 6
# Short-Description:    initscript
# Description:  This file should be used to construct scripts to be placed in /etc/init.d.
#
### END INIT INFO


#------------------------------------------------------------
# REDAME: The script is only applicable to China, used to prevent gfw dns pollution.
# china-domain-list: https://raw.githubusercontent.com/update1st/gfw-whitelist/master/china-domain-update.txt
# 30000+ Chinese domain name records through aliyun dns server(223.5.5.5 223.6.6.6).
# The default DNS is  universities dns server ( 115.159.157.26 115.159.158.38)
# If you do not want to use it,You can change the default DNS you want.
# public-dns: https://public-dns.info//
# config file directory /etc/dnsforwarder/default.en.config
#------------------------------------------------------------

# User Info
OSKEY="centos fedora debian ubuntu red-hat";
PACKAGE="curl wget git make automake aria2 unzip gcc";
RE_PACKAGE="";

# System Info
DATE=$(date +%Y%m%d);
DIR=$(cd "$(dirname "$0")"; pwd);
IP=$(ip a | grep inet | sed -n '3p' |awk '{print $2}' |awk -F '/' '{print $1}');
BIT=$(uname -m);


PROG_CONF_DIR="/etc/dnsforwarder";

# Program dnsforwarder.
Info_dnsforwarder() {

    PROG="dnsforwarder";
    PROG_PATH="/usr/local/bin";
    PROG_ARGS_PREFIX="-f";
    PROG_ARGS="$PROG_CONF_DIR/default.en.config";
    PROG_PID_KEY="defunct";

    # GET dnsforwarder Progarm PID
    PID=`ps -ef | grep $PROG_PID_KEY| grep -v grep|awk '{print $2}'`;
    #PROG_LOG="$PROG_LOG_DIR/$PROG-$DATE.log";
    PROG_LOG="/dev/null";
}

install_dnsforwarder() {
    cd /tmp && git clone https://github.com/holmium/dnsforwarder.git;
    cd dnsforwarder;
    ./configure --enable-downloader=wget && make && make install;
    dnsforwarder_conf;
}

dnsforwarder_conf(){
    cd $PROG_CONF_DIR;
    wget https://raw.githubusercontent.com/holmium/dnsforwarder/6/default.en.config;
    wget https://raw.githubusercontent.com/update1st/gfw-whitelist/master/china-domain-update.txt;
    sed -i 's/114\.114\.114\.114/115\.159\.157\.26/g' default.en.config;
    sed -ri 's/^UDPGroup 1\.2\.4\.8/115\.159\.158\.38/g' default.en.config;
    sed -ri 's/^GroupFile/GroupFile \/etc\/dnsforwarder\/china-domain-update.txt/g' default.en.config;

}

start_dnsforwarder() {
    Info_dnsforwarder;
    start;
}
stop_dnsforwarder() {
    Info_dnsforwarder;
    stop;
}
status_dnsforwardery() {
    Info_dnsforwarder;
    status;
}
remove_dnsforwarder() {
    Info_dnsforwarder
    stop_dnsforwarder;
    remove;
}






# CheckOS .
CheckOS() {
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
            echo -e "CPU: \033[31m $BIT \033[0m ";
        fi;
    done;
    #echo -e "Install command: \033[31m $INSTALL_BIN \033[0m ";
    #echo -e "CPU: \033[31m $BIT \032[0m ";
}
# install package.
CheckOS_Install_Package() {
    CheckOS;
    # install softpackage.
    if [ "$INSTALL_BIN" != "" ]; then
        $INSTALL_BIN update -y;
        $INSTALL_BIN install $PACKAGE -y;
    else
        echo -e "Operating system: \033[31m Unsupported operating system \033[0m ";
        exit 1
    fi
}
CheckOS_Remove_Package() {
    CheckOS
    # Remove softpackage.
    if [ "$INSTALL_BIN" != "" ]; then
        #$INSTALL_BIN update -y;
        $INSTALL_BIN remove $RE_PACKAGE -y;
    else
        echo -e "Operating system: \033[31m Unsupported operating system \033[0m ";
        exit 1
    fi
}

Create_dir() {
    # Create Config directory.
    if [ ! -d "$PROG_CONF_DIR" ]; then
      echo -e "[\033[32m INFO \033[0m] Create $PROG_CONF_DIR  conf directory";
      mkdir -p $PROG_CONF_DIR && chmod -R 755 $PROG_CONF_DIR;
    else
      echo -e "[\033[31m ERRO \033[0m] $PROG_CONF_DIR already exists!";
    fi
}








install() {
    CheckOS_Install_Package;
    Create_dir;
    install_dnsforwarder;
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
    echo -e "\033[32m Check the $PROG running status..\033[0m";
    if [ "$PID" != "" ]; then
       echo -e "[\033[31m ERRO \033[0m] $PROG is Running!";
       echo -e "[\033[31m PID:\033[0m ] $PID";
       #exit 1
    else if [ "$(ls $PROG_PATH | grep $PROG)" = "$PROG" ]; then
       echo -e "[\033[31m INFO \033[0m] $PROG is stopped!"; else
       echo -e "[\033[31m INFO\033[0m ] Please install $PROG first! Run as root \033[31m 'sh $0 install'\033[0m. ";fi
    fi
}

remove() {
    #stop
    echo -e "[\033[31m INFO:\033[0m ] Del bin file \033[31m $PROG_PATH/$PROG \033[0m ";
    rm -rf $PROG_PATH/$PROG ;
    Count=$(ls $PROG_LOG_DIR|wc -w );
    if [ "$Count" = "0" ]; then  rm -rf $PROG_LOG_DIR; fi
    if [ -f "$PROG_ARGS" ]; then
        echo -e "[\033[31m INFO:\033[0m ] Del config file \033[31m $PROG_ARGS \033[0m ";
        rm -rf $PROG_ARGS;
    fi
    Count1=$(ls $PROG_CONF_DIR|wc -w);
    if [ "$Count1" = "0" ]; then  rm -rf $PROG_CONF_DIR; fi
    echo -e "[\033[31m INFO:\033[0m ] END";
}


# Check run as root.
if [ "$(id -u)" != "0" ]; then
    echo -e "[\033[31m ERRO\033[0m ] This script must be run as root!" 1>&2;
    exit 1
fi

case "$1" in
    start)
    start_dnsforwarder
        exit 0
        ;;
    stop)
    stop_dnsforwarder
        exit 0
        ;;
    reload|restart|force-reload)
        stop_dnsforwarder
        start_dnsforwarder

        exit 0
        ;;
    install)
        install
        exit 0
        ;;
    remove)
        remove_dnsforwarder
        exit 0
        ;;
    **)
        echo -e "\033[32m  Usage: \033[0m $0 {\033[32m install|remove|start|stop|reload \033[0m}" 1>&2;
        #PID=`ps -ef | grep $PROG| grep -v grep|awk '{print $2}'`
        echo "----------------------------------------"
        status_dnsforwardery
        echo "----------------------------------------"
        exit 1
        ;;
esac
