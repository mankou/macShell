#!/bin/bash
#create by m-ning at 20160808
# desc 一键拷备、拷备代码用于整理升级包
## 开发背景:
###每次替换license很多 所以想写一个批处理一键替换
###后来添加了copyCode功能 配合svn日志,用于整理升级包用



author=man003@163.com
version=V2-20161114

#############################使用说明####################################################
#==============================how to use==============================
# 让该脚本有可执行权限 chmod +x ./oracleBak.sh

# 示例1 拷备代码 copyCode类型
# 使用场景 修改完代码后可求增量升级 
	#把修改的class文件配置文件按目录结果单独拷备出来进行升级
	# 则这里完成按目录结果拷备的功能
# 步骤1 从svn日志中提取要升级的文件
# 步骤2 参照codeCopyTest.config 写配置文件 指定要拷备的文件、源文件基准路径、目标文件基准路径
# 步骤2 执行命令 ./copyShell.sh -rd -f codeCopyTest.config
# 参数说明 -r 表示以copyCode类型进行拷备 这里取-r表示保存目录结构的意思
# 参数说明 -D 表示输出debugger信息 在拷备时会把执行的cp命令输出方便调试用
# 参数说明 -f 指定配置文件路径
# 注：程序默认不处理目录 也即如果拷备源里有目录默认直接跳过不处理 但可以通过-R选项去控制处理目录
# ./copyShell.sh -rR -f codeCopyTest.config


# 示例2 拷备文件
# 拷备时注意把依赖的脚本也一起拷走，目录结构不变 
# 让该脚本有可执行权限 chmod +x codeShell.sh 注其依赖的脚本也要加x权限
# 写配置文件 如这里配置文件叫 license.config
# 运行该脚本 ./codeShell.sh -f license.config


# ==============================exitcode=========================
##exit 1 当n对n的情况下 源路径个数与目标路径个数不一致
##exit 2 配置文件有误 
##exit 155 参数为空 为什么是155呢 因为当时用手机打某一词是923 取模256 就是155 但923代表什么词 忘记了
##exit 148 未指定的参数 为什么是148呢 因为404取模256就是148



# history
# 2016-08-09 V1 初版 支持一对一 一对多 多对一 多对多的拷备
# 2016-10-28 V2 [copyCode类型]支持代码拷备模式copyCode 用于拷备代码用 一般用于增量升级
# 2016-10-28 V2 [copyCode类型]将配置文件中源文件路径放在另一个文件中 以方便使用
# 2016-10-30 V2 [copyCode类型]针对内部类的情况进行特殊处理 并输出统计信息（复制多少个 正确多少个 错误多少个）
# 2016-11-09 V2 用-D 表示debugger模式 原来-d 表示debugger模式 因为我想用-d表示其它功能 如清除目录等
# 2016-11-09 V2 其它拷备模式也支持拷备信息统计 并且把统计信息的代码统一在一个函数里
# 2016-11-14 V2 fix copyCode类型如果拷备源是目录则默认不拷备并且输出日志 但可以通过-R选项控制是否处理目录

# 技巧点
## 获取某一目录的上一级目录
## copy $SOURCE $TARGET 变量其会自动带单引号 导致你不能从多个源拷备到一个目录 你只能循环一个一个拷备

#########################如下是配置区域#########################################################
##### 系统变量#####

#是否输出脚本运行时间 true表示输出 false表示不输出
IS_OUTPUT_RUNTIME=true;

#是否在脚本执行完后输出版本信息 true表示输出 false表示不输出
IS_OUTPUT_VERSION=true

#是否输出解析命令行日志
IS_OUTPUT_PARSE_PARAMETER=false


#是否创建tmp目录用于存储临时文件
IS_MKDIR_TMP=false

#脚本运行时是否切换到脚本所在路径
# 注 如果切换到脚本所在路径则你使用的相对路径就是以脚本所以路径为准 而不是你当前的路径了
IS_CD_SHELL_PATH=false

#是否输出统计信息如复制多少个文件 正确多少个 错误多少个
IS_OUTPUT_COPY_STATISTIC_INFO=true

#时间戳
datestr=`date "+%Y%m%d%H%M%S"`

if [ ${IS_OUTPUT_RUNTIME}X = "true"X ]
then
	echo start at `date  +"%Y-%m-%d %H:%M:%S"`====================
	startTime=`date +%s`
fi

# 当前路径
CURRENT_PATH=`pwd`

# 用于获得脚本所在路径的，因为如果你把该脚本加到PATH中然后在其它路径中使用命令 wcm.sh 则使用默认配置文件时会出错
# 注 这里cd pwd是有道理的，如果不加 你有可能获取到 . 
# 最好切换到脚本当前目录下 因为有时以crontab中运行有可能不动
# 如你经常将配置文件放在sh同一级目录下  脚本 -f con.config 有可能出错
# 已经测试虽然下面的命令中有cd操作 但我发现其不会改变当前路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
if [ ${IS_CD_SHELL_PATH}X = "true"X ]
then
	cd $SHELL_PATH
fi


# 用于获得脚本所在路径的
# 因为如果你把该脚本加到PATH中然后在其它路径中使用命令 wcm.sh 则使用默认配置文件时会出错
# 注 这里cd pwd是有道理的，如果不加 你有可能获取到 . 
# 当你使用 脚本名或者绝对路径调用脚本时$0是绝对路径 当你使用相对路径调用脚本时$0是相对路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
# 最好切换到脚本当前目录下 因为有时以crontab中运行有可能不动
# 如你经常将配置文件放在sh同一级目录下  脚本 -f con.config 有可能出错
cd $SHELL_PATH

# 获取脚本名
SHELL_NAME=`basename $0`
# 获取脚本所以父路径
PARENT_PATH=`dirname $SHELL_PATH`;

# 设置环境变量
PATH=$PATH:$PARENT_PATH/util/;


# 依赖的shell 一行一个 如果没有x 权限 自动设置
RELIANT_SH="
	$PARENT_PATH/util/getAbsolutePath.sh
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
# 如果tmp目录不存在 则新建
if  [ ${IS_MKDIR_TMP}X = "true"X ] && [ ! -d $TMP_PATH ]
then
	echo $TMP_PATH 目录不存在 将新建
	mkdir $TMP_PATH
fi


## 自定义变量 或者设置默认值
#对于copyCode类型是否复制目录 默认不复制 可通过-R选项控制该变量为true
copyCode_isProcessDir=false

#########################如上是配置区域#########################################################
# 输出解析选项的日志函数 以减少重复代码
function fun_OutputOpinion {
    if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] 
	then
		echo "[parse opinion]found the -$1 option,$2"
	fi
}

#统一处理统计信息
#该函数只能处理循环 然后一次拷备一个的那种 对于一个拷备命令就拷备多个那种处理不了
# $1 上一次执行copy命令的结果 $?
# $2 是否对准备复制的文件个数count_Source+1 如果非空就+1 因有有时针对一个文件可能复制好几次 如内部类的情况 则这种情况count_Source只能加1 而不能每次都加
function fun_processStatisticInfo {
	if [ ! -z $2 ]
	then
		count_Source=$[$count_Source+1]
	fi

	if [ $1 == 0 ]
	then
		count_Ok=$[$count_Ok+1]
	else
		count_Error=$[$count_Error+1]
	fi
	count_Real=$[$count_Real+1]
}


# 解析选项
if [ ${IS_OUTPUT_PARSE_PARAMETER}X = "true"X ] 
then
	echo 正在解析命令行选项 $*
fi
#如果某个选项字母后面要加参数则在后面加一冒号：
while getopts rRDf: opt
do
  case "$opt" in
     f) fun_OutputOpinion $opt $OPTARG
		##CONFIG=$OPTARG
		CONFIG=`getAbsolutePath.sh -f $OPTARG`
		;;
     r) fun_OutputOpinion $opt $OPTARG
		copyType="copyCode"
		;;
     R) fun_OutputOpinion $opt $OPTARG
		copyCode_isProcessDir=true
		;;
     D) fun_OutputOpinion $opt $OPTARG
		#是否debug模式 debug模式下会把执行的exp命令输出来方便测试
		IS_DEBUG=true;;
     *) fun_OutputOpinion $opt $OPTARG
		exit 148;;
  esac
done


#####################下面写脚本逻辑#####################################


#####参数校验#####
if [ -z $CONFIG ]
then
	# 输出错误信息 如下>&2 将输出重定向到标准出错 
	echo [ERR-155] -f 参数值不能为空 >&2
	exit 155
fi

# 如果不是copyCode类型则不取这些配置
# 因为copyCode类型不需要这些配置 因为配置文件中已经没有SOURCE_START这样的字样 所以有可能运行时会报错
if [ ${copyType}X != "copyCode"X ]
then
	# 取配置 源路径和目录路径
	SOURCE=`getConfig.sh -f $CONFIG -s SOURCE_START -e SOURCE_END -m`
	#echo getConfig.sh -f $CONFIG -s SOURCE_START -e SOURCE_END -m
	TARGET=`getConfig.sh -f $CONFIG -s TARGET_START -e TARGET_END -m`

	# 取源路径和目录路径的个数 用于判断各种类型
	SOURCE_COUNT=`getConfig.sh -f $CONFIG -s SOURCE_START -e SOURCE_END -mc`
	TARGET_COUNT=`getConfig.sh -f $CONFIG -s TARGET_START -e TARGET_END -mc`
fi

# 初始化信息
count_Source=0
count_Real=0
count_Ok=0
count_Error=0


# 判断各种类型
echo 
#  如果是copyCode类型则单独处理
if [ ${copyType}X = "copyCode"X ]
then
	echo ========== copyCode类型 ==========
	
	SOURCE_BASE_PATH=`getConfig.sh -f $CONFIG -i SOURCE_BASE_PATH`
	TARGET_BASE_PATH=`getConfig.sh -f $CONFIG -i TARGET_BASE_PATH`
	SOURCE_FILE=`getConfig.sh -f $CONFIG -i SOURCE_FILE`

	# 注 在下面循环拷备时会判断父目录是否存在 如果不存在新建 所以这里不需要判断

	# 清空目录(先判断目录是不是存在再清除)
	# 务必保证 变量不空 否则-d判断条件会通过 则就会执行rm -rf /* 很可怕 所以这里判断目录是否存在
	if [ ! -z $TARGET_BASE_PATH ] && [ -d $TARGET_BASE_PATH ]
	then
		echo $TARGET_BASE_PATH 存在,先清空该目录
		echo rm -rf $TARGET_BASE_PATH/*
		rm -rf $TARGET_BASE_PATH/*
		echo
	fi

	#遍历SOURCE
	for currentSource in `cat $SOURCE_FILE|grep ^[^#]`
    do
		#count_Source=$[$count_Source+1]
       	copySource=$SOURCE_BASE_PATH/$currentSource 
       	copyTarget=$TARGET_BASE_PATH/$currentSource
	
		#如果配置为不处理目录的情况下并且拷备源是个目录则跳过 也不计入统计信息
		#为什么不处理目录呢?因为我发现有时改下代码在svn的日志里也会有目录的路径
		## 因为目录里有我没有改过的文件 而这些文件不希望拷备
		## 我改过的、新加的文件肯定会在svn的日志里
		if [ ${copyCode_isProcessDir}X = "false"X  ] && [ -d $copySource ] 
		then
			echo 目录跳过不处理 $copySource >&2
			continue
		fi

		# 先取出目标路径父目录 如果不存在则创建 
		# 这里的用意主要是为了保证拷备时目录结构不发生变化 这也是copyCode的主要特点
		parentTargetPath=`dirname $copyTarget`
		if [ ! -d $parentTargetPath ] 
		then
			mkdir -p $parentTargetPath
		fi
		
		#如果是调试模式则输出对应的拷备命令方便调试
		if [ ${IS_DEBUG}X = "true"X ]
		then
			echo cp -rf $copySource $copyTarget
		fi	
        cp -rf $copySource $copyTarget
		result=$?
		fun_processStatisticInfo $result "+1"

		#针对内部类的处理
		#对于有内部类的java文件其会生成多个class文件
		#如StssdRiaAction.class StssdRiaAction$1.class StssdRiaAction$2.class
		#所以我需要把这些文件识别出来也拷过去

		#将source的文件名取出来
		copySourceFileFullName=`basename $copySource`
		copySourceParentPath=`dirname $copySource`
		targetParentPath=`dirname $copyTarget`
		#如果是JAVA文件 即文件名包含class字样 再处理内部类的问题其它不用处理
		#下面先判断复制源文件有没有出错 如果出错这里就不用处理了 一般出错是因为源文件不存在
		if [ $result == 0 ] && [[ $copySourceFileFullName =~ ".class" ]]
		then
			# 取出文件名 不带后缀 
			copySourceFileName=`echo $copySourceFileFullName |cut -d. -f1`;
			# 注如下grep的意思是取出类似  grep StssdRiaAction$ 的文件 但$是特殊字符需要转义
			# 在一般命令中使用\\$即可 但在``中对\也要转码 所以变成4个\
			for otherFile in `ls $copySourceParentPath |grep $copySourceFileName\\\\$`
			do
				source_OtherFile=$copySourceParentPath/$otherFile;
				target_OtherFile=$targetParentPath/$otherFile;
				if [ ${IS_DEBUG}X = "true"X ]
				then
					echo cp -rf $source_OtherFile $target_OtherFile
				fi	
				cp -rf $source_OtherFile $target_OtherFile
				result=$?
				fun_processStatisticInfo $result
			done
		fi
    done

elif [ $SOURCE_COUNT -eq 1 ] && [ $TARGET_COUNT -eq 1 ]
then
	#echo "一对一类型"
	if [ ${IS_DEBUG}X = "true"X ]
	then
		echo "cp -rf $SOURCE $TARGET"
	fi	
	cp -rf $SOURCE $TARGET
	result=$?
	fun_processStatisticInfo $result
elif [ $SOURCE_COUNT -eq 1 ] && [ $TARGET_COUNT -gt 1 ] 
then
	#echo "一对多类型"
	for currentTarget in $TARGET
	do
		if [ ${IS_DEBUG}X = "true"X ]
		then
			echo "cp -rf $SOURCE $currentTarget"
		fi	
		cp -rf $SOURCE $currentTarget
		result=$?
		fun_processStatisticInfo $result
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
		if [ ${IS_DEBUG}X = "true"X ]
		then
			echo "cp -rf $currentSource $TARGET"
		fi	
        cp -rf $currentSource $TARGET

		result=$?
		fun_processStatisticInfo $result
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
		if [ ${IS_DEBUG}X = "true"X ]
		then
			echo "cp -rf ${arraySource[i]} ${arrayTarget[i]}"
		fi	
		cp -rf ${arraySource[i]} ${arrayTarget[i]}
		result=$?
		fun_processStatisticInfo $result
	done;
else 
	echo "配置文件有问题"
	exit 2
fi

#输出统计信息
if [ ${IS_OUTPUT_COPY_STATISTIC_INFO}X = "true"X ]
then
	echo 
	echo 准备复制$count_Source 个文件
	echo 实际复制$count_Real 个文件
	echo 正确处理$count_Ok 个文件
	echo 复制出错$count_Error 个文件
fi


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
