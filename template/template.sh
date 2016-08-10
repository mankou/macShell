#!/bin/bash
#create by m-ning at 20160728
# desc 这是一个模板
## 功能1
## 功能2

author=man003@163.com
version=V1-20160728

#############################使用说明####################################################

#==============================how to use==============================
# 让该脚本有可执行权限 chmod +x ./oracleBak.sh
# 运行该脚本 ./oracleBak.sh

# 示例1 处理目录的相对路径
# 详细说明
#./getAbsolutePath.sh -d testDir/
#./getAbsolutePath.sh -d ~/Desktop

## 示例2 简要说明
## 详细说明...


# 其它说明
## 如果传入的是绝对路径则返回的也是绝对路径

# ==============================exitcode=========================
##exit 1 未输入NEW_PATH
##exit 2 如果即没有指定 -d 参数 也没有指定 -f 参数 则报错 因为我无法判断是目录还是文件
##exit 3 如果同时指定了 -d -f 参数 也返回错误


# ==============================脚本技巧点========================

#==============================todo==============================
# 


# ==============================history=========================
## 2016-2-19 V1 初版


#########################如下是配置区域#########################################################

#是否输出脚本运行时间 true表示输出 false表示不输出
IS_OUTPUT_RUNTIME="true";

#是否在脚本执行完后输出版本信息 true表示输出 false表示不输出
IS_OUTPUT_VERSION="true"

#时间戳
datestr=`date "+%Y%m%d%H%M%S"`

if [ ${IS_OUTPUT_RUNTIME}X = "true"X ]
then
	echo start at `date -d today +"%Y-%m-%d %T"`====================
	startTime=`date +%s`
fi


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
"
#$PARENT_PATH/util/tp.sh
for rs in $RELIANT_SH
do
	# 如果没有可执行权限 把权限加上
	if [ ! -x $rs ]; then
		chmod +x $rs
	fi
done

TMP_PATH=$BASE_PATH/tmp
# 如果tmp目录不存在 则新建
if [ ! -d $TMP_PATH ]
then
	echo $TMP_PATH 目录不存在 将新建
	mkdir $TMP_PATH
fi


# 工程是tv还是mo 工程不同目录有所不同 打的包名也不同
project=tv
# 本地代码根目录
codePath=/Users/mang/work/code/osc/frontCode/osc-tv-web-20160623-menu-JR0623

#########################如上是配置区域#########################################################
echo 正在解析命令行选项 $*
while getopts d:n:c:s:l opt
do
  case "$opt" in
     d) echo "[parse parameter]found the -d option,$OPTARG"
	 	deleteDays=$OPTARG	
		shellFunction="deleteDays";;
		# 注 最后一句必须加两个分号
     n) echo "[parse parameter]found the -n option,$OPTARG"
	    newestCount=$OPTARG
		shellFunction="retainNewest";;
     s) echo "[parse parameter]found the -s option,$OPTARG"
		suffix=$OPTARG;;
     l) echo "[parse parameter]found the -l option,$OPTARG"
		is_list="true";;
     *) echo "[parse parameter]unknown option:$opt"
		exit 148;;
  esac
done


# 处理参数
shift $[ $OPTIND -1 ]
count=1
# 只取出数组的第一个元素
# 注 为什么加() 把其变成数组 如果写成paramArray=$@就不是数组了 你就取不出元素了
# 注 因为我不会一次把元素取出来 所以用了2句 如本想以 ${$@[0]}
paramArray=($@);
deletePath=${paramArray[0]}
# 如下把解析的参数都输出来 方便查看
for param in "$@"
do
   echo "[parse parameter]parameter $count:$param"
   count=$[ $count+1 ]
done


## 这里是脚本逻辑




# 输出脚本运行时间信息
if [ ${IS_OUTPUT_RUNTIME}X = "true"X ] 
then
	echo
	endTime=`date +%s`
	timeInterval=$(( ($endTime-$startTime)/60 ))
	echo end at `date -d today +"%Y-%m-%d %T"`... 用时$timeInterval 分钟====================
fi
# 输出版本信息
if [ ${IS_OUTPUT_VERSION}X = "true"X ]
then
	echo *************develop by ${author} ${version}************;
fi
