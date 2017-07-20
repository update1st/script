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


# --------------------------------------
p1(){
  # BASE INFO
  PROG="";
  PROG_PATH="";
  PROG_ARGS_PREFIX="";
  PROG_ARGS="";
  PROG_PID_KEY="";

  Program_info;
}
p1_install(){
  echo "";
}

# --------------------------------------
# p2(){
#   # BASE INFO
#   PROG="";
#   PROG_PATH="";
#   PROG_ARGS_PREFIX="";
#   PROG_ARGS="";
#   PROG_PID_KEY="";
#
#   Program_info;
# }
# p2_install(){
#   echo "";
# }
#
# # --------------------------------------
# p3(){
#   # BASE INFO
#   PROG="";
#   PROG_PATH="";
#   PROG_ARGS_PREFIX="";
#   PROG_ARGS="";
#   PROG_PID_KEY="";
#
#   Program_info;
# }
# p3_install(){
#   echo "";
# }

# --------------------------------------
# Progarm Info
Program_info() {

  PROG_CONF_DIR=""; # $DIR
  PROG_LOG_DIR=""; # $DIR/log


  # GET Progarm PID
  PID=`ps -ef | grep "$PROG_PID_KEY"| grep -v grep|awk '{print $2}'`;

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
  PROG_LOG="$PROG_LOG_DIR/$PROG-$DATE.log";
  #PROG_LOG="/dev/null";

  # Create directory for Program(log/config)
  PROG_DIR="$pDIR $PROG_CONF_DIR $PROG_LOG_DIR ";
}


# Create Progarm log/config directory
Create_Log_Conf_Dir(){
  for x in $PROG_DIR; do
    if [ ! -d "$x" ]; then
      echo -e "$INFO Create $x Prog_dir/Conf_dir/Log_dir directory";
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

  # p2;
  # Create_Log_Conf_Dir;
  # p2_install;
  #
  # p3;
  # Create_Log_Conf_Dir;
  # p3_install;
}

Remove_Program(){
  p1;
  stop;
  remove;
  # echo "----------------------------------------"
  # p2;
  # stop;
  # remove;
  # echo "----------------------------------------"
  # p3;
  # stop;
  # remove;
  # echo "----------------------------------------"
  echo -e "$INFO RUNING END";
}

Start_Program(){
  p1;
  start;
  # echo "----------------------------------------"
  # p2;
  # start;
  # echo "----------------------------------------"
  # p3;
  # start;
  # echo "----------------------------------------"
}

Stop_Program(){
  p1;
  stop;
  # echo "----------------------------------------"
  # p2;
  # stop;
  # echo "----------------------------------------"
  # p3;
  # stop;
  # echo "----------------------------------------"
}
Status_Program(){
  p1;
  status;
  # echo "----------------------------------------"
  # p2;
  # status;
  # echo "----------------------------------------"
  # p3;
  # status;
  # echo "----------------------------------------"

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
    echo -e "\033[32m Check $PROG Run information\033[0m";
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
            elif  [ "$x" = "fedora" ]; then  INSTALL_BIN="dnf";
            elif  [ "$x" = "redhat" ]; then  INSTALL_BIN="yum";
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
