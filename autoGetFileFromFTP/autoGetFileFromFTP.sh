#!/bin/bash
# create 20160310114308
# desc 从ftp上下载最新文件的脚本
	# 背景说明 需要从ftp服务器上取最新的备份文件 所以想写一个脚本自动从ftp上取最新的文件 注这里只取最新的1个文件
	# 说明：该脚本中所需要的ftp相关信息可以以命令行的形式传入 也可以改脚本中的默认配置直接运行该脚本也可。具体使用参见下面的how to use部分


author=man003@163.com
version=V7-20171110

# =============================how to use==============================
usage(){
cat <<EOM
Desc: 从ftp上下载最新文件的脚本
Usage: $SHELL_NAME [options]
    -h |    print help usage
    -u |    username/password@ip
    -r |    remotePath
    -l |    localPath
    -s |    suffix
    -d |    deleteDays 

# 使用前提
    # 部署机器上已安装ftp客户端 能执行ftp命令
    # 具有可执行权限 chmod +x autoGetFileFromFTP.sh
    # 有ftp服务器及相关帐号

# 命令行选项如何使用?
    # autoGetFileFromFTP.sh -u username/password@192.168.1.2 -r bak-project/svn -l /Users/mang/work/dataBak/svnBak -s zip -d 3  >>/Users/mang/work/dataBak/svnBak/bak.log 2>&1 
    # 注 该脚本里设置了默认的参数 如果不想输入大长串的命令行选择也可在脚本中设置默认的参数 在不使用命令行参数的情况下就走默认的参数. 修改默认参数后可直接使用 autoGetFileFromFtp.sh 这样的命令运行

# 如何在crontab中使用
    # 每周1 2 3 4 5 的16:16执行从ftp取最新svn备份的脚本
    # 16 16 * * 1,2,3,4,5 /Users/mang/work/workData/shell/bat-mac/autoGetFileFromFTP/autoGetFileFromFTP.sh -u username/password@192.168.1.1 -r bak-project/svn -l /Users/mang/work/dataBak/svnBak -s zip -d 3  >>/Users/mang/work/dataBak/svnBak/bak.log 2>&1

EOM
exit 0
}
#==============================todo==============================
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
# V6 20160810
	# 采用delete.sh删除旧文件 支持保留最近N个文件的功能 原来是删除N天前的文件 这样的话如果周六周日不备份 周一再备份时就不能保证保留最近N个文件的功能
# V7 20161130
	# 规范代码 
		# 用一些函数代替原来的写法 如init check_parameter 
		# 采用参数version outputRuntime控制是否输出版本信息 运行时间 
		# 采用writeLog.sh写日志
# V7 20171110
    # * 添加-h选项，并且将使用说明纳入usage函数中 方便打印使用说明
    # fix 修复如果本地目录不存在 报找不到目录的错误 

###############################默认配置################################################

##### 系统变量#####

#是否输出脚本运行时间 true表示输出 false表示不输出
IS_OUTPUT_RUNTIME=false

#是否在脚本执行完后输出版本信息 true表示输出 false表示不输出
IS_OUTPUT_VERSION=false

#是否输出解析命令行日志
IS_OUTPUT_PARSE_PARAMETER=false

# 用于获得脚本所在路径的，因为如果你把该脚本加到PATH中然后在其它路径中使用命令 wcm.sh 则使用默认配置文件时会出错
# 注 这里cd pwd是有道理的，如果不加 你有可能获取到 . 
BASE_PATH=$(cd $(dirname "$0");pwd)
# 获取脚本名
SHELL_NAME=`basename $0`
PARENT_PATH=`dirname $BASE_PATH`;

# 设置环境变量
PATH=$PATH:$PARENT_PATH/util/;

# 依赖的shell 一行一个 如果没有x 权限 自动设置
RELIANT_SH="
	$PARENT_PATH/util/delete.sh
	$PARENT_PATH/util/writeLog.sh
"
for rs in $RELIANT_SH
do
	# 如果没有可执行权限 把权限加上
	if [ ! -x $rs ]; then
		chmod +x $rs
	fi
done

#默认的调用信息 如果不通过-M参数传入调用信息则这里默认为XX
CALLBACK_MESSAGE=XX


###############################函数################################################
# 通用的init方法
function fun_init_common {
	if [ ${IS_CD_SHELL_PATH}X = "true"X ]
	then
		cd $SHELL_PATH
	fi

	if [ ${IS_OUTPUT_RUNTIME}X = "true"X ]
	then
		echo start at `date  +"%Y-%m-%d %H:%M:%S"`====================
		startTime=`date +%s`
	fi

	# 如果tmp目录不存在 则新建
	if  [ ${IS_MKDIR_TMP}X = "true"X ] && [ ! -d $TMP_PATH ]
	then
		echo $TMP_PATH 目录不存在 将新建
		mkdir $TMP_PATH
	fi

	# 调用脚本名称 命令行参数 调用信息和自己想添加的信息(这里写start也可以自己指定)
	writeLog.sh $0 "$CLP" "${CALLBACK_MESSAGE} start"

}

# 初始化自己的变量
function fun_init_variable {
	# FTP ip 用户名 密码
	IP=192.168.1.1
	username=maning
	password=1

	# FTP路径 即要下载的文件在ftp的那个路径下
	remotePath=bak-project/svn/

	# 本地路径 即要将文件下载到本地哪个路径下
	localPath=/Users/mang/work/dataBak/svnBak

	# 默认删除几天前的备份
	# 从20160810 V6版本该参数变成保留N个文件的意思 而不是删除N天前的备份的意思
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

}

# init方法
function fun_init {
	fun_init_common
	#如下写自己的init方法

}

# 校验参数
function fun_checkParameter {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null
}

# 输出解析选项的日志函数 以减少重复代码
function fun_OutputOpinion {
    if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] 
	then
		echo "[parse opinion]found the -$1 option,$2"
	fi
}

# 初始化自己的变量
fun_init_variable

# 将命令行参数放到变量里 以后用 CLP表示 Command line parameters
CLP=$*
# 解析命令选项
while getopts :u:r:l:s:d:DM: opt
do
  case "$opt" in
     u) fun_OutputOpinion $opt $OPTARG
		# 解析IP、用户名、密码 字符串格式如 mang/1@192.168.1.1
		IP=`echo $OPTARG|cut -d@ -f2`;
		username=`echo $OPTARG|cut -d/ -f1`;
		password=`echo $OPTARG|cut -d/ -f2|cut -d@ -f1`;;
		# 注 最后一句必须加两个分号
     r) fun_OutputOpinion $opt $OPTARG
		 remotePath=$OPTARG;;
     l) fun_OutputOpinion $opt $OPTARG
		 localPath=$OPTARG;;
     s) fun_OutputOpinion $opt $OPTARG
		 suffix=$OPTARG;;
     d) fun_OutputOpinion $opt $OPTARG
		 deleteDays=$OPTARG;;
     D) fun_OutputOpinion $opt $OPTARG
		#是否debug模式 debug模式下会把执行的exp命令输出来方便测试
		IS_DEBUG=true;;
     M) fun_OutputOpinion $opt $OPTARG
		CALLBACK_MESSAGE=$OPTARG;;
     h) fun_OutputOpinion $opt $OPTARG
		usage;;
     *) fun_OutputOpinion $opt $OPTARG
		 usage;;
  esac
done

# 解析参数
shift $[ $OPTIND -1 ]
PARAMETER_COUNT=1
# 如下把解析的参数都输出来 方便查看
for param in "$@"
do
	case $param in
		"version" | "VERSION") 
			IS_OUTPUT_VERSION=true;;
		"outputRuntime") 
			IS_OUTPUT_RUNTIME=true;;
		*) ;;
	esac
   PARAMETER_COUNT=$[ $PARAMETER_COUNT+1 ]
done

# 取参数示例 如下只取出数组的第一个元素
# 注 为什么加() 把其变成数组 如果写成paramArray=$@就不是数组了 你就取不出元素了
# 注 因为我不会一次把元素取出来 所以用了2句 如本想以 ${$@[0]}
paramArray=($@);
#deletePath=${paramArray[0]}

# 校验参数
fun_checkParameter
# 初始化
fun_init


# 如下写脚本逻辑

# 切换到本地目标目录 因为ftp get 命令是把文件下载到当前目录
[ ! -d $localPath ] && mkdir -p $localPath
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
# 如何找到最新的文件呢？ ls 按时间排序 然后tail -1 取出最后一行 这就是最新的文件
# 注 20160811发现ftp上 ls -lt 是按正序排序的 而在你的mac上 ls -lt是按逆序排序的

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

	echo 保留最近${deleteDays}个版本的文件 如下是删除的文件
	#echo "delete.sh -n3 -o $localPath/lastDelete.log -s $suffix $localPath >/dev/null"
	#delete.sh -n3 -o $localPath/lastDelete.log -s $suffix $localPath >/dev/null 2>&1
	# 如下使用$PARENT_PATH 是为了以后换网盘路径不影响这里
    
    [ ! -d ${PARENT_PATH}/util/log ] && mkdir -p ${PARENT_PATH}/util/log

	delete.sh -M "$SHELL_NAME-$CALLBACK_MESSAGE" -n${deleteDays} -o $localPath/lastDelete.log -s $suffix $localPath >>$PARENT_PATH/util/log/delete.sh_autoGetFileFromFTP.log 2>&1

	# 如下把要删除的文件输出到控制台 方便重定向写日志
	cat $localPath/lastDelete.log

	fi

	echo 删除临时文件......
	rm -f temp

fi

#####################上面写脚本逻辑#####################################
# 输出脚本运行时间信息
if [ ${IS_OUTPUT_RUNTIME}X = "true"X ] 
then
	echo
	endTime=`date +%s`
	timeInterval=$(( ($endTime-$startTime)/60 ))
	echo end at `date  +"%Y-%m-%d %H:%M:%S"`... 用时$timeInterval 分钟====================
	#echo end at `date -d today +"%Y-%m-%d %T"`... 用时$timeInterval 分钟====================
fi
# 输出版本信息
if [ ${IS_OUTPUT_VERSION}X = "true"X ]
then
	echo *************develop by ${author} ${version}************;
fi
