#!/bin/bash
# 每分钟启动一次该脚本 
# 该脚本会把ping的日志放在指定日志文件下 每天一个


# 使用方式
# 命令行使用
# ./pingsh.sh -p 59.110.143.56 -s prefix -l /home/dxp/pingsh/log 

# crontab 下使用 如下每分钟执行一次
# */1 * * * * /home/dxp/pingsh/pingsh.sh -p 59.110.143.56 -s prefix -l /home/dxp/pingsh/log >/dev/null 2>&1

###########################################################################33
#是否输出解析命令行日志
IS_OUTPUT_PARSE_PARAMETER=false

SHELL_PATH=$(cd $(dirname "$0");pwd)

# 输出解析选项的日志函数 以减少重复代码
function fun_OutputOpinion {
    if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] 
	then
		echo "[parse opinion]found the -$1 option,$2"
	fi
}

while getopts p:l:s: opt
do
  case "$opt" in
     p) fun_OutputOpinion $opt $OPTARG
	 	IP=$OPTARG;;
		# 注 最后一句必须加两个分号
     l) fun_OutputOpinion $opt $OPTARG
		LOG_BASE=$OPTARG;;
     s) fun_OutputOpinion $opt $OPTARG
		PREFIX=$OPTARG;;
     *) fun_OutputOpinion $opt $OPTARG
		exit 148;;
  esac
done


datestr=`date "+%Y%m%d"`
datestr_sec=`date "+%Y-%m-%d %H:%M:%S"`


if [ -z $LOG_BASE ]
then
    LOG_BASE=$SHELL_PATH/log
fi

if [ ! -d $LOG_BASE ]
then
    echo $LOG_BASE 目录不存在 现在创建
    mkdir -p $LOG_BASE
fi

if [ -z $PREFIX ]
then
    log=$LOG_BASE/ping_$datestr.log
else
    log=$LOG_BASE/ping_${PREFIX}_$datestr.log
fi

if [ -z $IP ]
then
	echo IP不能为空 >>$log
	exit -1
fi



echo >>$log
echo ping脚本开始分析 $datestr_sec $IP >>$log
ping -c 60 $IP  |tee -a $log
