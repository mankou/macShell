#!/bin/bash
#功能描述：备份mac上常用的配置文件

#DEST=/Users/mang/AppData/Dropbox/mac/macConfigBackup
#BASE_PATH=$(cd $(dirname "$0");pwd)

DEST=/Users/mang/AppData/百度云同步盘/mac/macConfigBackup/shellConfigBak
cp ~/.vimrc  $DEST/
cp ~/.gvimrc  $DEST/
cp ~/.dir_colors  $DEST/
cp ~/.bash_profile  $DEST/

ls -al $DEST/
