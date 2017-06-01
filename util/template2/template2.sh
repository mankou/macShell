#!/bin/bash
# 简介 shell模板
# 描述 原来有一个shell模板 但越发的复杂 现在想要一个简单的模板 所以这里又开发一个新的模板
# 运行方式
# chmod +s *.sh
# ./template2.sh

author=man003@163.com
version=V1.0-20170526

###########命名规则说明#############
# 大写_大写 通用的变量 如脚本路径 脚本名  
# 小写_小写 工程定义的可修改的变量 这些变量可通过配置文件修改
# 峰驼写法  脚本中自己的使用的变量 脚本内部使用的变量


#################定义系统变量##################

# 脚本当前路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
SHELL_NAME=`basename $0`
PARENT_PATH=`dirname $SHELL_PATH`;
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

# 原工程名称
project_name_old=springmvc-demo

# 原工程中maven的 groupId
group_id_old=mang.demo

# 原工程中包名前缀
package_old=mang.demo.springmvc

# 原工程中开发代码的路径前缀
java_path_prefix_develop=src/main/java
# 原工程中测试代码的路径前缀
java_path_prefix_test=src/test/java

# 新工程的名称
project_name_new=mtest

# 新工程 maven中的groupID 用于替换pom.xml
group_id_new=com.mtest

# 新工程包名 
package_new=com.mtest


################定义自己的函数#####################




###  ------------------------------- ###
###  Main script                     ###
###  ------------------------------- ###

# 获取配置文件覆盖变量默认值
initConfig=${SHELL_PATH}/${SHELL_NAME}.config
if [ -f $initConfig ]
then
    echo 采用 ${SHELL_NAME}.config 覆盖默认配置
    . $initConfig

fi

echo 新工程名  $project_name_new 
echo 新groupID $group_id_new
echo 新包名    $package_new
echo


#############定义根据上述变量计算所得的变量##############



echo
echo done.


