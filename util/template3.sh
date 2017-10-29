#!/bin/bash
# create by m-ning at 20171028
# desc 这是一个模板脚本 20171028来自pinga.sh
# 背景
    # 因template.sh 太复杂 后来其于source 文件的技巧开发了template2.sh通过默认配置文件修改变量值
    # 但template2.sh 太简单 所以开发了template3.sh 既能通过命令行参数修改变量值 也能通过默认配置文件修改变量值 并且删除了template.sh中一些认为没用的脚本

author=man003@163.com
version=1.0-20171028

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
## V1-20171028
    # 说明1
    # 说明2


#########################如下是配置区域#########################################################
##### 系统变量#####

# 是否静默模式 在静默模式下不输出日志 只打印数据方便接管道进行进一步的处理
IS_SILENT=true

#脚本运行时是否输出当前时间 以方便你看日志,另在静默模式下该选项没用
IS_OUTPUT_RUN_START_DATE=true

#是否输出脚本运行时长 可用于查看脚本运行多久,另在静默模式下该选项没用
IS_OUTPUT_RUNTIME=false

#是否输出解析命令行日志 常用于开发期,另在静默模式下该选项没用
IS_OUTPUT_PARSE_PARAMETER=false

#脚本运行时是否切换到脚本所在路径
# 注 如果切换到脚本所在路径则你使用的相对路径就是以脚本所在路径为准，而不是你当前的路径了
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

# 获取脚本名
SHELL_NAME=`basename $0`
# 获取脚本所在父路径
PARENT_PATH=`dirname $SHELL_PATH`;

# 脚本不包括后缀的文件名 如xx.sh 则文件名为 xx
SHELL_NAME0=${SHELL_NAME%.*}

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


#是否创建tmp目录用于存储临时文件
IS_MKDIR_TMP=true
TMP_PATH=$SHELL_PATH/tmp
#是否删除临时文件
IS_DELETE_TMP=true

#默认的调用信息 如果不通过-M参数传入调用信息则这里默认为XX
CALLBACK_MESSAGE=XX


#########################如上是配置区域#########################################################
# 通用的init方法
function fun_init_common {

    if [ ${IS_OUTPUT_RUN_START_DATE}X = "true"X ] && [ ! ${IS_SILENT}X = "true"X ]
    then
        echo
        echo ======================
        echo $datestrFormat
        echo ======================
    fi

    # 如果在debug模式下 则可输出版本 参数解析 运行时间等信息 方便调试
    if [ ${IS_DEBUG}X = "true"X ]
    then
        IS_OUTPUT_PARSE_PARAMETER=true
        IS_OUTPUT_RUNTIME=true
    fi

	if [ ${IS_CD_SHELL_PATH}X = "true"X ]
	then
		cd $SHELL_PATH
	fi
    
	if [ ${IS_OUTPUT_RUNTIME}X = "true"X ] && [ ! ${IS_SILENT}X = "true"X ]
	then
		echo start at `date  +"%Y-%m-%d %H:%M:%S"`====================
		startTime=`date +%s`
	fi

	# 如果tmp目录不存在 则新建
	if [ ${IS_MKDIR_TMP}X = "true"X ] && [ ! -d $TMP_PATH ]
	then
		mkdir $TMP_PATH
	fi
	
	# 写日志
	# 调用脚本名称 命令行参数 调用信息和自己想添加的信息(这里写start也可以自己指定)
	writeLog.sh $0 "$CLP" "${CALLBACK_MESSAGE} start"

	#如下是如何在脚本中使用-M参数的示例
	#delete.sh -M "$SHELL_NAME-$CALLBACK_MESSAGE" -n $dateModel_retainCount -o $TMP_PATH/delete.log $1>/dev/null 2>&1

}


# 输出解析选项的日志函数 以减少重复代码
function fun_OutputOpinion {
    if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] && [ ! ${IS_SILENT}X = "true"X ]
	then
		echo "[parse opinion]found the -$1 option,$2"
	fi
}

# 输出版本信息
function fun_showVersion {
    echo *************develop by ${author} ${version}************;
    exit 0
}

[ $# -eq 0 ] && usage


###  ------------------------------- ###
###  Main script                     ###
###  ------------------------------- ###

#################自定义变量######################
# 如下定义一些默认的参数

# 结果文件路径
target_file_path=$CURRENT_PATH/${SHELL_NAME0}.result

# 分析的日志文件后缀名
suffix=*.log

# 用于下面grep时提取 时间用的模式
pattern_line="ping脚本开始分析"

# 结果文件中使用的日志文件名是否使用短名 即只有文件名不包括路径 免得太长你不好看日志
is_short_file_name=true


CONFIG_FILE=$SHELL_PATH/$SHELL_NAME0.config
[ -e $CONFIG_FILE ] && . $CONFIG_FILE

fun_init_common


[ ! -d $TMP_PATH ] && mkdir -p $TMP_PATH

# 解析选项
[ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] && [ ! ${IS_SILENT}X = "true"X ] && echo 正在解析命令行选项 $*
# 将命令行参数放到变量里 以后用 CLP表示 Command line parameters
CLP=$*
#如果某个选项字母后面要加参数则在后面加一冒号：
while getopts s:t:vhDM: opt
do
  case "$opt" in
     s) fun_OutputOpinion $opt "$OPTARG"
	 	suffix=$OPTARG;;
     t) fun_OutputOpinion $opt "$OPTARG"
		target_file_path=$OPTARG;;
     v) fun_OutputOpinion $opt "$OPTARG"
        fun_showVersion;;
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
# 如下整理出需要分析哪些文件 将文件路径存储在 timpFile1中
for paramFilter in ${paramArrayFilter[@]}
do
    echo $paramFilter
done


#####################下面写脚本逻辑#####################################
echo
echo 一般在在这里写脚本逻辑
echo 但有时需要用到命令行参数 所以在命令行参数阶段脚本逻辑就开始了



#####################上面写脚本逻辑#####################################


[ ${IS_DELETE_TMP}X = "true"X ] && rm -rf $TMP_PATH

[ ! ${IS_SILENT}X = "true"X ] && echo **ok!!! result saved in follow path
[ ! ${IS_SILENT}X = "true"X ] && echo $target_file_path

#####################上面写脚本逻辑#####################################

# 输出脚本运行时间信息
if [ ${IS_OUTPUT_RUNTIME}X = "true"X ] && [ ! ${IS_SILENT}X = "true"X ]
then
	echo
	endTime=`date +%s`
	timeInterval=$(( ($endTime-$startTime)/60 ))
	echo end at `date  +"%Y-%m-%d %H:%M:%S"`... 用时$timeInterval 分钟====================
	#echo end at `date -d today +"%Y-%m-%d %T"`... 用时$timeInterval 分钟====================
fi
