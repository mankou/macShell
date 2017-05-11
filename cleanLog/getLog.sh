#!/bin/bash
# create by m-ning at 2017-04-27
# Desc: 从多个目录中取出日志并压缩成压缩包 常与cleanLog.sh配合使用

author=man003@163.com
version=V1-20170501

#==============================TODO==============================
# TODOXXX
	# 支持 -n 选项 取最新的N个文件

# usage 
usage() {
 cat <<EOM
Desc: 从多个目录中拷备指定日志到目标目录,并打成压缩包,以达到快速从服务器上取日志的目的,常与cleanLog.sh配合使用
Usage: $SHELL_NAME [options]
  -h |    print help usage      打印usage
  -s |    fileNameStr           要查找的文件名
  -t |    target                目标路径
  -T |    DEFAULT_TARGET_FILENAME   目标路径目录名 默认名是log 可通过该参数修改
  -f |    configFile            配置文件路径(路径写在配置文件中)
  -F |    shoftConfigFile       文件简写模式的配置文件路径
  -R |    removeTarget          是否删除目标目录
  -Z |    isNotCompress         不压缩(默认压缩 可通过该选项指定不压缩)
  -D |    IS_DEBUG              debug模式(输出一些调试日志如版本 运行时间等)
  -M |    CALLBACK_MESSAGE      调用信息 用于记录调用日志


show some examples

## 示例1  将源路径通过命令行参数传入(常用)
## 如下表示从源路径中找文件名包含1214或者1215的文件拷备到target/log 这里通过传入的参数决定要哪些拷备目录
## 其会生成一个tar包 并把拷来的log目录删除(可通过-Z -R 参数决定是否生成tar 是否删除log)
./getLog.sh -s '1214 1215' -t /home/user/logpickup/20170426172816  /home/user/nohup/source1 /home/user/nohup/source2

## 示例2 -f 选项 将源路径通过配置文件传入(常用)
## 如下表示从源路径中找文件名包含1214或者1215的文件拷备到target 这里通过配置文件配置决定要拷备哪些目录
## 其会生成一个tar包 并把拷来的log目录删除(可通过-Z -R 参数决定是否生成tar 是否删除log)
./getLog.sh -s '1214 1215' -t /home/user/logpickup/20170426172816   -f /home/user/shell/cleanLog/getLog_file.config 

## 示例3 -F 选项 将源路径和简写名写到配置文件 并且将简写名通过参数传入决定具体要拷备哪些路径(常用)
./getLog.sh -s '1214 1215' -t /home/user/logpickup/20170426172816   -F /home/user/shell/cleanLog/getLog_shortFile.config  source1 source2


## 示例4 -R选项 不删除log目录
## 如下只生成压缩包 但不会删除log目录
./getLog.sh -R -s '1214 1215' -t /home/user/logpickup/20170426172816  /home/user/nohup/source1 /home/user/nohup/source2

./getLog.sh -R -s '1214 1215' -R -t /home/user/logpickup/20170426172816   -f /home/user/shell/cleanLog/getLog_file.config

## 示例5 -Z 不压缩
## 不压缩log 只拷备log 
## 注 如果不压缩 也不会删除log目录
./getLog.sh -s '1214 1215' -Z -t /home/user/logpickup/20170426172816  /home/user/nohup/source1 /home/user/nohup/source2
./getLog.sh -s '1214 1215' -Z -t /home/user/logpickup/20170426172816   -f /config/getLog.config

## 示例6 -T 选项 设置log目录名
## log目录名默认为log 这里也可以修改为其它名称
./getLog.sh -T log2 -s '1214 1215' -Z -t /home/user/logpickup/20170426172816  /home/user/nohup/source1  /home/user/nohup/source2

## 示例7 -D 调试选项(输出版本、运行时间等信息)
./getLog.sh -D -s '1214 1215' -t /home/user/logpickup/20170426172816  /home/user/nohup/source1  /home/user/nohup/source2
./getLog.sh -D -s '1214 1215' -t /home/user/logpickup/20170426172816   -f /config/getLog_file.config

## 示例8 只输出某些调试信息(不想用-D选项 输出全部的调试信息 只输出某些信息)
./getLog.sh -D -s '1214 1215' -t /home/user/logpickup/20170426172816  /home/user/nohup/source1  /home/user/nohup/source2 version runtime


# 其它说明
# 最好保证源目录中的日志名不一样 否则后拷备的文件会覆盖先前拷备的文件 所以一般与cleanLog配合使用 以免日志文件名重复
# 为什么该脚本不对拷备的文件加前缀以区分 因为不好加 拷备的源路径有好几个 每个源路径都需要有一个前缀 配置麻烦 取配置也麻烦

# ==============================exitcode=========================

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
IS_OUTPUT_PARSE_PARAMETER=false


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

# 用于获得脚本所在路径的，因为如果你把该脚本加到PATH中然后在其它路径中使用命令 wcm.sh 则使用默认配置文件时会出错
# 注 这里cd pwd是有道理的，如果不加 你有可能获取到 . 
# 最好切换到脚本当前目录下 因为有时以crontab中运行有可能不动
# 已经测试虽然下面的命令中有cd操作 但我发现其不会改变当前路径
SHELL_PATH=$(cd $(dirname "$0");pwd)

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
	$PARENT_PATH/util/getConfig.sh
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
# 允许用户通过选项修改的变量放这里

# 默认目标目录的目录名 如为log则会创建 target/log并把文件拷备到这里
DEFAULT_TARGET_FILENAME=log


# 脚本默认功能
SHELL_FUNCTION=argument


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


# 初始化自己的变量 
function fun_init_variable {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null

    # 是否删除拷备 一般我们都会压缩所以拷备的文件就没用了可以删除
    isDeleteCopy=true

    # 默认压缩
    isCompress=true
}

# init方法
function fun_init {
	fun_init_common
	#如下写自己的init方法

    realTarget=$target/$DEFAULT_TARGET_FILENAME
    if [ ! -d $realTarget ] 
    then 
        echo $realTarget 目录不存在 现在创建
        mkdir -p $realTarget
    fi

    # 判断功能模式 
    if [ ${SHELL_FUNCTION}X = "argument"X ]
    then
        echo "命令行模式"
        sourceArray=(${paramArrayFilter[*]})
    elif [ ${SHELL_FUNCTION}X = "file"X ]
    then
        echo "一般文件模式"
        configFileSource=`getConfig.sh -f $configFile -s CONFIG_START -e CONFIG_END -m`
        sourceArray=($configFileSource);
    elif [ ${SHELL_FUNCTION}X = "shortFile"X ]
    then
        echo "文件简写模式"
        # 如果是-F 选项 则依次循环paramArrayFilter 从配置文件中取出路径放在数组中
        for para in ${paramArrayFilter[*]}
        do
            # 从配置文件里取配置
            fromPath=`getConfig.sh -f $configFile -s CONFIG_START -e CONFIG_END -i $param`
            sourceArray=(${sourceArray[*]} $fromPath) 
        done
    fi
}

# 校验参数
function fun_checkParameter {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null

	if [ ! -z $configFile ]
	then
        if [ ! -f $configFile ]
        then
            echo [ERR-156] 配置文件不存在 $configFile >&2
            exit 156
        fi
	fi


    if [ -z $target ] 
    then
        echo [ERR-155] -t 参数值不能为空 >&2
        exit 155
    fi

    if [ -z "$fileNameStr" ]
    then
        echo [ERR-155] -s 参数值不能为空 >&2
        exit 155
    fi
}

# 输出解析选项的日志函数 以减少重复代码
function fun_OutputOpinion {
    if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] 
	then
		echo "[parse opinion]found the -$1 option,$2"
	fi
}


# 从源路径找到匹配的文件拷备到目标路径的代码
function fun_copy {
	local local_source=$1
    local local_fileName=$2
    local local_target=$3 

    # 如果源目录存在再拷备
    if [ -d $local_source ]
    then
        for file in `ls $local_source|grep $local_fileName`
        do
             echo "cp -rf $local_source/$file $local_target/"
             cp -rf $local_source/$file $local_target/
        done
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
while getopts s:t:T:f:F:RZhDM: opt
do
  case "$opt" in
     s) fun_OutputOpinion $opt "$OPTARG"
        fileNameStr=$OPTARG	
		# 注 最后一句必须加两个分号
        ;;
     t) fun_OutputOpinion $opt $OPTARG
	    target=$OPTARG
        ;;
     T) fun_OutputOpinion $opt $OPTARG
        DEFAULT_TARGET_FILENAME=$OPTARG
         ;;
     f) fun_OutputOpinion $opt $OPTARG
        SHELL_FUNCTION=file
	    configFile=$OPTARG
        ;;
     F) fun_OutputOpinion $opt $OPTARG
        SHELL_FUNCTION=shortFile
	    configFile=$OPTARG
        ;;
     R) fun_OutputOpinion $opt $OPTARG
        isDeleteCopy=false
        ;;
     Z) fun_OutputOpinion $opt $OPTARG
		isCompress=false
        isDeleteCopy=false
        ;;
     h) fun_OutputOpinion $opt $OPTARG
         usage
         ;;
     D) fun_OutputOpinion $opt $OPTARG
		#是否debug模式 debug模式下会把执行的exp命令输出来方便测试
		IS_DEBUG=true
        ;;
     M) fun_OutputOpinion $opt $OPTARG
		CALLBACK_MESSAGE=$OPTARG;;
     *) fun_OutputOpinion $opt $OPTARG
         usage
		exit 148;;
  esac
done

# 解析参数
paramArrayFilter=()
shift $[ $OPTIND -1 ]
PARAMETER_COUNT=1
# 如下把解析的参数都输出来 方便查看
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

# 取参数示例 如下只取出数组的第一个元素
# 注 为什么加() 把其变成数组 如果写成paramArray=$@就不是数组了 你就取不出元素了
# 注 因为我不会一次把元素取出来 所以用了2句 如本想以 ${$@[0]}
paramArrayAll=($@);
#deletePath=${paramArray[0]}


# 校验参数
fun_checkParameter

# 初始化
fun_init

#####################下面写脚本逻辑#####################################

# 拷备文件
echo
echo 拷备文件
for source in ${sourceArray[@]}
do
    if [ -d $source ]
    then
        for fileName in $fileNameStr
        do
            fun_copy $source $fileName $realTarget
        done
    else
        echo [warn]源目录不存在 $source
    fi
done


# 判断是否拷备到文件
fileCount=`ls $realTarget|wc -l` 
if [ $fileCount -gt 0 ]
then
    isCopyedFile=true
else
    echo "[warn]未拷备到文件"
    isCopyedFile=false
fi

# 压缩
if [ ${isCompress}X = "true"X ] && [ ${isCopyedFile}X = "true"X ]
then
    tarName=`basename $target`.tar.gz
    echo
    echo 压缩文件 到 $target/$tarName
    tar -czvf $target/$tarName -C $target $DEFAULT_TARGET_FILENAME
fi

# 压缩后拷备的文件就不用了 可以判断是否删除
if [ ${isDeleteCopy}X = "true"X ] && [ ${isCopyedFile}X = "true"X ]
then
    echo
    echo 删除 $realTarget
    rm -rf $realTarget
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
