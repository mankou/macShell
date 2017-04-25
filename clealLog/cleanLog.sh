#!/bin/bash
# 每天清除日志的脚本
	# 将旧日志拷备到指定目录下 文件名加上日期 并且可以加前缀
	# 清空日志文件
	# 需加到计划任务crontab中使用



# 脚本当前路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
SHELL_NAME=`basename $0`

# usage 
usage() {
 cat <<EOM
Usage: $SHELL_NAME [options]
  -h |    print help usage
  -f |    from path
  -t |    to path
  -d |    day
  -p |    prefix

show some examples
# 每天一个日志(默认) 以test做为前缀
./cleanLog.sh -f /home/bin/nohup.out  -t /home/bak/ -p test

# 每周一个日志 以test做为前缀
./cleanLog.sh -f /home/bin/nohup.out  -t /home/bak/ -d "-7days" -p test

# 每月一个日志 以test做为前缀
./cleanLog.sh -f /home/bin/nohup.out  -t /home/bak/ -d "-1month" -p test

# 配置到crontab中每天0点0分 备份dxp日志 并清空日志文件
0 0 * * * /home/dxp/shell/cleanLog.sh -f /home/dxp/dataexchange/bin/nohup.out -t /home/dxp/nohup/dxp -p dxp
EOM
exit 0
}


###  ------------------------------- ###
###  Main script                     ###
###  ------------------------------- ###

# 设置默认值
ndays="-1 days"

while getopts f:t:d:p:h opt
do
  case "$opt" in
     f) fromFile=$OPTARG
		;;
     t) toPath=$OPTARG
		;;
     d) ndays=$OPTARG
		;;
     p) prefix=$OPTARG
		;;
     h) usage
         ;;
     *) echo unexpect option $opt
		exit 148;;
  esac
done


if [ ! -e $fromFile ]
then
	echo file not found $fromFile
	exit 1
fi

if [ ! -d $toPath ]
then
	mkdir -p $toPath
fi


fromFileName=`basename $fromFile`
dateStr=`date  +"%Y%m%d" -d  "$ndays"`

if [ ! -z $prefix ]
then
    targetFileName=$prefix-$fromFileName-$dateStr
else
    targetFileName=$fromFileName-$dateStr
fi

echo cp $targetFileName ...
cp $fromFile $toPath/$targetFileName


echo clean $fromFile ...
cat /dev/null >$fromFile

echo ok...


