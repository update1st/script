#!/bin/bash  
### BEGIN INIT INFO  
#  
# Provides:  arai2c  .....
# Required-Start:   $local_fs  $remote_fs  
# Required-Stop:    $local_fs  $remote_fs  
# Default-Start:    2 3 4 5  
# Default-Stop:     0 1 6  
# Short-Description:    initscript  
# Description:  This file should be used to construct scripts to be placed in /etc/init.d.  
#  
### END INIT INFO  

### --------README---------
# 
# http://ip              Aria2c WebGUI  
# http://ip/file         Aria2c Download directory (File Manager)
# Caddy Auth --> ./caddy-aria2/conf/Caddyfile config file. KEY(basicauth / user password && basicauth / guest pass)
# Aria2c Auth --> ./caddy-aria2/conf/aria2.conf config file. KEY(rpc-secret=abc.com)
#
### ----------------------- 

# User Info
OSKEY="centos fedora debian ubuntu red-hat";
PACKAGE="curl wget git make aria2 unzip gcc";
RE_PACKAGE="aria2";

# System Info
DATE=$(date +%Y%m%d);
DIR=$(cd "$(dirname "$0")"; pwd);
IP=$(ip a | grep inet | sed -n '3p' |awk '{print $2}' |awk -F '/' '{print $1}');
BIT=$(uname -m);

# Progarm config/log directory Info.
PROG_LOG_DIR=""; # $DIR/log
PROG_CONF_DIR=""; # config directory
# like this: /ect/init.d/xxxx.sh->/path/to/yyy.sh .
xDIR=$(ls -ll $0 | grep $0 | awk -F '->' '{print $2}'); 
if [ "$xDIR" = "" ]; then
    PROG_LOG_DIR=$DIR/caddy-aria2/log;
    PROG_CONF_DIR=$DIR/caddy-aria2/conf;
else 
    PROG_LOG_DIR=${xDIR%/*}/caddy-aria2/log;
    PROG_CONF_DIR=${xDIR%/*}/caddy-aria2/conf;
fi


# Program caddy.
Info_caddy() {

    PROG="caddy";
    PROG_PATH="/usr/local/bin";
    PROG_ARGS_PREFIX="-conf";
    PROG_ARGS="$PROG_CONF_DIR/Caddyfile";
    PROG_PID_KEY="Caddyfile";

    # GET Caddy Progarm PID 
    PID=`ps -ef | grep $PROG_PID_KEY| grep -v grep|awk '{print $2}'`;
    PROG_LOG="$PROG_LOG_DIR/$PROG-$DATE.log";
    #PROG_LOG="/dev/null";
}

install_caddy() {
    cd /usr/local/bin && curl https://getcaddy.com | bash -s http.filemanager; 
    rm -rf /usr/local/bin/caddy_* && cd /tmp;
    cd ${PROG_LOG_DIR%/*}/www;
    Ver=$(curl -m 10 -s "https://github.com/mayswind/AriaNg/releases/latest"|sed -r 's/.*tag\/(.+)\">redirected.*/\1/');
    wget -N --no-check-certificate "https://github.com/mayswind/AriaNg/releases/download/${Ver}/aria-ng-${Ver}.zip";
    unzip aria-ng-${Ver}.zip && rm -rf aria-ng-${Ver}.zip;
    chmod -R 755 ${PROG_LOG_DIR%/*}/www;
    Caddy_conf;
    aria2c_conf
}

Caddy_conf(){
    echo ""> $PROG_CONF_DIR/Caddyfile;
    echo ":80 {
      root ${PROG_LOG_DIR%/*}/www
      timeouts none
      gzip
      basicauth / user password
      basicauth / guest pass
      filemanager /file {
      show ${PROG_LOG_DIR%/*}/www/file
       user:
       allow_new true
       allow_edit true
       allow_commands true
       allow_command cp
       guest:
       allow_new false
       allow_edit false
       }
     }" > $PROG_CONF_DIR/Caddyfile;
}

start_caddy() {
    Info_caddy;
    start;
}
stop_caddy() {
    Info_caddy;
    stop;
}
status_caddy() {
    Info_caddy;
    status;
}
remove_caddy() {
    Info_caddy
    stop_caddy;
    remove;
    rm -rf ${PROG_LOG_DIR%/*}/www ;
}


Info_aria2c() {
    # Aria2c info.
    PROG="aria2c";
    PROG_PATH="/usr/bin";
    PROG_ARGS_PREFIX="";
    PROG_ARGS="--conf-path=$PROG_CONF_DIR/aria2.conf";
    PROG_PID_KEY="aria2.conf";

    # GET Aria2c Progarm PID 
    PID=`ps -ef | grep \/$PROG_PID_KEY| grep -v grep|awk '{print $2}'`;
    PROG_LOG="$PROG_LOG_DIR/$PROG-$DATE.log";
    #PROG_LOG="/dev/null";
}

aria2c_conf() {
    if [ ! -d "$PROG_CONF_DIR" ]; then  Create_dir;  fi
    cd $PROG_CONF_DIR;
    wget --no-check-certificate https://softs.pw/Other/Aria2/dht.dat;
    echo "" > $PROG_CONF_DIR/aria2.session;
    echo "" > $PROG_CONF_DIR/aria2.conf;
    echo "
      dir=${PROG_LOG_DIR%/*}/www/file
      file-allocation=none
      continue=true

      max-concurrent-downloads=10
      max-connection-per-server=5
      min-split-size=10M
      split=20
      max-overall-upload-limit=1M
      disable-ipv6=false


      input-file=$PROG_CONF_DIR/aria2.session
      save-session=$PROG_CONF_DIR/aria2.session


      enable-rpc=true
      rpc-allow-origin-all=true
      rpc-listen-all=true
      rpc-listen-port=6800
      rpc-secret=abc.com


      follow-torrent=true
      listen-port=51413
      enable-dht=true
      enable-peer-exchange=true
      peer-id-prefix=-TR2770-
      user-agent=Transmission/2.77
      seed-ratio=0.1
      bt-seed-unverified=true
      " > $PROG_CONF_DIR/aria2.conf;

}


start_aria2c() {
    Info_aria2c;
    start;
}
stop_aria2c() {
    Info_aria2c;
    stop;
}
status_aria2c() {
    Info_aria2c;
    status;
}

remove_aria2c() {
    Info_aria2c
    stop_aria2c;
    CheckOS_Remove_Package
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
    # Create log directory ,if u don't need it, annotations here.
    if [ ! -d "$PROG_LOG_DIR" ]; then
      echo -e "[\033[32m INFO \033[0m] Create $PROG_LOG_DIR  log directory";
      mkdir -p $PROG_LOG_DIR && chmod -R 777 $PROG_LOG_DIR;
    else  
      echo -e "[\033[31m ERRO \033[0m] $PROG_LOG_DIR already exists!";
    fi
    # Create Config directory.
    if [ ! -d "$PROG_CONF_DIR" ]; then
      echo -e "[\033[32m INFO \033[0m] Create $PROG_CONF_DIR  conf directory";
      mkdir -p $PROG_CONF_DIR && chmod -R 777 $PROG_CONF_DIR;
    else  
      echo -e "[\033[31m ERRO \033[0m] $PROG_CONF_DIR already exists!";
    fi   
   # Create Caddy http directory ${PROG_LOG_DIR%/*}/www/file.
    if [ ! -d "${PROG_LOG_DIR%/*}/www/file" ];then 
      echo -e "[\033[32m INFO \033[0m] Create ${PROG_LOG_DIR%/*}/www/file  http directory";
      mkdir -p ${PROG_LOG_DIR%/*}/www/file && chmod -R 777 ${PROG_LOG_DIR%/*}/www/file;
    fi 
}


install() {
    CheckOS_Install_Package;
    Create_dir;
    install_caddy;
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
       #exit 1
    else if [ "$(ls $PROG_PATH | grep $PROG)" = "$PROG" ]; then
       echo -e "[\033[31m INFO \033[0m] $PROG is stopped!"; else
       echo -e "[\033[31m INFO\033[0m ] Please install $PROG first! Run as root \033[31m 'sh $0 install'\033[0m. ";fi
    fi    
}

remove() {
    #stop
    echo -e "[\033[31m INFO:\033[0m ] Del bin file \033[31m $PROG_PATH/$PROG \033[0m ";
    rm -rf $PROG_PATH/$PROG $PROG_LOG_DIR/$PROG-*;
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
        start_caddy
        start_aria2c
        exit 0
        ;;
    stop)  
        stop_caddy
        stop_aria2c
        exit 0
        ;;
    reload|restart|force-reload)  
        stop_aria2c
        start_aria2c

        exit 0
        ;;
    install)  
        install
        exit 0
        ;;
    remove)  
        remove_caddy
        remove_aria2c
        exit 0
        ;;
    **)  
        echo -e "\033[32m  Usage: \033[0m $0 {\033[32m install|remove|start|stop|reload \033[0m}" 1>&2;
        #PID=`ps -ef | grep $PROG| grep -v grep|awk '{print $2}'`
        echo "----------------------------------------"
        status_caddy
        echo "--------------------"
        status_aria2c     
        echo "----------------------------------------"
        exit 1
        ;;
esac






