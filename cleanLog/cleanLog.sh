#!/bin/bash
# 每天清除日志的脚本
	# 将旧日志拷备到指定目录下 文件名加上日期 并且可以加前缀
	# 清空日志文件
	# 需加到计划任务crontab中使用



author=man003@163.com
version=V1.0-20170501


# 脚本当前路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
SHELL_NAME=`basename $0`

# usage 
usage() {
 cat <<EOM
Desc: 该脚本用于备份并清空日志文件,常放在crontab中以达到定期清空日志文件的功能
Usage: $SHELL_NAME [options]
  -h |    print help usage
  -f |    from path
  -t |    to path
  -d |    day
  -F |    dateFormat
  -p |    prefix


show some examples
# 每天一个日志(默认) 拷备的日志文件以test做为前缀
./cleanLog.sh -f /home/user/test/nohup.out  -t /home/user/nohup/test -p test

# 每周一个日志 拷备的日志文件以test做为前缀
./cleanLog.sh -f /home/user/test/nohup.out  -t /home/user/nohup/test -d "-7days" -p test

# 每月一个日志 拷备的日志文件以test做为前缀
./cleanLog.sh -f /home/user/test/nohup.out  -t /home/user/nohup/test -d "-1month" -p test

# 每6小时一个日志 拷备的日志文件以test做为前缀
./cleanLog.sh -f /home/user/test//nohup.out  -t /home/user/nohup/test -d "-6hour" -p test

# 每30分钟一个日志 拷备的日志文件以test做为前缀
./cleanLog.sh -f /home/user/test/nohup.out  -t /home/user/nohup/test -d "-30minute" -p test

# 取当前时间
./cleanLog.sh -f /home/user/test/nohup.out  -t /home/user/nohup/test -p test -d "now"
# 如下自己指定时间格式
./cleanLog.sh -f /home/user/test/nohup.out  -t /home/user/nohup/test -p test -d "now" -F "%Y%m%d%H%M"

# -F 选项 设置时间格式
# 如下可通过-F选项 自己指定时间格式  如果不指定时间格式则采用默认的时间格式
# 使用场景1:因上面演示的例子取的时间都是以前的时间 如前1天 前7天等 有时想取现在的时间并且还想自定义时间格式就可以用这种方法
# 使用场景2:如果对默认的时间格式不满意 可通过该选项进行调整
./cleanLog.sh -f /home/user/test/nohup.out  -t /home/user/nohup/test -p test -d "now" -F "%Y%m%d%H%M%S"
./cleanLog.sh -f /home/user/test/nohup.out  -t /home/user/nohup/test -p test -d "-1days" -F "%Y%m%d%H%M%S"

# 配置到crontab中使用
# 每天0点0分备份日志 并清空日志文件
# 注如下务必保证重定向的目录存在
0 0 * * * /home/user/shell/cleanLog/cleanLog.sh -f /home/user/test/nohup.out -t /home/user/nohup/test -p test >>/home/user/shell/shelllog/cleanLog.test.log 2>&1


#一些说明
如上的例子中 -d 选项的参数如  "-7days" "-1month" 都表示取7天前、1个月前的时间 总之是取以前的时间
为什么要取以前的时间? 因为一般该脚本都是配置在crontab中执行 如果每天1个日志 则我的习惯日志的开始时间一般是1天前 所以取1天前的时间

EOM
exit 0
}

# 取时间戳格式
getDateFromatter(){
    if [ ! -z $dateFormat ]
    then
        echo $dateFormat
    else
        echo $1
    fi
}


##### 系统变量#####

#时间戳
datestr=`date "+%Y%m%d%H%M%S"`
datestrFormat=`date "+%Y-%m-%d %H:%M:%S"`


#################自定义变量######################
ndays="-1 days"




# init方法
function fun_init {
	fun_init_common
	#如下写自己的init方法

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

    # 如果传入now 则用当前时间
    if [ ${ndays}X = "now"X ]
    then
        formatter=`getDateFromatter $default_formatter_now `
        dateStr=`date +$formatter`
    else
        # 如果包含minute min 则时间格式精确到分钟
        if [[ $ndays =~ "minute" ]] ||  [[ $ndays =~ "min" ]]
        then
            formatter=`getDateFromatter $default_formatter_min`
            dateStr=`date +$formatter` -d "$ndays"
        elif [[ $ndays =~ "hour" ]]
        then
            # 如果包含hour 则时间格式精确到小时
            formatter=`getDateFromatter $default_formatter_hour`
            dateStr=`date +$formatter` -d "$ndays"
        else
            # 否则时间格式精确到天
            formatter=`getDateFromatter $default_formatter_common`
            dateStr=`date  +$formatter -d  "$ndays"`
        fi
    fi


    if [ ! -z $prefix ]
    then
        targetFileName=$prefix-$fromFileName-$dateStr
    else
        targetFileName=$fromFileName-$dateStr
    fi
}


# 通用的init方法
function fun_init_common {
    echo
    echo ======================
    echo $datestrFormat
    echo ======================
}



# 初始化自己的变量 
function fun_init_variable {
	# 注已测试函数中的语句不能为空 必须有一句命令 否则报错 所以我加一句免得出错
	echo >/dev/null

    default_formatter_now=%Y%m%d%H%M%S
    default_formatter_min=%Y%m%d%H%M
    default_formatter_hour=%Y%m%d%H
    default_formatter_common=%Y%m%d

}


###  ------------------------------- ###
###  Main script                     ###
###  ------------------------------- ###



# 初始化程序内部的变量
fun_init_variable

while getopts f:t:d:F:p:h opt
do
  case "$opt" in
     f) fromFile=$OPTARG
		;;
     t) toPath=$OPTARG
		;;
     d) ndays=$OPTARG
		;;
     F) dateFormat=$OPTARG
		;;
     p) prefix=$OPTARG
		;;
     h) usage
         ;;
     *) echo unexpect option $opt
		exit 148;;
  esac
done

# 初始化
fun_init


echo cp $targetFileName ...
cp $fromFile $toPath/$targetFileName

echo clean $fromFile ...
cat /dev/null >$fromFile

echo ok...


