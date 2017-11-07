#!/bin/bash
# create by m-ning at 20160809
# desc 删除某目录下的文件
## 支持 删除N天前文件
## 支持 只保留最近N个最新的文件
## 支持 过滤后缀名 即只有某后缀名的文件才被删除
## 支持 调试模式 只显示要删除的文件 而不实际删除 用于调试
## 支持 -o 参数 将删除的文件放取指定日志文件中方便其它脚本调用写日志

author=man003@163.com
version=V1.3-20171107

#==============================TODO==============================
# -n参数不支持文件名带有空格
	# -n 参数不能删除文件中有空格的文件
	# 但是-d参数支持 因为我用find -print0|xargs -0可解决 
	# 因-n参数中 使用的是awk '{print $9}' 这块还没有很好的解决 所以不支持文件名有空格
	#/Users/mang/AppData/百度云同步盘/mac/bat-mac/util/delete.sh -D -n 1 /Users/mang/Desktop/shell-delete/

# usage 
usage() {
 cat <<EOM
Desc:删除某目录下N天前文件或者只保留最近N个最新的文件
Usage: $SHELL_NAME [options]
  -h |    print help usage      打印usage
  -d |    deleteDays            删除N天前文件
  -n |    newestCount           保留最新的N个文件
  -s |    suffix                后缀
  -r |    isDeleteEmptyDir      删除空目录
  -o |    delete_log            输出日志 常用于嵌入其它脚本中使用
  -D |    IS_DEBUG              debug模式 只输出要删除的文件 但实际上不删除
  -M |    CALLBACK_MESSAGE      调用信息 用于记录调用日志


show some examples
#==============================how to use==============================

# 删除路径最好用绝对路径 相对路径也行 但推荐用绝对路径

# crontab中使用
# 每天4点删除无用的日志 只保留最近的30个
0 4 * * * /home/dxp/shell/util/delete.sh  -n 30  /home/dxp/nohup/dxp >>/home/dxp/nohup/delete.dxp.log 2>&1


# 如下所有命令都可以加上 -D 开启调试选项
# 这样只列出程序要删除的文件但不会真的删除(部署测试时非常有用)
# ./delete.sh -n2 -D testDir

# 示例1 -n选项
# 保留某目录下最新的2个文件或者文件夹  
# ./delete.sh -n2  testDir/


# 示例2 -d选项
# 删除某目录下3天前的文件 
# 注 这里输入N 即会删除N+1天及之前的文件 也即输入2会删除3天前的文件
# 注 在这里输入2 即+2 也即大于2天的文件 因都是整数 也就是3天及3天前的文件
# ./delete.sh -d2 testDir/

# 示例3 -s选项 
# 支持后缀名 保留某目录下 文件名以zip结尾的 2个文件或文件夹 
#./delete.sh -n2 -s zip testDir/
# 示例4 支持后缀名 删除某目录下3天前 并且后缀是zip的 文件
# ./delete.sh -d2 -s zip testDir/


# 示例4 -r选项
# 指定是否删除空目录
# 如上所有命令都支持-r 选项 表示删除文件后 同时删除空目录
# 删除2天前的文件 并且删除空目录
# ./delete.sh -r -d2 testDir/
# 保留某目录下最新的2个文件或者文件夹  并且删除空目录
# ./delete.sh -r n2  testDir/
# 也可单独使用 表示删除空目录
	# ./delete.sh -r testDir/
	# 注 -D 选项与-r选项同时使用时 虽然不会真的删除空目录 但也不会列出要删除的空目录
	# 为什么不能列出呢?因为其调用的deleteEmptyDir.sh是通过循环 删除空目录后 再判断空目录个数 是否继续删除 所以其不能列出具体将要删除哪些目录

# 示例5 -o选项
# 在其它脚本中使用 指定删除日志文件
# 注在其它脚本中调用该脚本时不需要该脚本输出的日志 只想知道删除了哪些文件 如下用-o 参数把删除的文件重定向到某一文件 然后再cat出来可用于写日志等
# 注 如下2>&1是必须的 否则该脚本会输出rm的命令 因为delete.sh中使用了xargs -t 

# 如下三句是代码示例
#delete.sh -n3 -o $localPath/lastDelete.log -s $suffix $localPath >/dev/null 2>&1
# 如下把要删除的文件输出到控制台 方便重定向写日志
#cat $localPath/lastDelete.log

# ==============================exitcode=========================
## 148 未知选项 为什么起148呢 因为148+256=404
## 1 删除路径为空

EOM
exit 0
}

# ==============================脚本技巧点========================
## 同时处理命令行选项和参数
## ls -tl 按修改时间倒序排序
## 如下处理后缀名的手法 原来ls *zip -tl 可以 但ls *zip -tl 路径就不行 所以我用grep了
	## ls -tl $deletePath|sed -n '2,$p'|grep "$suffix\$">$BASE_PATH/ls.temp
## 注 如下sed -n "" 必须是双引号 不能是单引号 因为你里面引用了变量
	## sed -n "$[newestCount+1],\$p" $BASE_PATH/ls.temp|tee $BASE_PATH/delete.temp



# ==============================history=========================
# 20160810 V1 
	# 初版
# 20161124 V1.1 
	# 增加删除空目录功能、原来解析选项的代码用公用函数代替
# 20161130 V1.2 
	# 规范代码 加入-V -M 选项、一些公用代码纳入函数中处理 如init checkParameter
# 20161208 V1.2
	# fix 修复-d选项不能删除带有空格的文件的bug(注-n选项也有这个问题未解决)
	# * 支持version/outputRntime参数 把原来的-V选项去掉
# 20161208 V1.3
	# * -r选项可单独使用删除空目录 原来必须和-d -n选项同时使用才行 
# 20171107 V1.3-20171107
   # * fix bug 解决删除N天前文件 如果未找到文件 则会列出当前路径下所有文件的bug 

#########################如下是配置区域#########################################################

#是否输出脚本运行时间 true表示输出 false表示不输出
IS_OUTPUT_RUNTIME=false

#是否在脚本执行完后输出版本信息 true表示输出 false表示不输出
IS_OUTPUT_VERSION=false

#时间戳
datestr=`date "+%Y%m%d%H%M%S"`
datestrFormat=`date "+%Y-%m-%d %H:%M:%S"`

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
	$PARENT_PATH/util/getAbsolutePath.sh
	$PARENT_PATH/util/deleteEmptyDir.sh
	$PARENT_PATH/util/writeLog.sh
"
#$PARENT_PATH/util/tp.sh

for rs in $RELIANT_SH
do
	# 如果没有可执行权限 把权限加上
	if [ ! -x $rs ]; then
		chmod +x $rs
	fi
done

#########################如上是配置区域#########################################################
# 通用的init方法
function fun_init_common {
    echo
    echo ======================
    echo $datestrFormat
    echo ======================

	if [ ${IS_OUTPUT_RUNTIME}X = "true"X ]
	then
		#echo start at `date -d today +"%Y-%m-%d %T"`====================
		echo start at `date  +"%Y-%m-%d %H:%M:%S"`====================
		startTime=`date +%s`
	fi

	if [ ! -d $TMP_PATH ]
	then
		echo $TMP_PATH 目录不存在 将新建
		mkdir $TMP_PATH
	fi

	# 写运行日志
	writeLog.sh $0 "$CLP" "${CALLBACK_MESSAGE} start"
}

# 初始化自己的变量
function fun_init_variable {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null

	# 是否删除临时文件 true 表示删除 false表示不删除
	IS_DELETE_TEMP=false
	IS_CLEAN_TEMP=true

    # 如果tmp目录不存在 则新建
    TMP_PATH=$BASE_PATH/tmp

	#定义临时文件路径
	lsTmp=$TMP_PATH/${SHELL_NAME}_ls.tmp
	lsAwkTmp=$TMP_PATH/${SHELL_NAME}_ls_awk.tmp
	deleteTmp=$TMP_PATH/${SHELL_NAME}_delete.tmp
}


# init方法
function fun_init { 
	fun_init_common
}

# 参数校验
function fun_checkParameter {
	if [ -z $deletePath ]
	then
		echo [error]删除路径不能为空
		exit 1
	else
		echo [parse parameter]删除路径 $deletePath
		deletePath=`getAbsolutePath.sh -fc $deletePath`
		echo [parse parameter]处理相对路径后 $deletePath
	fi

    [ ! -e $deletePath ] && echo [warn]目录不存在,直接退出 $deletePath && exit 2

}

# 输出解析选项的日志函数 以减少重复代码
function fun_OutputOpinion {
    if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] 
	then
		echo "[parse opinion]found the -$1 option,$2"
	fi
}

# 清除空目录
function fun_deleteEmptyDir {
	if [ ${isDeleteEmptyDir}X = "true"X ]
	then
		echo 删除空目录... |tee -a $deleteTmp
		if [ ! ${IS_DEBUG}X = "true"X ]
		then
			deleteEmptyDir.sh $1 |tee -a $deleteTmp	
		fi
	fi
}


###  ------------------------------- ###
###  Main script                     ###
###  ------------------------------- ###


# 初始化变量
fun_init_variable

# 将命令行参数放到变量里 以后用 CLP表示 Command line parameters
CLP=$*
#echo 正在解析命令行选项 $*
while getopts d:n:s:o:rhDVM: opt
do
  case "$opt" in
     d) fun_OutputOpinion $opt $OPTARG
	 	deleteDays=$OPTARG	
		shellFunction="deleteDays";;
		# 注 最后一句必须加两个分号
     n) fun_OutputOpinion $opt $OPTARG
	    newestCount=$OPTARG
		shellFunction="retainNewest";;
     s) fun_OutputOpinion $opt $OPTARG
		suffix=$OPTARG;;
     r) fun_OutputOpinion $opt $OPTARG
		isDeleteEmptyDir=true;;
     o) fun_OutputOpinion $opt $OPTARG
		 # 将delete_log处理成绝对路径 并且如果父级目录不存在则创建
		delete_log=`getAbsolutePath.sh -fc $OPTARG`
		echo [parse parameter]处理相对路径后 $delete_log;;
     h) fun_OutputOpinion $opt $OPTARG
         usage
         ;;
     D) fun_OutputOpinion $opt $OPTARG
		IS_DEBUG=true;;
     M) fun_OutputOpinion $opt $OPTARG
		# 用于写日志用
		CALLBACK_MESSAGE=$OPTARG;;
     *) fun_OutputOpinion $opt $OPTARG
         usage
		exit 148;;
  esac
done

# 取出要删除的路径 这里以参数的形式输入(非选项)
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
# 只取出数组的第一个元素
# 注 为什么加() 把其变成数组 如果写成paramArray=$@就不是数组了 你就取不出元素了
# 注 因为我不会一次把元素取出来 所以用了2句 如本想以 ${$@[0]}
paramArray=($@);
deletePath=${paramArray[0]}

# 初始化
fun_init

#参数校验
fun_checkParameter

## 这里是脚本逻辑

echo 要删除的文件如下
# 判断是deleteDays功能还是retainNewest功能
if [ ${shellFunction}X = "deleteDays"X ]
then
	#echo "find $localPath -name "*$suffix" -mtime +"$deleteDays"|xargs ls -l";
	# 注不要写成 find . -name *.* 这样只能查temp.out这样的文件 但查不出temp这样的文件
	# 如下find -print0|xargs -0 是为了处理文件名有空格的文件

    # 先判断下是否找到文件 如果找到了再输出 主要是解决如下的bug
    # 如果find未查出文件 则会传一个空给ls -l 则其会列出当前路径下所有的文件
    # 虽然实际并没有删除文件 因为 rm -rf 不加参数什么也删除不了,但写的日志不对会对你实际运行时产生误导
    findResult=`find $deletePath -name "*$suffix" -mtime +"$deleteDays" -print0`
    if [ ! -z $findResult ]
    then
        find $deletePath -name "*$suffix" -mtime +"$deleteDays" -print0|xargs -0 ls -l|tee $deleteTmp;
        # 如果输入-l参数 则只列出要删除的内容 不实际删除 免得删除错了
        if [ ! ${IS_DEBUG}X = "true"X  ]
        then
            find $deletePath -name "*$suffix" -mtime +"$deleteDays" -print0|xargs -0 -n5 rm -rf;
        fi
    else
        echo "无可删除的文件"
    fi

elif [ ${shellFunction}X = "retainNewest"X ]
then
	#echo "retainNewest" 功能";
	# 只保留最近的N个文件
	# 先把文件找出来 按mtime倒序排序 放到临时文件中
	# 删除第N+1行到最后一行中的文件
	
	# 如下 ls -lt 按时间逆序排 最新的文件在前面
	# sed -n '2,$p' 把第2行到最后一行输出到临时文件 因为ls -lt输出如下 所以要用sed处理下
	#total 0
	#-rw-r--r-- 1 mang staff 0 Aug  9 17:27 2.zip
	#-rw-r--r-- 1 mang staff 0 Aug  9 17:27 3.zip
	ls -tl $deletePath|sed -n '2,$p'|grep "$suffix\$">$lsTmp

	#处理lsTmp 把文件名处理成绝对路径 这样下面删除时就不需要切换到该目录下了
	# 注 -v 是传递参数的方式 p"/"$9 其中"/"是print中连接字符串的方式
	cat $lsTmp|awk -v p=$deletePath '{print $1,$2,$3,$4,$5,$6,$7,$8,p"/"$9}' > $lsAwkTmp

	# 注 如下sed -n "" 必须是双引号 不能是单引号 因为你里面引用了变量
	# 注 如下使用tee接t型管 是为了把删除的数据输出的标准输出中
	sed -n "$[newestCount+1],\$p" $lsAwkTmp|tee $deleteTmp
    echo

	# 如果输入-D参数 则只列出要删除的内容 不实际删除 免得删除错了
	# 这里如果没有输入-D参数 则真的删除
	if [ ! ${IS_DEBUG}X = "true"X ]
	then
		#cat $BASE_PATH/delete.temp
		# 注如下-t 是为了把命令输出出来
		# -n5 是每5个删除一下 免得要删除的文件太多出现问题
		# awk '{print $9}' 输出第9列
		# 注 如下-t 会输出实际的命令 其输出在错误输出中 在其它脚本中调用该脚本你可能想屏蔽该脚本的输出有可能会用到
		# 注 如下第一句不能屏蔽输出 第二句可以
		#cat $deleteTmp|awk '{print $9}'|xargs -t -n5 rm -rf >/dev/null
		#cat $deleteTmp|awk '{print $9}'|xargs -t -n5 rm -rf 2>/dev/null
		cat $deleteTmp|awk '{print $9}'|xargs -t -n5 rm -rf
	fi
fi


# 清除空目录
fun_deleteEmptyDir $deletePath

# 如果用户输入了删除日志路径 则这里只把要删除的文件写入日志文件方便其它程序调用
# XXX 我不能解释为什么用 -n不对 而用 ! -z 是对的呢
#  如果我换成-n 用如下命令就会出错
#./delete.sh -n2 -l testDir/

#if [ -n $delete_log ]
if [ ! -z $delete_log ]
then
	cat $deleteTmp>$delete_log
fi

# 判断是否删除临时文件
if [ ${IS_DELETE_TEMP}X = "true"X ]
then
	rm -rf $TMP_PATH
else
    # 如果不删除临时文件夹 则判断是否要清空临时文件夹
    if [ ${IS_CLEAN_TEMP}X = "true"X ]
    then
        rm -rf $TMP_PATH/*
    fi
fi

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
