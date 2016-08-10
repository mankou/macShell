#!/bin/bash
# create 20160310114308
# modify 2016-03-31 15:34:20
# desc 从ftp上下载最新文件的脚本
	# 背景说明 需要从ftp服务器上取最新的备份文件 所以想写一个脚本自动从ftp上取最新的文件 注这里只取最新的1个文件
	# 说明：该脚本中所需要的ftp相关信息可以以命令行的形式传入 也可以改脚本中的默认配置直接运行该脚本也可。具体使用参见下面的how to use部分


# 注如下是个变量 程序运行时可以输出
author=man003@163.com
version=V5\(2016-03-31\)

# =============================how to use==============================
# 使用前提
  # 具有可执行权限 chmod +x autoGetFileFromFTP.sh
  # 有ftp服务器及相关帐号

# 命令行选项如何使用?
	# autoGetFileFromFTP.sh -u maning/1@10.4.124.166 -r bak-project/svn -l /Users/mang/work/dataBak/svnBak -s zip -d 3  >>/Users/mang/work/dataBak/svnBak/bak.log 2>&1 
	# 注 该脚本里设置了默认的参数 如果不想输入大长串的命令行选择也可在脚本中设置默认的参数 在不使用命令行参数的情况下就走默认的参数. 修改默认参数后可直接使用 autoGetFileFromFtp.sh 这样的命令运行

# 如何在crontab中使用
	# 每周1 2 3 4 5 的16:16执行从ftp取最新svn备份的脚本
	# 16 16 * * 1,2,3,4,5 /Users/mang/AppData/快盘/mac/bat-mac/autoGetFileFromFTP/autoGetFileFromFTP.sh -u maning/1@10.4.124.166 -r bak-project/svn -l /Users/mang/work/dataBak/svnBak -s zip -d 3  >>/Users/mang/work/dataBak/svnBak/bak.log 2>>&1

#==============================todo==============================
# 放到github上 用mac的git命令放
# 删除比下载文件早3天的文件 目前crontab中不支持touch -d  date -d  这样的-d参数
# 默认连接3次：如果当时未连接上，则10分钟后重新连接下载 

# ==============================history ==============================
# V1.0 初步完成脚本
# V2 2016-03-14 
	# + 增加判断FTP是否连接正常 解决start at 不输出时间的bug(后来发现没有解决)
# V3 2016-03-18 
	# + 如果本地已经存在该文件则不下载
	# + 删除比当前下载文件早n天的文件
# V4 2016-03-30
    # + 支持命令行选项
# V5 2016-03-31
	# fix 修复如果取出的最新文件名为空 提示信息错误容易误导用户的bug
	# * 所有参数都走默认配置 如果不通过命令行指定参数就走默认配置。这样做的好处是直接敲脚本名称就运行了 不需要写很长的参数
	# + 增加版本说明 在程序运行最后输出

###############################默认配置################################################
# 如下的配置默认值 如果脚本没有加选项设置相关值就用配置值即可

# FTP ip 用户名 密码
IP=192.168.1.1
username=maning
password=1

# FTP路径 即要下载的文件在ftp的那个路径下
remotePath=bak-project/svn/

# 本地路径 即要将文件下载到本地哪个路径下
localPath=/Users/mang/work/dataBak/svnBak

# 默认删除几天前的备份
deleteDays=3 

# 设置压缩包的格式 默认只取这种压缩包后缀的文件
#suffix=zip 
	# 注 如果设置成这样则表示全部文件 因为 cat temp|grep ".*" 会把全部行取出来  注 必须用引号把.*括起来 我试了
	# 如果是 cat temp|grep zip 会把包含zip的行取出来
#suffix=.* 
suffix=zip


# 如果连接不上重新连接的次数
reConnect=3

# 重新连接的时间间隔 默认10分钟
reConnectInterval=10

###############################默认配置################################################

# 解析命令选项
echo 正在解析命令行选项......
while getopts :u:r:l:s:d: opt
do
  case "$opt" in
     u) echo "found the -u option,$OPTARG"
		# 解析IP、用户名、密码 字符串格式如 mang/1@192.168.1.1
		IP=`echo $OPTARG|cut -d@ -f2`;
		username=`echo $OPTARG|cut -d/ -f1`;
		password=`echo $OPTARG|cut -d/ -f2|cut -d@ -f1`;;
		# 注 最后一句必须加两个分号
     r) echo "found the -r option,$OPTARG"
		 remotePath=$OPTARG;;
     l) echo "found the -l option,$OPTARG"
		 localPath=$OPTARG;;
     s) echo "found the -s option,$OPTARG"
		 suffix=$OPTARG;;
     d) echo "found the -d option,$OPTARG"
		 deleteDays=$OPTARG;;
     *) echo "unknown option:$opt"
		 exit 404;;
  esac

done



#shellDirPath=$(cd "$(dirname "$0")"; pwd)
#echo currentPath is $shellDirPath;


# tips: 注如下 反斜杠`` 后面必须有一个空格 否则执行时有可能输出空（我直接运行脚本没问题 放到crontab中出现问题）
# 注 即使我加了空格 以crontab中输出还是没有输出 所以我先把时间放到变量里再输出
echo
# TODO 如下-d 参数在crontab中不认 但是直接执行脚本认 所以目前也没有想到好办法
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

# TODO 把测试连接的代码写成循环 如果连接上就跳出来 如果连接不上就循环等待
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
	echo '正在从FTP取出最新的文件的文件名......';
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
	echo "取得FTP上的文件列表如下";
	cat temp;
	# 注:为什么要用{suffix} 这样把一个变量括起来
	# 注：最后的$表示以该后缀名结尾
	file_name=`cat temp|grep ".${suffix}$"|tail -1|awk '{print $9}'`
	echo 分析出的最新的文件名为: $file_name
	
	# 判断本地是否存在该文件 如果存在则不下载
	# 注：为什么要用 -z 呢？因为有可能file_name为空 我测试了如果其为空 下面的-f $file_name 判断也为true 所以先判断变量是否为空
	if [ -z $file_name ]
	then
		echo 未找到后缀是$suffix 的文件 请查看路径是否有误或者后缀是否有误
	elif [ -f $file_name ] 
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
	echo  删除比下载文件早 $deleteDays 天的文件......

	# TODO 如下-d 参数 在crontab中不认 但是直接执行脚本可以运行  目前没有解决办法
	#touch -r $file_name -d "$deleteDays days ago" time.tmp;
	# 注 如下先把要删除的文件打印出来
	#find $localPath ! -newer time.tmp -name "*.$suffix"|xargs ls -l;
	#find $localPath ! -newer time.tmp -name "*.$suffix"|xargs rm -rf;
	# 注 为什么不需要删除time.tmp呢 因为小面 ! -newer 会包含当前文件 所以上一句就直接删除了
	# rm -rf time.tmp;

	# XXX 因为上面的代码touch -d 参数在crontab中不认 所以上面删除N天前的代码有问题 所以我先用下面的代码将就
	echo 因crontab中不认touch -d命令 先用变通的方法删除N天前的文件
	# 注 可通过如下的方式查看最后运行的命令 以快速查找错误
	echo "find $localPath -name "*$suffix" -mtime +"$deleteDays"|xargs ls -l";
	# 注不要写成 find . -name *.* 这样只能查temp.out这样的文件 但查不出temp这样的文件
	find $localPath -name "*$suffix" -mtime +"$deleteDays"|xargs ls -l;
	find $localPath -name "*$suffix" -mtime +"$deleteDays"|xargs rm -rf;

	fi

	echo 删除临时文件......
	rm -f temp

fi

endTime=`date +%s`
timeInterval=$(( ($endTime-$startTime)/60 ))
date
echo end at `date -d today +"%Y-%m-%d %T"` ... 用时$timeInterval 分钟====================
echo *************develop by ${author} ${version}************;
