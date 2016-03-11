#!/bin/bash
# author:m-ning@neusoft.com
# create:2015-01-04 22:27
# modify:2015-01-14 22:22
# version 1
# TODO&QUES 
 # 目前该脚本大概总计只能计算到50万左右的行数 不知道是不是find 查出的文件太多 管道给wc 不认导致

#功能描述：统计某一目录代码行数、文件个数
# 功能1：统计代码总行数 结果默认存在wcm.result中 (注：可配置每次计算时是否清除原来的数据)
 # 功能2：按文件类型分别统计代码行数(*.js *.java)
 # 功能3：提供选项文件中的空行是否计数 ./wcm.sh -n
 # 功能4：统计文件个数
 # 功能5：按文件类型分别统计文件个数
 # 功能6：针对每个路径分别统计代码行数、文件个数 结果默认存在wcm.result.patt_respective (注 每次计算会清除以前的数据)

# 使用说明
 # 使用该脚本的前提条件
  # 第1步:设置该脚本具有执行权限 chmod a+x wcm.sh
  # 第2步:在wcm.config中配置要统计的路径、哪些后缀需要统计代码行数、哪些后缀需要统计文件个数

 # 统计代码行数及文件个数示例 这是最简单的用法 将采用默认的配置文件 ./wcm.config
  # ./wcm.sh
 
 # 过滤掉文件中的空行，即空行不计数 示例
  # ./wcm.sh -n

 # 关于配置文件使用
  # 如果用户不指定配置文件,则默认使用 ./wcm.config 配置文件
  # 如果用户需要指定配置文件 则用如下命令 wcm.sh -f your_confg_path 
   # 如wcm.sh -f /home/mang/wcm.config
   # 为什么支持用户自定义配置文件：如果需要执行多组任务只需要复制并修改配置文件，通过-f参数指定不同的配置，而不需要再去复制脚本。


#代码开始====================================================================================================
#如果在MacOSX (Mountain Lion),必须先执行两条export，否则在编译阶段会报错：'sed: RE error: illegal byte sequence' 先执行这两句。 也不知道为什么
export LC_COLLATE='C'
export LC_CTYPE='C'

# 默认配置文件 如果用户不指定配置文件则使用默认配置文件
CONFIG=wcm.config

# 用于获得脚本所在路径的，因为如果你把该脚本加到PATH中然后在其它路径中使用命令 wcm.sh 则使用默认配置文件时会出错
BASE_PATH=$(cd $(dirname "$0");pwd)
CONFIG="$BASE_PATH/$CONFIG"

# 如果未输入参数则使用默认配置文件
if [ -z "$1" ];then
	echo "[info]if you do not designate the config file,we will use the  default config file named "$CONFIG
	if [ ! -f "$CONFIG" ] ;then
		echo "[error]sorry I can not find $CONFIG!!!"
		exit 1
	fi
# 这里主要防止用户直接输入wcm.sh wcm.config 这样的命令。因为我想如果要自己指定配置文件必须用命令wcm.sh -f wcm.config的命令。
else
	#para=`echo $1|cut -c1`
	# 之所以echo $1x 是因为如果用户输入wcm.sh -n 则这里就变成echo -n 但-n是echo的选项 echo什么也不输出 导致你管道给cut时什么也没有
	para=`echo $1x|cut -c1`
	# 注如下 != 两边必须有空格 如果你写成[ $para!=- ] 则永远返回0 也即if永远为true 2015-1-4我试验时发现
	if [ $para != - ]; then
		echo "[error] unknow param"
		exit 1
	fi

fi

# 循环处理选项
while getopts :nf: opt
do
	case "$opt" in
		f)
			# 如果文件存在则使用该配置文件 否则报错
			if [ -f "$OPTARG" ];then
				CONFIG="$OPTARG"
			else	
				# 这里使用>&2 临时重定向描述符技巧 用于向错误文件中输出信息。当用户使用重定向该脚本标准错误时有用
				echo "[error]$OPTARG does not exist or is not a file!!!" >&2
				exit 1;
			fi;;
		n)
			OPT_N="1";;
		*) echo "unknown option:$opt" >&2
			exit 1;;
	esac
done

# 从配置文件中取出通用的配置
CONFIG_START_INDEX=`grep -n 'CONFIG_START' ${CONFIG} | cut -d: -f1`
CONFIG_END_INDEX=`grep -n 'CONFIG_END' ${CONFIG} | cut -d: -f1`
CONFIG_START_INDEX=$[CONFIG_START_INDEX+1]
CONFIG_END_INDEX=$[CONFIG_END_INDEX-1]

# 注:以下写法不对。你不能先把config截取出来放到变量中。因为变量中没有\n 其自动把\n转成空格了，所以你再去找DEST就不对
# 应该先把命令放到变量中，然后再一起执行
#CONFIG_TEXT=`sed -n ${CONFIG_START_INDEX},${CONFIG_END_INDEX}p $CONFIG |grep '^[^#]'`
#DEST=`echo $CONFIG_CONTENT|grep '^DEST'|cut -d= -f2`


CONFIG_TEXT="sed -n ${CONFIG_START_INDEX},${CONFIG_END_INDEX}p ${CONFIG}"
# 备份路径
DEST=`${CONFIG_TEXT} | grep '^DEST' | cut -d= -f2`
RESULT_FILENAME=`${CONFIG_TEXT} | grep '^RESULT' | cut -d= -f2`
RESULT=$DEST$RESULT_FILENAME
IS_CLEAR_OLD_DATA=`${CONFIG_TEXT} | grep '^IS_CLEAR_OLD_DATA' | cut -d= -f2`
# 注意等号两边必须有空格 否则这条测试永远正确 永远是true了
if [ "$IS_CLEAR_OLD_DATA"x = "true"x ] ;then
	echo [info]清空$RESULT
	cat /dev/null > $RESULT
fi
#======================从配置文件中取出路径=================================
PATH_START_INDEX=`grep -n 'PATH_START' ${CONFIG} | cut -d: -f1`
PATH_END_INDEX=`grep -n 'PATH_END' ${CONFIG} | cut -d: -f1`
PATH_START_INDEX=$[PATH_START_INDEX+1]
PATH_END_INDEX=$[PATH_END_INDEX-1]
#IFS=$'\n'
#拼接路径
for VAR in `sed -n ${PATH_START_INDEX},${PATH_END_INDEX}p $CONFIG |grep '^[^#]'`
do 
	WPATH="$WPATH $VAR"
done
#IFS=$IFSOLD

#=======================以下取出统计行数的相关配置======================================
#从配置文件中取出后缀配置所在行号
SUFFIX_START_INDEX=`grep -n 'INCLUDE_SUFFIX_START' ${CONFIG} | cut -d: -f1`
SUFFIX_END_INDEX=`grep -n 'INCLUDE_SUFFIX_END' ${CONFIG} | cut -d: -f1`
SUFFIX_START_INDEX=$[SUFFIX_START_INDEX+1]
SUFFIX_END_INDEX=$[SUFFIX_END_INDEX-1]
# 拼接后缀
# 下面设置IFSOLD本来是用于处理路径中有空格的问题，但后来也没有解决，这里先保留着反正不影响目前的功能
#IFSOLD=$IFS
#IFS=$'\n'
for VAR in `sed -n ${SUFFIX_START_INDEX},${SUFFIX_END_INDEX}p $CONFIG |grep '^[^#]'`
do 
	SUFFIX="$SUFFIX $VAR"
done
#IFS=$IFSOLD


#===================以下取出统计文件个数的相关配置==========================================
#从配置文件中取出后缀配置所在行号
FILECOUNT_START_INDEX=`grep -n 'INCLUDE_FILECOUNT_START' ${CONFIG} | cut -d: -f1`
FILECOUNT_END_INDEX=`grep -n 'INCLUDE_FILECOUNT_END' ${CONFIG} | cut -d: -f1`
FILECOUNT_START_INDEX=$[FILECOUNT_START_INDEX+1]
FILECOUNT_END_INDEX=$[FILECOUNT_END_INDEX-1]
# 拼接
# 下面设置IFSOLD本来是用于处理路径中有空格的问题，但后来也没有解决，这里先保留着反正不影响目前的功能
#IFSOLD=$IFS
#IFS=$'\n'
#这所以要赋为空 因为这里是函数 可能会多次执行
for VAR in `sed -n ${FILECOUNT_START_INDEX},${FILECOUNT_END_INDEX}p $CONFIG |grep '^[^#]'`
do 
	FILECOUNT="$FILECOUNT $VAR"
done
#IFS=$IFSOLD

# 如果文件不存在则创建
if [ ! -d $DEST ] ; then
	mkdir -p $DEST
fi
if [ ! -f $RESULT ] ;then
	touch $RESULT
fi

NOW=`date -d today +"%Y-%m-%d %T"`
echo |tee -a $RESULT
echo "#"${NOW} |tee -a $RESULT
# 把当前执行的命令也写到log中去
echo $0$*>>$RESULT



#============================== 函数声明======================================
#特别注意:这里声明一个函数 用于统计代码行数、按类型统计行数、文件个数、按类型统计文件个数
# 最后会调用该函数的
function computeLine() {
#================================统计总计有多少行=============================================
# 这时局部变量用于接参数的 表示要统计哪些路径 如果有多个路径前面已处理面空格分隔
local filePath=$1
# 如果路径为空 则行数为0 并提示没有设置路径 
# 如果不加双引号就报 binary operator expected 的错
if [ -z "$filePath" ] 
then
	echo "0(配置文件中未指定路径 所以行数为0)" 
else
	# 如果配置文件中没有指定文件后缀名则使用find命令查出所有文件再计算
	if [ -z "$SUFFIX" ]
	then
		# 如果没有使用-n 参数则表示不过滤空行 如果使用了-n参数 则表示空行也计算
		if [ -z $OPT_N ]
		then
			find $filePath -type f |xargs wc -l|tail -1
		else
			find $filePath |xargs sed '/^$/d'|wc -l
		fi
	else
	#上面拼接的后缀名为 *.js *.java 现在替换成find类型 *.js -o -name *.java (注意最前面也应该有个-name 这里没有加 放到find命令中加了)
		SUFFIX_TOTAL=`echo $SUFFIX|sed 's/ / -o -name /'`
		if [ -z $OPT_N ]
		then
			# 这里-type f 表示只查找文件也即排除目录
			echo 
			echo "总计行数(包含空行)(单位行):"
			#find $filePath -type f -name $SUFFIX_TOTAL |xargs wc -l|tail -1|cut -d" " -f2 |tee -a $RESULT
			find $filePath -type f -name $SUFFIX_TOTAL |xargs wc -l|tail -1
		else
			# 这里-type f 表示只查找文件也即排除目录
			echo 
			echo "总计行数(不包含空行)(单位行):"
			find $filePath -type f -name $SUFFIX_TOTAL |xargs sed '/^$/d'|wc -l

		fi
	fi
fi

#=======================按类型统计行数========================================
# todo 如果没用指定后缀或者没有指定路径 则不进行按类型统计行数的工作
for var in $SUFFIX
do
		if [ -z $OPT_N ]; then
			# 这里-type f 表示只查找文件也即排除目录
			echo "$var 行数(包含空行)(单位行):"
			# 注 最后cut -d " " -f2 是因为最后输出的结果是 4 total 第一列是空格 所以要以空格为分隔取第2段
			find $filePath -type f -name $var |xargs wc -l|tail -1
		else
			# 这里-type f 表示只查找文件也即排除目录
			echo "$var 行数(不包含空行)(单位行):"
			find $filePath -type f -name $var |xargs sed '/^$/d'|wc -l

		fi

done

#========================统计总计文件个数=====================================================
FILECOUNT_TOTAL=`echo $FILECOUNT|sed 's/ / -o -name /'`
echo
echo "总计文件个数:"
find $filePath -type f -name $FILECOUNT_TOTAL|wc -l

#========================按类型统计文件个数=====================================================
for var in $FILECOUNT
do
	echo "$var 文件个数:"
    find $filePath -type f -name $var|wc -l
done


}
#============函数结束===========================


# =================所有路径统计一个总的行数=================
#这里参数必须加引号 因为各个路径合并后有空格 函数以空格为分隔
computeLine "$WPATH" |tee -a $RESULT;


# =================每个路径分别统计=================
# 是否按路径分别统计
IS_STATISTICS_PATH_RESPECTIVE=`${CONFIG_TEXT} | grep '^IS_STATISTICS_PATH_RESPECTIVE' | cut -d= -f2`
# 如果按路径分别统计 则结果放在哪里
PATH_RESPECTIVE=`${CONFIG_TEXT} | grep '^PATH_RESPECTIVE' | cut -d= -f2`
RESULT_RESPECTIVE=$DEST$PATH_RESPECTIVE


if [ $IS_STATISTICS_PATH_RESPECTIVE = "true" ] ;then
	echo
	echo [info] 本脚本针对每个路径分别进行了统计，结果存储在$RESULT_RESPECTIVE;
	echo "#"${NOW} > $RESULT_RESPECTIVE 
	for var in `sed -n ${PATH_START_INDEX},${PATH_END_INDEX}p $CONFIG |grep '^[^#]'`
		do 
			echo >>$RESULT_RESPECTIVE;
		    echo "$var" >> "$RESULT_RESPECTIVE";
			# 调用函数分别统计各个路径情况
			computeLine "$var" >>$RESULT_RESPECTIVE
			#computeLine "$var" |tee -a $RESULT_RESPECTIVE
		done
fi

