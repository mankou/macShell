#!/bin/bash
# create by m-ning at 20160809
# desc 删除某目录下的文件
## 支持 删除N天前文件
## 支持 只保留最近N个最新的文件
## 支持 过滤后缀名 即只有某后缀名的文件才被删除
## 支持 -l 参数 只显示要删除的文件 而不实际删除 用于调试
## 支持 -o 参数 将删除的文件放取指定日志文件中方便其它脚本调用写日志

author=man003@163.com
version=V1-20160809

#############################使用说明####################################################

#==============================how to use==============================
# 让该脚本有可执行权限 chmod +x ./delete.sh
# 运行该脚本 如下有一些例子


# 删除路径最好用绝对路径 相对路径也行 但推荐用绝对路径


# 示例说明 如下所有命令都可以加上 -l 开启调试选项
# 这样只列出程序要删除的文件但不会真的删除 
# ./delete.sh -n2 -l testDir

# 示例1 保留某目录下最新的2个文件或者文件夹 
# ./delete.sh -n2  testDir/

# 示例2 支持后缀名 保留某目录下 文件名以zip结尾的 2个文件或文件夹
#./delete.sh -n2 -s zip testDir/

# 示例3 删除某目录下3天前的文件
# 注 这里输入N 即会删除N+1天及之前的文件 也即输入2会删除3天前的文件
# 注 在这里输入2 即+2 也即大于2天的文件 因都是整数 也就是3天及3天前的文件
# ./delete.sh -d2 testDir/

# 示例4 支持后缀名 删除某目录下3天前 并且后缀是zip的 文件
# ./delete.sh -d2 -s zip testDir/

# 示例5 指定删除日志文件
# 如下-o 参数指定删除文件日志 因为该脚本输出的日志很多 其它脚本调用时不需要这些日志 只需要知道删除了哪些文件 这里把删除的文件放到指定日志中 用户只需要cat 日志文件即可取出
#./delete.sh -n2 -l -o /Users/mang/Desktop/delete.log testDir >/dev/null 2>&1
#cat /Users/mang/Desktop/delete.log

# 示例6 在其它脚本中使用
# 注在其它脚本中调用该脚本时不需要该脚本输出的日志 只想知道删除了哪些文件 如下用-o 参数把删除的文件重定向到某一文件 然后再cat出来可用于写日志等
# 注 如下2>&1是必须的 否则该脚本会输出rm的命令 因为delete.sh中使用了xargs -t 其输出在错误输出中 20160810试验的
# 如下三句是代码示例
#delete.sh -n3 -o $localPath/lastDelete.log -s $suffix $localPath >/dev/null 2>&1
# 如下把要删除的文件输出到控制台 方便重定向写日志
#cat $localPath/lastDelete.log


# ==============================exitcode=========================
## 148 未知选项 为什么起148呢 因为148+256=404
## 1 删除路径为空


# ==============================脚本技巧点========================
## 同时处理命令行选项和参数
## ls -tl 按修改时间倒序排序
## 如下处理后缀名的手法 原来ls *zip -tl 可以 但ls *zip -tl 路径就不行 所以我用grep了
	## ls -tl $deletePath|sed -n '2,$p'|grep "$suffix\$">$BASE_PATH/ls.temp
## 注 如下sed -n "" 必须是双引号 不能是单引号 因为你里面引用了变量
	## sed -n "$[newestCount+1],\$p" $BASE_PATH/ls.temp|tee $BASE_PATH/delete.temp


#==============================todo==============================

# ==============================history=========================
# 20160810 V1 初版

#########################如下是配置区域#########################################################

#是否输出脚本运行时间 true表示输出 false表示不输出
IS_OUTPUT_RUNTIME="true";

#是否在脚本执行完后输出版本信息 true表示输出 false表示不输出
IS_OUTPUT_VERSION="true"

#时间戳
datestr=`date "+%Y%m%d%H%M%S"`

if [ ${IS_OUTPUT_RUNTIME}X = "true"X ]
then
	#echo start at `date -d today +"%Y-%m-%d %T"`====================
	echo start at `date  +"%Y-%m-%d %H:%M:%S"`====================
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


# 如果tmp目录不存在 则新建
TMP_PATH=$BASE_PATH/tmp
if [ ! -d $TMP_PATH ]
then
	echo $TMP_PATH 目录不存在 将新建
	mkdir $TMP_PATH
fi



# 是否删除临时文件 true 表示删除 false表示不删除
IS_DELETE_TEMP="false"

#定义临时文件路径
lsTmp=$TMP_PATH/${SHELL_NAME}_ls.tmp
lsAwkTmp=$TMP_PATH/${SHELL_NAME}_ls_awk.tmp
deleteTmp=$TMP_PATH/${SHELL_NAME}_delete.tmp

#########################如上是配置区域#########################################################

echo 正在解析命令行选项 $*
while getopts d:n:s:o:l opt
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
     o) echo "[parse parameter]found the -o option,$OPTARG"
		 # 将delete_log处理成绝对路径 并且如果父级目录不存在则创建
		delete_log=`getAbsolutePath.sh -fc $OPTARG`
		echo [parse parameter]处理相对路径后 $delete_log;;
     *) echo "[parse parameter]unknown option:$opt"
		exit 148;;
  esac
done

# 取出要删除的路径 这里以参数的形式输入(非选项)
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

if [ -z $deletePath ]
then
	echo [error]删除路径不能为空
	exit 1
else
	echo [parse parameter]删除路径 $deletePath
	deletePath=`getAbsolutePath.sh -fc $deletePath`
	echo [parse parameter]处理相对路径后 $deletePath
fi

## 这里是脚本逻辑
echo
echo 要删除的文件如下
# 判断是deleteDays功能还是retainNewest功能
if [ ${shellFunction}X = "deleteDays"X ]
then
	#echo "find $localPath -name "*$suffix" -mtime +"$deleteDays"|xargs ls -l";
	# 注不要写成 find . -name *.* 这样只能查temp.out这样的文件 但查不出temp这样的文件
	find $deletePath -name "*$suffix" -mtime +"$deleteDays"|xargs ls -l|tee $deleteTmp;

	# 如果输入-l参数 则只列出要删除的内容 不实际删除 免得删除错了
	if [ ! ${is_list}X = "true"X  ]
	then
		find $deletePath -name "*$suffix" -mtime +"$deleteDays"|xargs rm -rf;
	fi
elif [ ${shellFunction}X="retainNewest"X ]
then
	#echo "retainNewest" 功能";
	# 只保留最近的N个文件
	# 先把文件找出来 按mtime倒序排序 放到临时文件中
	# 删除第N+1行到最后一行中的文件
	
	# 如下 ls -lt 按时间逆序排 最新的文件在前面
	# sed -n '2,$p' 把第2行到最后一行输出到临时文件 因为ls -lt输出如下 所以要用sed处理下
	#total 0
	#-rw-r--r-- 1 mang staff 0 Aug  9 17:27 2.zip
	#-rw-r--r-- 1 mang staff 0 Aug  9 17:27 3.zip
	ls -tl $deletePath|sed -n '2,$p'|grep "$suffix\$">$lsTmp

	#处理lsTmp 把文件名处理成绝对路径 这样下面删除时就不需要切换到该目录下了
	# 注 -v 是传递参数的方式 p"/"$9 其中"/"是print中连接字符串的方式
	cat $lsTmp|awk -v p=$deletePath '{print $1,$2,$3,$4,$5,$6,$7,$8,p"/"$9}' > $lsAwkTmp

	# 注 如下sed -n "" 必须是双引号 不能是单引号 因为你里面引用了变量
	# 注 如下使用tee接t型管 是为了把删除的数据输出的标准输出中
	sed -n "$[newestCount+1],\$p" $lsAwkTmp|tee $deleteTmp

	# 如果输入-l参数 则只列出要删除的内容 不实际删除 免得删除错了
	# 这里如果没有输入-l参数 则真的删除
	if [ ! ${is_list}X = "true"X ]
	then
		#cat $BASE_PATH/delete.temp
		# 注如下-t 是为了把命令输出出来
		# -n5 是每5个删除一下 免得要删除的文件太多出现问题
		# awk '{print $9}' 输出第9列
		# 注 如下-t 会输出实际的命令 其输出在错误输出中 在其它脚本中调用该脚本你可能想屏蔽该脚本的输出有可能会用到
		# 注 如下第一句不能屏蔽输出 第二句可以
		#cat $deleteTmp|awk '{print $9}'|xargs -t -n5 rm -rf >/dev/null
		#cat $deleteTmp|awk '{print $9}'|xargs -t -n5 rm -rf 2>/dev/null
		cat $deleteTmp|awk '{print $9}'|xargs -t -n5 rm -rf
	fi

fi

# 如果用户输入了删除日志路径 则这里只把要删除的文件写入日志文件方便其它程序调用
# XXX 我不能解释为什么用 -n不对 而用 ! -z 是对的呢
#  如果我换成-n 用如下命令就会出错
#./delete.sh -n2 -l testDir/

#if [ -n $delete_log ]
if [ ! -z $delete_log ]
then
	cat $deleteTmp>$delete_log
fi
# 判断是否删除临时文件
if [ ${IS_DELETE_TEMP}X = "true"X ]
then
	rm -rf $deleteTmp $lsTmp
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