#!/bin/bash
# author man003@163.com
# create 20160310114308
# modify 2016-03-18 17:34:57
# version 3
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
# V2 2016-03-14 
    # + 增加判断FTP是否连接正常 解决start at 不输出时间的bug
# V3 2016-03-18 
	# + 如果本地已经存在该文件则不下载
	# + 删除比当前下载文件早n天的文件


IP=10.4.124.166
username=maning
password=1
remotePath=bak-project/svn

localPath=/Users/mang/work/dataBak/svnBak
logFile=bak.log

deleteDays=3


abLogPath=$localPath/$logFile
suffix=zip # 设置压缩包的格式
#shellDirPath=$(cd "$(dirname "$0")"; pwd)
#echo currentPath is $shellDirPath;


# tips: 注如下 反斜杠`` 后面必须有一个空格 否则执行时有可能输出空（我直接运行脚本没问题 放到crontab中出现问题）
# 注 即使我加了空格 以crontab中输出还是没有输出 所以我先把时间放到变量里再输出
echo
startTimeStr=`date -d today +"%Y-%m-%d %T"`
echo start at "$startTimeStr" ====================
date

startTime=`date +%s`
# 切换到本地目标目录 因为ftp get 命令是把文件下载到当前目录
cd $localPath;

# 先测试FTP是否连接成功 如果能连接成功再进行下一步
# tips: 原理 把命令输出到变量里 看输出是否正常 如果出现"230 Logged on" 这样的字样表明登录成功 否则登录失败
status=`
ftp -v -n $IP<<EOF
user $username $password
bin
bye
EOF`


echo $status|grep "230"
if [ $? -eq 0 ]
then
	echo 测试连接成功;
	isConnectOk="true";
else
	echo 测试连接FTP失败;
	echo status如下 $status
	isConnectOk="false";
fi	

# 先从ftp上找出最新的文件 再下载
# 如何找到进阶新的文件呢？ ls 按时间排序 然后tail -1 取出最后一行 这就是最新的文件

if [ $isConnectOk = "true" ]
then
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
	
	#TODO 判断本地是否存在该文件 如果存在则不下载
	if [ -f $file_name ] 
	then
		echo $file_name 文件已经存在 不重复下载
	else
		echo '开始下载文件';
		ftp -v -n $IP <<EOF
		user $username $password
		bin
		cd $remotePath
		get $file_name 
		bye
EOF
	
	# 删除比下载文件早3天的文件
	echo  删除比下载文件早 $deleteDays 天的文件
	touch -r $file_name -d "$deleteDays days ago" time.tmp;
	# 注 如下先把要删除的文件打印出来
	#find . ! -newer time.tmp -name "*.$suffix"|xargs ls -l;
	#find . ! -newer time.tmp -name "*.$suffix"|xargs rm -rf;
	find $localPath ! -newer time.tmp -name "*.$suffix"|xargs ls -l;
	find $localPath ! -newer time.tmp -name "*.$suffix"|xargs rm -rf;
	# 注 为什么不需要删除time.tmp呢 因为小面 ! -newer 会包含当前文件 所以上一句就直接删除了
	# rm -rf time.tmp;
	fi

	echo '删除临时文件';
	rm -f temp

fi

endTime=`date +%s`
timeInterval=$(( ($endTime-$startTime)/60 ))
date
echo end at `date -d today +"%Y-%m-%d %T"` ... 用时$timeInterval 分钟====================
