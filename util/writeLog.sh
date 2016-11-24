#!/bin/bash
# create by m-ning at 20160728
# desc 

author=man003@163.com
version=V1-20161124


#==============================how to use==============================

# 用于获得脚本所在路径的，因为如果你把该脚本加到PATH中然后在其它路径中使用命令 wcm.sh 则使用默认配置文件时会出错
# 已经测试虽然下面的命令中有cd操作 但我发现其不会改变当前路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
#logPath=/Users/mang/AppData/百度云同步盘/mac/bat-mac/util/commonLog/shRun.log

# 配置变量
logPath=$SHELL_PATH/commonLog/shRun.log
logPath_detail=$SHELL_PATH/commonLog/shRun_detail.log

# 自定义参数
# 调用脚本信息 其取自调用者的$0 通过这个可以判断是从哪里调的
shName=$1 

# 输出日志信息
message=$2

datestr=`date "+%Y-%m-%d %H:%M:%S"`

shell_name=`basename $shName`

#如果日志文件父目录不存在则新建
LOG_PARENT_PATH=`dirname $logPath`;
if [ ! -e LOG_PARENT_PATH ]
then
	mkdir -p $LOG_PARENT_PATH
fi

echo $datestr [$shell_name] $message >>$logPath
echo $datestr [$shell_name] $message $shName >>$logPath_detail
