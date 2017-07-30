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


# OS PACKAGE Info
OSKEY="centos fedora debian ubuntu redhat";
PACKAGE="curl wget git make automake autoconf unzip gcc privoxy proxychains-ng";
RE_PACKAGE="";

# System Info
DATE=$(date +%Y%m%d);
DIR=$(cd "$(dirname "$0")"; pwd);
IP=$(ip a | grep inet | sed -n '3p' |awk '{print $2}' |awk -F '/' '{print $1}');
BIT=$(uname -m);

INFO="[\033[32m INFO \033[0m]";
ERRO="[\033[31m ERRO \033[0m]";
rPID="[\033[31m PID: \033[0m]"; #red PID
gPID="[\033[32m PID: \033[0m]"; #green PID


# dnsforwarder--------------------------------------
p1(){
  # BASE INFO
  PROG="dnsforwarder";
  PROG_PATH="/usr/local/bin";
  PROG_ARGS_PREFIX="-f";

  Program_info;
  p1_args;
}
p1_args(){
  # PROG_DIR="$pDIR $PROG_CONF_DIR $PROG_LOG_DIR ";
  PROG_ARGS="$PROG_CONF_DIR/default.en.config";
  PROG_PID_KEY="defunct";

  # GET Progarm PID
  PID=`ps -ef | grep "$PROG_PID_KEY"| grep -v grep|awk '{print $2}'`;

}
p1_install(){

  #### ERRO alocal 1.x command not found,make sure autoconf && automake version.

  # wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
  # tar -zxf autoconf-2.69.tar.gz && autoconf-2.69
  # ./configure && make && make install; cd /tmp
  #
  # wget ftp://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz
  # tar -zxf  automake-1.15.tar.gz && cd automake-1.15
  # ./configure && make && make install; cd /tmp
  # export LDFLAGS=-lrt


  cd /tmp && git clone https://github.com/holmium/dnsforwarder.git;
  cd dnsforwarder;
  ./configure --enable-downloader=wget && make && make install;
  dnsforwarder_conf;
  cd $PROG_CONF_DIR;
  wget https://raw.githubusercontent.com/holmium/dnsforwarder/6/default.en.config;
  wget https://raw.githubusercontent.com/update1st/gfw-whitelist/master/china-domain-update.txt;
  sed -i 's/114\.114\.114\.114/115\.159\.157\.26/g' default.en.config;
  sed -ri 's/^UDPGroup 1\.2\.4\.8/115\.159\.158\.38/g' default.en.config;
  #sed -ri 's/^GroupFile/GroupFile \/etc\/dnsforwarder\/china-domain-update.txt/g' default.en.config;
  sed  -rie "s#^LogOn false#LogOn true#g" default.en.config;
  sed  -rie "s#^LogFileFolder#LogFileFolder $PROG_CONF_DIR\/log#g" default.en.config;
  sed  -rie "s#^GroupFile#GroupFile $PROG_CONF_DIR\/china-domain-update.txt#g" default.en.config;

}


# --------------------------------------
# Progarm Info
Program_info() {
  pDIR=""; #Progarm
  PROG_CONF_DIR=""; # $DIR
  PROG_LOG_DIR=""; # $DIR/log

  # PORG log.conf Directory
  xDIR=$(ls -ll $0 | grep $0 | awk -F '->' '{print $2}');
  pDIR=$DIR/$PROG;
  if [ "$xDIR" = "" ]; then
      PROG_CONF_DIR=$pDIR;
      #PROG_CONF_DIR=$pDIR/conf;
      PROG_LOG_DIR=$pDIR/log;

  else
      PROG_CONF_DIR=${xDIR%/*}/$PROG;
      #PROG_CONF_DIR=${xDIR%/*}/$PROG/conf;
      PROG_LOG_DIR=${xDIR%/*}/$PROG/log;

  fi

  # OUTPUT log or /dev/null
  #PROG_LOG="$PROG_LOG_DIR/$PROG-$DATE.log";
  PROG_LOG="/dev/null";

  # Create directory for Program(log/config)
  PROG_DIR="$pDIR $PROG_CONF_DIR $PROG_LOG_DIR ";
}


# Create Progarm log/config directory
Create_Log_Conf_Dir(){
  for x in $PROG_DIR; do
    if [ ! -d "$x" ]; then
      echo -e "$INFO Create $x  directory";
      mkdir -p $x && chmod -R 755 $x;
    else
      echo -e "$ERRO $xDIR already exists!";
    fi
  done
}

# Delete Progarm log/config directory
Delete_log_conf_Dir(){
  for x in $PROG_DIR; do
    if [ ! -d "$x" ]; then
      echo "";
      #exit 1;
    else
      rm -rf $x;
    fi
  done
}

# How to install the program and configure?
Insall_Program(){
  install;

  # how to install program?
  p1;
  Create_Log_Conf_Dir;
  p1_install;

}

Remove_Program(){
  p1;
  stop;
  remove;
  echo "----------------------------------------"
  echo -e "$INFO RUNING END";
}

Start_Program(){
  p1;
  start;
  echo "----------------------------------------"
}

Stop_Program(){
  p1;
  stop;
  echo "----------------------------------------"
}
Status_Program(){
  p1;
  status;
  echo "----------------------------------------"
}


install() {
    CheckOS_Install_Package;
}

remove() {
    CheckOS_Remove_Package
    rm -rf $PROG_PATH/$PROG ;
    if [ -f "$PROG_ARGS" ]; then
        echo -e "[\033[31m INFO:\033[0m ] Del config file \033[31m $PROG_ARGS \033[0m ";
        rm -rf $PROG_ARGS;
    fi
    Delete_log_conf_Dir;
}

start() {
    echo -e "\033[32m Start $PROG\033[0m";
    if [ "$PID" != "" ]; then
       echo -e "$ERRO $PROG is Running!";
       echo -e "$ERRO $PID";
       #exit 1
    else
       $PROG_PATH/$PROG $PROG_ARGS_PREFIX $PROG_ARGS > $PROG_LOG 2>&1 &
       echo -e "$INFO Starting $PROG......";
       PID=`ps -ef | grep $PROG_PID_KEY| grep -v grep|awk '{print $2}'`;
       echo -e "$INFO $PID";
    fi
}

stop() {
    echo -e "\033[32m Stop $PROG\033[0m";
    echo -e "$INFO Check $PROG \033[31m PID \033[0m information......";
    if [ "$PID" != "" ]; then
       kill $PID;
       echo -e "$INFO $PROG Stopped";
    else
       echo -e "$ERRO $PROG isn't Running!";
       #exit 1
    fi
}

status() {
    echo -e "\033[32m Check the $PROG running status..\033[0m";
    if [ "$PID" != "" ]; then
       echo -e "$ERRO $PROG is Running!";
       echo -e "$rPID $PID";
       #exit 1
    else if [ "$(ls $PROG_PATH | grep $PROG)" = "$PROG" ]; then
       echo -e "$INFO $PROG is stopped!"; else
       echo -e "$INFO Please install $PROG first! ";fi
    fi
}


# Check run as root.
if [ "$(id -u)" != "0" ]; then
    echo -e "$ERRO This script must be run as root!" 1>&2;
    exit 1
fi

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
# Install package.
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


case "$1" in
    start)
        Start_Program
        exit 0
        ;;
    stop)
        Stop_Program
        exit 0
        ;;
    reload|restart|force-reload)
        Stop_Program
        Start_Program
        exit 0
        ;;
    install)
        Insall_Program
        exit 0
        ;;
    remove)
        Remove_Program
        exit 0
        ;;
    **)
        echo -e "\033[32m  Usage: \033[0m $0 {\033[32m install | remove | start | stop | reload \033[0m}" 1>&2;
        #PID=`ps -ef | grep $PROG| grep -v grep|awk '{print $2}'`

        Status_Program
        exit 1
        ;;
esac
