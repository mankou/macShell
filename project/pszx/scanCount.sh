#!/bin/bash
# 简介 配送割接-辅助统计scanCount的脚本
# 运行方式
# chmod +x *.sh
# ./scanCount.sh

author=man003@163.com
version=V1.0-20170630

###########命名规则说明#############
# 大写_大写 通用的变量 如脚本路径 脚本名  
# 小写_小写 工程定义的可修改的变量 这些变量可通过配置文件修改
# 峰驼写法  脚本中自己的使用的变量 脚本内部使用的变量


#################定义系统变量##################

# 脚本当前路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
SHELL_NAME=`basename $0`
PARENT_PATH=`dirname $SHELL_PATH`;
# 脚本不包括后缀的文件名 如xx.sh 则文件名为 xx
SHELL_NAME0=${SHELL_NAME%.*}
cd $PARENT_PATH

# 设置环境变量
PATH=$PATH:$PARENT_PATH/util/;

# 依赖的shell 一行一个 如果没有x 权限 自动设置
#RELIANT_SH="
#	$PARENT_PATH/util/deleteEmptyDir.sh
#"
RELIANT_SH=""

#$PARENT_PATH/util/tp.sh
for rs in $RELIANT_SH
do
	# 如果没有可执行权限 把权限加上
	if [ ! -x $rs ]; then
		chmod +x $rs
	fi
done


###############定义脚本相关变量###################
# scan路径
scan_file_path=/Users/mang/Desktop/scanPath

# find查找到的文件 存放路径 如果不指定使用默认的
result_find=""

# 排序后文件路径 如果不指定使用默认的
result_sort=""

################定义自己的函数#####################



###  ------------------------------- ###
###  Main script                     ###
###  ------------------------------- ###

# 获取配置文件覆盖变量默认值
initConfig=${SHELL_PATH}/${SHELL_NAME0}.config
if [ -f $initConfig ]
then
    echo 采用 ${SHELL_NAME}.config 覆盖默认配置
    . $initConfig
fi

# 如果指定路径使用默认的路径
if [ -z $result_find ]
then
    result_find=$SHELL_PATH/scanCount-result.find
fi

if [ -z $result_sort ]
then
    result_sort=$SHELL_PATH/scanCount-result.sort
fi

# 如果文件存在删除
if [ -f $result_find ]
then
    rm -rf $result_find
fi

if [ -f $result_sort ]
then
    rm -rf $result_sort
fi

echo 文件路径  $scan_file_path
echo


### 正式逻辑####################
cd $scan_file_path

for filePath in `find . -name "*.jpg"`
do
    fileName=`basename $filePath`
    scanName=`echo $fileName | awk 'BEGIN{FS="_"}{print $1}'`
    filePath_cut=`echo ${filePath:2}`
    #echo ${filePath:2}
    echo finding $scanName ...
    echo $scanName $fileName $filePath_cut >>$result_find
done

echo
echo sorting  ...
sort $result_find >$result_sort


# 再拷一份用于入库操作

# 取文件所在路径
resultSortPath=$(cd $(dirname "$result_sort");pwd)
# 取文件名
resultSortFileName=`basename $result_sort`
# 取不带后缀的文件名
resultSortFileName0=${resultSortFileName%.*}
# 取文件后缀名
resultSortExtension=${resultSortFileName#*.}

result_sort_db=$resultSortPath/$resultSortFileName0-db.$resultSortExtension
cp $result_sort  $result_sort_db


# 注不明白为什么在linux上操作还有编码不一致的问题
# 有可能文件名拷到linux上就是乱码 你没注意而已 然后find找出来的文件也是乱码
echo iconv ....
iconv -f GB18030 -t UTF8 $result_sort > ${result_sort}.conv
iconv -f GB18030 -t UTF8 $result_sort_db > ${result_sort_db}.conv
mv ${result_sort}.conv ${result_sort}
mv ${result_sort_db}.conv ${result_sort_db}

echo
echo file saved in $result_sort $result_sort_db
echo done.


