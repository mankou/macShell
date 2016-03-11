#!/bin/bash
#功能描述：备份mac上常用的配置文件

#DEST=/Users/mang/AppData/Dropbox/mac/macConfigBackup
DEST=/Users/mang/AppData/快盘/mac/macConfigBackup
cp ~/.vimrc  $DEST/
cp ~/.gvimrc  $DEST/
cp ~/.dir_colors  $DEST/
cp ~/.bash_profile  $DEST/

ls -al $DEST/
