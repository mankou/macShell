#!/bin/bash
#create by m-ning at 20160808
# desc 一键拷备
## 背景:每次替换license很多 所以想写一个批处理一键替换
## 功能说明:
## 在配置文件中指定要拷备的源文件 和目标路径即可
## 如果源文件是一个 目标路径是一个 则直接拷备
## 如果源文件是一个 目录路径是多个 则会把源文件分别拷备到各目标路径下
## 如果源文件是多个 目标路径是一个 则会把各个源文件拷备到该目标路径下
## 如果源文件是多个 目录路径也是多个 则一对一拷备,但必须保证源文件个数与目录路径个数一样 否则报错退出

## 其它说明
# 当源路径有多个时 目录路径为一个时 则目录路径必须是个目录

## 返回错误码说明
## 1 当n对n的情况下 源路径个数与目标路径个数不一致
## 2 配置文件有误 


author=man003@163.com
version=V1.0-20160808

#############################使用说明####################################################
# 使用说明
# 拷备时注意把依赖的脚本也一起拷走，目录结构不变 
# 让该脚本有可执行权限 chmod +x codeShell.sh 注其依赖的脚本也要加x权限
# 运行该脚本 ./codeShell.sh -f license.config

# 依赖的脚本
# getConfig/getConfig.sh


# history
# 2016-08-09 V1 初版 支持一对一 一对多 多对一 多对多的拷备


#########################如下是配置区域#########################################################
#时间戳
datestr=`date "+%Y%m%d%H%M%S"`

# 设置环境变量
BASE_PATH=$(cd $(dirname "$0");pwd)
PARENT_PATH=`dirname $BASE_PATH`;
PATH=$PATH:$PARENT_PATH/getConfig/;

source="~/.dir_colors"
target=/Users/mang/AppData/百度云同步盘/mac/macConfigBackup/shellConfigBak/
echo "cp -rf $source $target"
cp -rf ${source} $target
