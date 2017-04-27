#!/bin/bash
#create by m-ning at 2016/8/9 15:05:48 
# desc 从一个配置文件中取配置  
# 配置支持#注释、
# 支持取多行配置
# 支持取单行配置 如SOURCE=/Users/test/

author=man003@163.com
version=V2-20161015

#############################how to use####################################################

# 使用说明
# 让该脚本有可执行权限 chmod +x ./getConfig.sh
# 运行该脚本  下面会介绍脚本具体参数
# 对于单行配置都是以等号为分隔的
# 具体配置样例参见 getConfig.sh_test.config

# 取单行配置 SOURCE 这里查找范围为全文
#./getConfig.sh -f test.config -i SOURCE

# 取单行配置 SOURCE 只是限定了查找范围
# 以CONFIG_START开始 以CONFIG_END结束 
#以等号为分隔符
#./getConfig.sh -f test.config -s CONFIG_START -e CONFIG_END -i SOURCE

# 取多行配置示例 如拷备时源路径一行一个
#./getConfig.sh -f test.config -s SOURCE_START -e SOURCE_END -m
# 如下将多行内容放到变量里 其以空格为分隔符 因放到变量里了 其会自动删除空白
# configFileSource=`getConfig.sh -f $configFile -s SOURCE_START -e SOURCE_END -m`

# 取多行配置的个数 有时需要判断多行配置的个数 
#./getConfig.sh -f test.config -s SOURCE_START -e SOURCE_END -mc


# 脚本参数说明
## -s start的意思
## -e end的意思
## -m 多行的意思
## -c 取count的意思 需要与-m一起使用
## -i item的意思 用于取单行的配置

# history
# 2016-08-09 V1 初版
# 2016-10-15 V2 
	# 取多行配置直接输出而不是写到变量里 免得处理不了行中有空格的情况
	# -s -e 不输入则默认搜索全文 也即不用必要求配置文件必须以CONFIG_START 开始 以CONFIG_END结束
	# 取单行配置支持全字匹配

#########################如下是配置区域#########################################################



#########################如上是配置区域#########################################################


#-f test.config -s CONFIG_START  -e CONFIG_END -i SOURCE
#-f test.config -s CONFIG_START  -e CONFIG_END -m

while getopts f:s:e:i:mc opt
do
  case "$opt" in
    f) 
		CONFIG=$OPTARG;;
	s)
		CONFIG_START=$OPTARG;;
    e)
		CONFIG_END=$OPTARG;;
    i)
		CONFIG_ITEM=$OPTARG;;
	m)
		IS_MANY_ROW="true";;
    c)
		IS_COUNT="true";;
    *) 
		exit 404;;
  esac
done

# 设置默认值 如果传入的参数为空 就走默认值
#CONFIG_START_DEFAULT="CONFIG_START";
#CONFIG_END_DEFAULT="CONFIG_END";
CONFIG_DEFAULT="conf.config";

#if [ -z $CONFIG_START ]
#then
#	CONFIG_START=$CONFIG_START_DEFAULT;
#fi


#if [ -z $CONFIG_END ]
#then
#	CONFIG_END=$CONFIG_END_DEFAULT;
#fi

# 如果没有传入CONFIG_START 则默认从第1行开始
if [ -z $CONFIG_START ]
then
	CONFIG_START_INDEX=1
else
	CONFIG_START_INDEX=`grep -n ${CONFIG_START} ${CONFIG} | cut -d: -f1`
	CONFIG_START_INDEX=$[CONFIG_START_INDEX+1]

fi

# 如果没有传入CONFIG_END 则默认查找到最后一行
if [ -z $CONFIG_END ]
then
	CONFIG_END_INDEX=`wc -l ${CONFIG}|awk '{print $1}'`
else
	CONFIG_END_INDEX=`grep -n ${CONFIG_END} ${CONFIG} | cut -d: -f1`
	CONFIG_END_INDEX=$[CONFIG_END_INDEX-1]
fi


# 注:以下写法不对。你不能先把config截取出来放到变量中。因为变量中没有\n 其自动把\n转成空格了，所以你再去找ST就不对
# 应该先把命令放到变量中，然后再一起执行
#CONFIG_TEXT=`sed -n ${CONFIG_START_INDEX},${CONFIG_END_INDEX}p $CONFIG |grep '^[^#]'`
#DEST=`echo $CONFIG_CONTENT|grep '^DEST'|cut -d= -f2`



if [ ${IS_MANY_ROW}X != "true"X ]
then
	CONFIG_TEXT="sed -n ${CONFIG_START_INDEX},${CONFIG_END_INDEX}p ${CONFIG}"
	# 如下grep -w 是整字匹配
	result=`${CONFIG_TEXT} | grep -w "^${CONFIG_ITEM}" | cut -d= -f2`
	echo $result;
else
	#如果为-c 则只返回行数	
	if [ ${IS_COUNT}X = "true"X ]
	then
		count=`sed -n ${CONFIG_START_INDEX},${CONFIG_END_INDEX}p ${CONFIG} | grep '^[^#]'|wc -l`
		echo $count
	else
		# 注:对于多行配置直接输出 而不是放变量里再输出是因为放变量里会把多行变成一行 以空格分隔 如果你的配置中有空格就不能处理了
		sed -n ${CONFIG_START_INDEX},${CONFIG_END_INDEX}p ${CONFIG} | grep '^[^#]'
	fi
fi
