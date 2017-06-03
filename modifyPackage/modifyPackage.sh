#!/bin/bash
# 简介 修改java包名路径
# 描述 有时需要批量修改java文件的路径 包括文件实际存储的路径 java文件里引用的包名等 该脚本就用于处理这类问题
# 运行方式
# chmod +s *.sh
# ./modifyPackage.sh

author=man003@163.com
version=V1.0-20170601


###########命名规则说明#############
# 大写_大写 系统变量(通用的变量) 如脚本路径 脚本名  
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

# 原包名
package_old=mang.demo.springmvc

# 基准路径
base_path=$SHELL_PATH

# 新包名
package_new=com.mtest


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

echo 基准路径 $base_path
echo 原包名  $package_old
echo 新包名  $package_new
echo



#############定义根据上述变量计算所得的变量##############

# 通过包名获取java文件实际路径
# 如包名为 mang.demo.springmvc 则其java路径在 mang/demo/springmvc
packageFilePathOld=`echo "$package_old" | sed 's#\.#/#g'`
packageFilePathNew=`echo "$package_new" | sed 's#\.#/#g'`


# 处理java文件的路径
echo 正在处理 java文件存储路径
javaPathFrom=$base_path/$packageFilePathOld
javaPathTo=$base_path/$packageFilePathNew
if [ -d $javaPathFrom ]
then
    if [ ! -d ${javaPathTo}  ]
    then
        mkdir -p ${javaPathTo}
    fi
    mv $javaPathFrom/* $javaPathTo
    
    # 删除基准目录下的空目录
    # 因修改java文件路径后 原包名下的文件都移动到新包名下 原包名就有很多空文件夹这里把空文件夹都删除
    echo 删除空目录
    deleteEmptyDir.sh $base_path
fi

echo

# 正在处理 java文件里的包名路径
echo 正在处理 java文件包路径
find $base_path -name "*.java" |xargs sed -ig "s/$package_old/$package_new/g"
find $base_path -name "*.javag" |xargs -n5 rm -rf


echo
echo done.


