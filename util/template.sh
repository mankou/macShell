#!/bin/bash
#create by m-ning at 20160728
# desc 这是一个模板 如果想要写脚本 把该脚本拷过去直接写你的逻辑 其已经具备解析命令行、统计运行时长待功能
## 功能1
## 功能2

author=man003@163.com
version=V1-20160728

#==============================TODO==============================
# TODOXXX
	# 说明

# usage 
usage() {
 cat <<EOM
Desc: 这是一个样例
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
# 示例1 -f 选项 选项说明
# 详细说明
#./template.sh -d testDir/

# 输出版本信息
./template.sh  version runtime


# 其它说明
## 如果传入的是绝对路径则返回的也是绝对路径

# ==============================exitcode=========================
##exit 1 未输入NEW_PATH

EOM
exit 0
}

# ==============================脚本技巧点========================



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
IS_OUTPUT_PARSE_PARAMETER=true


#是否创建tmp目录用于存储临时文件
IS_MKDIR_TMP=false

#脚本运行时是否切换到脚本所在路径
# 注 如果切换到脚本所在路径则你使用的相对路径就是以脚本所以路径为准 而不是你当前的路径了
IS_CD_SHELL_PATH=false

#时间戳
datestr=`date "+%Y%m%d%H%M%S"`
datestrFormat=`date "+%Y-%m-%d %H:%M:%S"`

# 当前路径
CURRENT_PATH=`pwd`

# 用于获得脚本所在路径的
# 因为如果你把该脚本加到PATH中然后在其它路径中使用命令 wcm.sh 则使用默认配置文件时会出错
# 注 这里cd pwd是有道理的，如果不加 你有可能获取到 . 
# 当你使用 脚本名或者绝对路径调用脚本时$0是绝对路径 当你使用相对路径调用脚本时$0是相对路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
if [ ${IS_CD_SHELL_PATH}X = "true"X ]
then
	cd $SHELL_PATH
fi

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


#################自定义变量######################

# 默认目标目录的目录名 如为log则会创建 target/log并把文件拷备到这里
DEFAULT_TARGET_FILENAME=log

#########################如上是配置区域#########################################################
# 通用的init方法
function fun_init_common {
    echo
    echo ======================
    echo $datestrFormat
    echo ======================


    # 如果在debugg模式下 则可输出版本 参数解析 运行时间等信息 方便调试
    if [ ${IS_DEBUG}X = "true"X ]
    then
        IS_OUTPUT_VERSION=true
        IS_OUTPUT_PARSE_PARAMETER=true
        IS_OUTPUT_RUNTIME=true
    fi

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


# 初始化自己的变量(这些变量一般程序内部使用 不需要提供给外部)
function fun_init_variable {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null

    echo fun_init_variable 这里定义程序内部使用的变量
    echo

    # 是否删除拷备 一般我们都会压缩所以拷备的文件就没用了可以删除
    isDeleteCopy=true

    # 默认压缩
    isCompress=true
}

# init方法
function fun_init {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null

	fun_init_common
	#如下写自己的init方法
   
    echo
    echo fun_init 这里写自己的初始化方法 如目录不存在新建 


}

# 校验参数
function fun_checkParameter {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null
    
    echo
    echo  fun_checkParameter 这里校验参数 如非空 目录是否存在等
	#if [ -z $CONFIG ]
	#then
	#	# 输出错误信息 如下>&2 将输出重定向到标准出错 
	#	echo [ERR-155] -f 参数值不能为空 >&2
	#	exit 155
	#fi

	#if [ ! -e $CONFIG ]
	#then
	#	echo [ERR-156] 配置文件不存在 $CONFIG >&2
	#	exit 156
	#fi
}

# 输出解析选项的日志函数 以减少重复代码
function fun_OutputOpinion {
    if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] 
	then
		echo "[parse opinion]found the -$1 option,$2"
	fi
}


###  ------------------------------- ###
###  Main script                     ###
###  ------------------------------- ###

# 初始化程序内部的变量
fun_init_variable

# 解析选项
if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] 
then
	echo 正在解析命令行选项 $*
fi
# 将命令行参数放到变量里 以后用 CLP表示 Command line parameters
CLP=$*
#如果某个选项字母后面要加参数则在后面加一冒号：
while getopts d:n:c:s:lhDM: opt
do
  case "$opt" in
     d) fun_OutputOpinion $opt "$OPTARG"
	 	deleteDays=$OPTARG	
		shellFunction="deleteDays";;
		# 注 最后一句必须加两个分号
     n) fun_OutputOpinion $opt "$OPTARG"
	    newestparameterCount=$OPTARG
		shellFunction="retainNewest";;
     s) fun_OutputOpinion $opt "$OPTARG"
		suffix=$OPTARG;;
     l) fun_OutputOpinion $opt "$OPTARG"
		is_list="true";;
     h) fun_OutputOpinion $opt "$OPTARG"
         usage
         ;;
     D) fun_OutputOpinion $opt "$OPTARG"
		#是否debug模式 debug模式下会把执行的exp命令输出来方便测试
		IS_DEBUG=true;;
     M) fun_OutputOpinion $opt "$OPTARG"
		CALLBACK_MESSAGE=$OPTARG;;
     *) fun_OutputOpinion $opt "$OPTARG"
         usage
		exit 148;;
  esac
done

# 解析参数
paramArrayFilter=()
shift $[ $OPTIND -1 ]
PARAMETER_COUNT=1
# 如下把解析的参数都输出来 方便查看
# 有时在参数中既有业务相关的东西 如文件路径从参数输入 你又想通过参数输入其它信息来控制程序则可用如下方式把业务上相关的参数取出来
for param in "$@"
do
	case $param in
		"version" | "VERSION") 
			IS_OUTPUT_VERSION=true;;
		"outputRuntime" |"outputruntime"| "runtime") 
			IS_OUTPUT_RUNTIME=true;;
		*)
          paramArrayFilter=(${paramArrayFilter[*]} $param) 
          ;;
	esac
   PARAMETER_COUNT=$[ $PARAMETER_COUNT+1 ]
done

# 取参数示例 如下示例如何从参数数组中取出某一个元素
# 注 为什么加() 把其变成数组 如果写成paramArray=$@就不是数组了 你就取不出元素了
paramArrayAll=($@);
#deletePath=${paramArrayAll[0]}

# 遍历参数数组 有时需要遍历数组则可用如下方式
echo 遍历paramArrayFilter
for paramFilter in ${paramArrayFilter[@]}
do
    echo $paramFilter
done


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
