#!/bin/bash
#create by m-ning at 20160808
# desc 一键拷备
## 开发背景:每次替换license很多 所以想写一个批处理一键替换
## 功能说明:
## 在配置文件中指定要拷备的源文件 和目标路径 然后执行脚本即可
## 具体配置文件的细节参拷license.config

## 返回错误码说明
## 1 当n对n的情况下 源路径个数与目标路径个数不一致
## 2 配置文件有误 
## 404 未知选项


author=man003@163.com
version=V1-20160808

#############################使用说明####################################################
# 使用说明
# 拷备时注意把依赖的脚本也一起拷走，目录结构不变 
# 让该脚本有可执行权限 chmod +x codeShell.sh 注其依赖的脚本也要加x权限
# 写配置文件 如这里配置文件叫 license.config
# 运行该脚本 ./codeShell.sh -f license.config

# 该脚本依赖的脚本
# getConfig/getConfig.sh


# history
# 2016-08-09 V1 初版 支持一对一 一对多 多对一 多对多的拷备

# 技巧点
## 获取某一目录的上一级目录
## copy $SOURCE $TARGET 变量其会自动带单引号 导致你不能从多个源拷备到一个目录 你只能循环一个一个拷备

#########################如下是配置区域#########################################################
#时间戳
datestr=`date "+%Y%m%d%H%M%S"`

# 设置环境变量
BASE_PATH=$(cd $(dirname "$0");pwd)
PARENT_PATH=`dirname $BASE_PATH`;
PATH=$PATH:$PARENT_PATH/util/;

# 依赖的shell 一行一个 如果没有x 权限 自动设置
RELIANT_SH="
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


#########################如上是配置区域#########################################################
echo start at `date -d today +"%Y-%m-%d %T"`====================
startTime=`date +%s`

# 解析命令选项
echo 正在解析命令行选项......
while getopts f: opt
do
  case "$opt" in
    f) echo "found the -f option,$OPTARG"
		CONFIG=$OPTARG;;
	# 注 最后一句必须加两个分号
    *) echo "unknown option:$opt"
		exit 404;;
  esac
done


# 取配置 源路径和目录路径
SOURCE=`getConfig.sh -f $CONFIG -s SOURCE_START -e SOURCE_END -m`
TARGET=`getConfig.sh -f $CONFIG -s TARGET_START -e TARGET_END -m`

# 取源路径和目录路径的个数 用于判断各种类型
SOURCE_COUNT=`getConfig.sh -f $CONFIG -s SOURCE_START -e SOURCE_END -mc`
TARGET_COUNT=`getConfig.sh -f $CONFIG -s TARGET_START -e TARGET_END -mc`
#echo SOURCE_COUNT $SOURCE_COUNT
#echo TARGET_COUNT $TARGET_COUNT

# 判断各种类型

echo 
if [ $SOURCE_COUNT -eq 1 ] && [ $TARGET_COUNT -eq 1 ]
then
	#echo "一对一类型"
	echo "cp -rf $SOURCE $TARGET"
	cp -rf $SOURCE $TARGET
elif [ $SOURCE_COUNT -eq 1 ] && [ $TARGET_COUNT -gt 1 ] 
then
	#echo "一对多类型"
	for currentTarget in $TARGET
	do
		echo "cp -rf $SOURCE $currentTarget"
		cp -rf $SOURCE $currentTarget
	done
elif [ $SOURCE_COUNT -gt 1 ] && [ $TARGET_COUNT -eq 1 ] 
then
	#echo "多对一类型"

	# 注原来我是写成如下语句的 但发现执行报错 
	# 我感觉与变量转换后带单引号有关 因为我把命令单独复制出来执行没有错误
	#cp -rf "$SOURCE" $TARGET
	#cp: cannot stat '/Users/mang/.vimrc /Users/mang/.gvimrc /Users/mang/.dir_colors /Users/mang/.bash_profile': No such file or directory
	for currentSource in $SOURCE
    do
        echo "cp -rf $currentSource $TARGET"
        cp -rf $currentSource $TARGET
    done
elif [ $SOURCE_COUNT -gt 1 ] && [ $TARGET_COUNT -gt 1 ] 
then
	#echo "多对多类型"
	# 同时从 $SOURCE 和 $TARGET中取数据 然后一条一条拷备
	# 把SOURCE变成数组 以用于下面遍历数组
	arraySource=($SOURCE)
	arrayTarget=($TARGET)
	
	# 如果源路径个数与目标路径个数不一致 报错返回
	if [ ${#arraySource[@]} -ne ${#arrayTarget[@]} ] 
	then
		echo 源路径个数为 ${#arraySource[@]}  目标路径个数为 ${#arrayTarget[@]} 个数不一致 请检查配置
		exit 1
	fi

	# 依次从源路径和目标路径中取出源 目标 进行拷备操作
	for(( i=0;i<${#arraySource[@]};i++)) do 
		echo "cp -rf ${arraySource[i]} ${arrayTarget[i]}"
		cp -rf ${arraySource[i]} ${arrayTarget[i]}
	done;
else 
	echo "配置文件有问题"
	exit 2
fi


echo
endTime=`date +%s`
timeInterval=$(( ($endTime-$startTime)/60 ))
echo end at `date -d today +"%Y-%m-%d %T"`... 用时$timeInterval 分钟====================
echo *************develop by ${author} ${version}************;
