#!/bin/bash
# author man003@163.com
# create 20160310114308
# modify 2016-03-11 13:33:20
# version 1.0
# =============================how to use==============================
# 如何在crontab中使用
# 命令参数又是如何使用的

#==============================todo==============================
# 放到github上 用mac的git命令放
# 如果本地有文件则不下载
# 删除比下载文件早3天的文件
# 把ip username 等都写成参数 以后调用时用命令调用即可
# 如果ftp连接不上应该提示

# ==============================history ==============================
# V1.0 初步完成脚本


IP=10.4.124.166
username=maning
password=1
remotePath=bak-project/svn

localPath=/Users/mang/work/dataBak/svnBak
logFile=bak.log


abLogPath=$localPath/$logFile
suffix=zip # 设置压缩包的格式
#shellDirPath=$(cd "$(dirname "$0")"; pwd)
#echo currentPath is $shellDirPath;


echo
echo start at `date -d today +"%Y-%m-%d %T"`====================
#TODO 我也不明白如下的语句为什么在crontab中没有输出呢？
#date -d today +"%Y-%m-%d %T"
date
startTime=`date +%s`
# 切换到本地目标目录 因为ftp get 命令是把文件下载到当前目录
cd $localPath;

# 先从ftp上找出最新的文件 再下载
# 如何找到进阶新的文件呢？ ls 按时间排序 然后tail -1 取出最后一行 这就是最新的文件
echo '从FTP取出最新的文件的文件名';
ftp -v -n $IP<<EOF
user $username $password
bin
cd $remotePath
ls -lt temp
bye
EOF

#cat temp|head -1|awk '{print $9}' >file_name
# 为什么要grep一下呢 因为有时正好遇上ftp那边备份脚本正在备份 这时会生成目录但还没有压缩 
# 如果这个时候你去下载文件很可能下载的是这个目录,所以加个grep可以起到过滤的作用
# 或者ftp那边的目录下还有其它文件 grep一下可以过滤一下
# 当然这个方式仍然不能彻底解决ftp那边正在备份文件的问题
file_name=`cat temp|grep $suffix|tail -1|awk '{print $9}'`
echo $file_name


echo '开始下载文件';
ftp -v -n $IP <<EOF
user $username $password
bin
cd $remotePath
get $file_name 
bye
EOF

echo '删除临时文件';
rm -f temp



endTime=`date +%s`
timeInterval=$(( ($endTime-$startTime)/60 ))
date
echo end at `date -d today +"%Y-%m-%d %T"`... 用时$timeInterval 分钟====================
