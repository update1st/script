#!/bin/bash
# http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/
# http://gcc.skazkaforyou.com/releases/

Version=$(curl -m 10 -s http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/ | grep gcc\- |sed '/^$/!h;$!d;g' |sed 's/<[^>]*>//g' |awk -F '[ /]' '{print $1}');

Version_local="gcc-$(gcc --version | grep gcc|awk '{print $3}')";

if [ "$Version" = "$Version_local" ]; then
    echo -e "[\033[31m ERRO \033[0m] GCC_VERSION=$Version_local is new version";
else  
    echo -e "[\033[32m INFO \033[0m] local gcc_version : $Version_local ";
    echo -e "[\033[32m INFO \033[0m] remote gcc_version : $Version ";
    cd /tmp && wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/$Version/$Version.tar.gz;
    tar -xf $Version.tar.gz; cd $Version; ./contrib/download_prerequisites;
    mkdir gcc_temp && cd gcc_temp;
    ../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib;
    make & make install
fi
