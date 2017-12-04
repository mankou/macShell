#!/bin/bash
# create by m-ning at 20171028
# desc pingsh.sh的配套分析脚本 用于从ping包日志中分析出哪些时间有丢包现象

author=man003@163.com
version=1.0-20171028

#==============================TODO==============================
# TODOXXX
	# 说明

# usage 
usage() {
 cat <<EOM
Desc: pingsh.sh的配套分析脚本 用于从ping包日志中分析出哪些时间有丢包现象
Usage: $SHELL_NAME [options] args
  -h |    print help usage      打印usage
  -t |    target_file_path      结果文件存放路径
  -s |    suffix                后缀

show some examples
# 示例1 分析dir1 dir2目录下ping包日志文件以及file1哪些时间有丢包现象
./pinga.sh dir1 dir2 file1
# 注1 关于结果文件 
    ## 这里没有指定结果文件存放路径,则走默认值.默认路径为:当前路径/pinga.result
    ## 可通过-t 选项改变结果文件存放路径
# 注2 关于日志文件后缀
    ## 这里没有指定后缀 则默认为*.log 即只查找 *.log 这样的文件
    ## 可通过-s 选项 修改后缀
# 注3 关于分析哪些目录
    ## 在命令行参数中可以指定目录，也可以指定文件 
    ## 如果是目录则会查找该目录下所有后缀为*.log的文件 进行分析
    ## 如果是文件则直接分析该文件


# 示例2 指定结果文件存放路径
./pinga.sh -t targetPath dir1 dir2
# 注 则这里结果文件会存放在指定的路径 而不是默认的路径

# ==============================exitcode=========================

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


# 如果目标文件所在目录不存在则新建 如果目标文件存在则删除
targetParentPath=`dirname $target_file_path`
[ ! -d $targetParentPath ] && mkdir $targetParentPath
[ -e $target_file_path ] && rm -rf $target_file_path

# 遍历参数数组 有时需要遍历数组则可用如下方式
# 如下整理出需要分析哪些文件 将文件路径存储在 timpFile1中
[ ! ${IS_SILENT}X = "true"X ] && echo **阶段1:正在搜索要分析的日志文件 $suffix
tmpFile1=$TMP_PATH/$SHELL_NAME0.tmp1
[ -e $tmpFile1 ] && rm -rf $tmpFile1
for paramFilter in ${paramArrayFilter[@]}
do
    if [ -d $paramFilter ]
    then
        find $paramFilter -name $suffix >>$tmpFile1
    elif [ -f $paramFilter ]
    then
        echo $paramFilter>>$tmpFile1 
    fi
done


# 如下找出丢包率不是0%的行 重定向到tmpFile2中
[ ! ${IS_SILENT}X = "true"X ] && echo **阶段2:找出丢包率不是0%的行
tmpFile2=$TMP_PATH/$SHELL_NAME0.tmp2
[ -e $tmpFile2 ] && rm -rf $tmpFile2
cat $tmpFile1 |while read line
do
    grep -Hn "packet loss" $line |grep -v " 0% " >>$tmpFile2
done


# 如下进一步规范数据 删除数据中的无用空格
[ ! ${IS_SILENT}X = "true"X ] && echo **阶段3:规范数据
tmpFile3=$TMP_PATH/$SHELL_NAME0.tmp3
[ -e $tmpFile3 ] && rm -rf $tmpFile3
sed 's/, /,/g' $tmpFile2 >>$tmpFile3


# 如下根据上面找到的文件名及行号取出时间 并将最终的内容保存到结果文件中
[ ! ${IS_SILENT}X = "true"X ] && echo **阶段4:提取时间
cat $tmpFile3 | while read line
do
     #取出文件名
     filename=`echo $line|cut -d: -f1`; 
     #取出行号
     lineEndNum=`echo $line|cut -d: -f2` 
     #因为一般丢失率那行最多往上60多行就能找到时间所以这里-70
     lineStartNum=$[$lineEndNum-70]; 
     # 取出当前时间那一行 其格式为2017-10-27 05:34:01
     date_time=`sed -n "$lineStartNum,$lineEndNum p" $filename |grep $pattern_line|tail -n 1|awk '{print $2,$3}'`;
     date=`echo $date_time|awk '{print $1}'` 
     time=`echo $date_time|awk '{print $2}'`
     
     if [ ${is_short_file_name}X = "true"X ]
     then
         shortFileName=`basename $filename`;
         #echo $line|awk -v shortFileName=$shortFileName -v date=${date} -v time=${time} 'BEGIN{FS=":";OFS=","} {print date " " time,shortFileName,$2,$3}'>>$target_file_path
         echo $line|awk -v shortFileName=$shortFileName -v date=${date} -v time=${time} 'BEGIN{FS=":";OFS=","} {print date " " time,shortFileName,$2,$3}' |tee -a $target_file_path
     else
         #echo $time:$line >>$target_file_path
         echo $time:$line |tee -a $target_file_path
     fi
done

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
