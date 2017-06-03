#!/bin/bash
# 简介 处理gui反编译后java文件
# 描述 用gui反编译后的java文件 保存后是有注释的 该脚本用于去除注释
# 运行方式
# chmod +s *.sh
# ./processGuiJava.sh

author=man003@163.com
version=V1.0-20170601

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
RELIANT_SH="
	$PARENT_PATH/util/deleteEmptyDir.sh
"
#$PARENT_PATH/util/tp.sh
for rs in $RELIANT_SH
do
	# 如果没有可执行权限 把权限加上
	if [ ! -x $rs ]; then
		chmod +x $rs
	fi
done


###############定义脚本相关变量###################

# 基准路径
base_path=$SHELL_PATH
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

echo 基准路径  $base_path
echo


#############定义根据上述变量计算所得的变量##############
echo 正在处理 行首的注释
# 样例如下
# /*    */  java代码
# sed 命令解释
# 如下sed -ig 表示在原文件上操作 因在mac上不支持-i选项 所以用-ig 选项 其会把原文件以g结尾 所以下一句再删除
# sed 命令中用#做为分隔符 因为我替换的文本中有/ 所以用#比较好
# \*.*\*  其中\*是转义 .* 表示任意字符  合起来匹配 /*   */的文本
find $base_path -name "*.java" |xargs sed -ig "s#/\*.*\*/##g"
find $base_path -name "*.javag"|xargs -n5 rm -rf 

echo 正在处理 文件末尾的注释
# 样例如下
#/* Location:              
# * Java compiler version: 7 (51.0)
# * JD-Core Version:       0.7.1
# */
for line in `find $base_path -name "*.java"`
do
    # 命令解释
    # -v ^\/\*  其中\/ 和\* 表示转义  合起来表示删除/*开头的行
    # -v '^\s*\*'  \s*表示空白字符重复n次 \*表示转义 合起来表示删除包含  以空白字符开头到* 这样的行
    cat $line|grep -v '^\/\*'|grep -v '^\s*\*'>$line.tmp
    mv $line.tmp $line
done


echo
echo done.


