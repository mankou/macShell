#!/bin/bash
#create by m-ning at 20160728
# desc 这是一个模板 如果想要写脚本 把该脚本拷过去直接写你的逻辑 其已经具备解析命令行、统计运行时长待功能
## 功能1
## 功能2

author=man003@163.com
version=V1-20160728

#############################使用说明####################################################

#==============================how to use==============================
# 让该脚本有可执行权限 chmod +x ./oracleBak.sh
# 运行该脚本 ./oracleBak.sh

# 示例1 处理目录的相对路径
#./getAbsolutePath.sh -d testDir/
#./getAbsolutePath.sh -d ~/Desktop
# 详细说明

## 示例2 简要说明
# 脚本命令
## 详细说明...


# 其它说明
## 如果传入的是绝对路径则返回的也是绝对路径

# ==============================exitcode=========================
##exit 1 未输入NEW_PATH
##exit 2 如果即没有指定 -d 参数 也没有指定 -f 参数 则报错 因为我无法判断是目录还是文件
##exit 3 如果同时指定了 -d -f 参数 也返回错误
##exit 148 未指定的参数 为什么是148呢 因为404取模256就是148
##exit 155 参数为空 为什么是155呢 因为当时用手机打某一词是923 取模256 就是155 但923代表什么词 忘记了
##exit 155 参数为空 为什么是155呢 因为当时用手机打某一词是923 取模256 就是155 但923代表什么词 忘记了


# ==============================脚本技巧点========================

#==============================todo==============================
# 


# ==============================history=========================
## V1 2016-2-19 V1 初版
	# 说明1
	# 说明2


#########################如下是配置区域#########################################################
##### 系统变量#####

#是否输出脚本运行时间 true表示输出 false表示不输出
IS_OUTPUT_RUNTIME=false

#是否在脚本执行完后输出版本信息 true表示输出 false表示不输出
IS_OUTPUT_VERSION=false

#是否输出解析命令行日志
IS_OUTPUT_PARSE_PARAMETER=false


#是否创建tmp目录用于存储临时文件
IS_MKDIR_TMP=false

#脚本运行时是否切换到脚本所在路径
# 注 如果切换到脚本所在路径则你使用的相对路径就是以脚本所以路径为准 而不是你当前的路径了
IS_CD_SHELL_PATH=false

#时间戳
datestr=`date "+%Y%m%d%H%M%S"`

# 当前路径
CURRENT_PATH=`pwd`

# 用于获得脚本所在路径的，因为如果你把该脚本加到PATH中然后在其它路径中使用命令 wcm.sh 则使用默认配置文件时会出错
# 注 这里cd pwd是有道理的，如果不加 你有可能获取到 . 
# 最好切换到脚本当前目录下 因为有时以crontab中运行有可能不动
# 如你经常将配置文件放在sh同一级目录下  脚本 -f con.config 有可能出错
# 已经测试虽然下面的命令中有cd操作 但我发现其不会改变当前路径
SHELL_PATH=$(cd $(dirname "$0");pwd)

# 用于获得脚本所在路径的
# 因为如果你把该脚本加到PATH中然后在其它路径中使用命令 wcm.sh 则使用默认配置文件时会出错
# 注 这里cd pwd是有道理的，如果不加 你有可能获取到 . 
# 当你使用 脚本名或者绝对路径调用脚本时$0是绝对路径 当你使用相对路径调用脚本时$0是相对路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
# 最好切换到脚本当前目录下 因为有时以crontab中运行有可能不动
# 如你经常将配置文件放在sh同一级目录下  脚本 -f con.config 有可能出错
cd $SHELL_PATH

# 获取脚本名
SHELL_NAME=`basename $0`
# 获取脚本所在父路径
PARENT_PATH=`dirname $SHELL_PATH`;

# 设置环境变量
PATH=$PATH:$PARENT_PATH/util/;


# 依赖的shell 一行一个 如果没有x 权限 自动设置
RELIANT_SH="
	$PARENT_PATH/util/getAbsolutePath.sh
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

TMP_PATH=$SHELL_PATH/tmp

#默认的调用信息 如果不通过-M参数传入调用信息则这里默认为XX
CALLBACK_MESSAGE=XX

#########################如上是配置区域#########################################################
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
	
	# 写日志
	# 调用脚本名称 命令行参数 调用信息和自己想添加的信息(这里写start也可以自己指定)
	writeLog.sh $0 "$CLP" "${CALLBACK_MESSAGE} start"

	#如下是如何在脚本中使用-M参数的示例
	#delete.sh -M "$SHELL_NAME-$CALLBACK_MESSAGE" -n $dateModel_retainCount -o $TMP_PATH/delete.log $1>/dev/null 2>&1

}


# 初始化自己的变量
function fun_init_variable {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null
}

# init方法
function fun_init {
	fun_init_common
	#如下写自己的init方法

	## 自定义变量 或者设置默认值
	#project=tv
	#codePath=/Users/mang/work/code/osc/frontCode/osc-tv-web-20160623-menu-JR0623
}

# 校验参数
function fun_checkParameter {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null

	if [ -z $CONFIG ]
	then
		# 输出错误信息 如下>&2 将输出重定向到标准出错 
		echo [ERR-155] -f 参数值不能为空 >&2
		exit 155
	fi

	if [ ! -e $CONFIG ]
	then
		echo [ERR-156] 配置文件不存在 $CONFIG >&2
		exit 156
	fi
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

# 解析选项
if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] 
then
	echo 正在解析命令行选项 $*
fi
# 将命令行参数放到变量里 以后用 CLP表示 Command line parameters
CLP=$*
#如果某个选项字母后面要加参数则在后面加一冒号：
while getopts d:n:c:s:lDM: opt
do
  case "$opt" in
     d) fun_OutputOpinion $opt $OPTARG
	 	deleteDays=$OPTARG	
		shellFunction="deleteDays";;
		# 注 最后一句必须加两个分号
     n) fun_OutputOpinion $opt $OPTARG
	    newestparameterCount=$OPTARG
		shellFunction="retainNewest";;
     s) fun_OutputOpinion $opt $OPTARG
		suffix=$OPTARG;;
     l) fun_OutputOpinion $opt $OPTARG
		is_list="true";;
     D) fun_OutputOpinion $opt $OPTARG
		#是否debug模式 debug模式下会把执行的exp命令输出来方便测试
		IS_DEBUG=true;;
     M) fun_OutputOpinion $opt $OPTARG
		CALLBACK_MESSAGE=$OPTARG;;
     *) fun_OutputOpinion $opt $OPTARG
		exit 148;;
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

#####################下面写脚本逻辑#####################################
echo
echo 在这里写脚本逻辑
echo



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
