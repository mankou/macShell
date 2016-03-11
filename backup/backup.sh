#!/bin/bash
# backup.sh 用于备份的脚本 
# author mang 
# create:2013年12月04日 星期三 21时53分46秒
# modify:2013年12月06日 星期五 14时08分21秒
# 功能描述：用于备份文件的脚本。 注意这里使用了绝对压缩路径 如果解压时不想使用绝对路径压缩则不要使用P选项
# 下一步可做的功能
## 添加-h选项 输出该脚本的用户帮助信息
# bug
## 目前不能处理带有空格的行
## -错误：刚开始你判断$1是否以-开头，如果不是就报错退出。所以如果你以后往脚本中添加功能 想在该脚本中使用单独的参数。就直接被这个if语句退出了。也即这个脚本只能使用选项而不能使用参数。


# 使用说明
## 使用方式一：使用默认的配置文件
### 把默认配置文件与该脚本放在同一目录下
### 在配置文件中设置相关参数如：备份路径 压缩包文件名等
### 确保该脚本具有x权限 chmod u+x backup.sh
### 运行该脚本: backup.sh

## 使用方式二：用户自己指定配置文件路径(当有多项备份任务而不想使用一个配置文件时可使用此种方式)
### 配置文件可放在任意路径下，但格式要与默认配置文件一致。最好把默认配置文件复制过去后修改参数
### 确保该脚本具有x权限 chmod u+x backup.sh
### 运行该脚本 backup.sh -f 配置文件路径



# 默认配置文件 如果用户不指定配置文件则使用默认配置文件
CONFIG=backup.config

# 用于获得脚本所在路径的，因为如果你把该脚本加到PATH中然后在其它路径中使用命令 backup.sh 则使用默认配置文件时会出错
BASE_PATH=$(cd $(dirname "$0");pwd)
CONFIG="$BASE_PATH/$CONFIG"

# 如果未输入参数则使用默认配置文件
if [ -z "$1" ];then
	echo "[info]if you do not designate the config file  we will use the  default config file named backup.config"
	if [ ! -f "$CONFIG" ] ;then
		echo "[error]sorry I can not find $CONFIG!!!"
		exit 1
	fi
# 这里主要防止用户直接输入backup.sh backup.config 这样的命令。因为我想如果要自己指定配置文件必须用命令backup.sh -f backup.config的命令。
else
	para=`echo $1|cut -c1`
	if [ $para != - ];then
		echo "[error] unknow param"
		exit 1
	fi

fi

# 循环处理选项
while getopts :f: opt
do
	case "$opt" in
		f)
			# 如果文件存在则使用该配置文件
			if [ -f "$OPTARG" ];then
				CONFIG="$OPTARG"
			else	
				echo "[error]$OPTARG does not exist or is not a file!!!"
				exit 1;
			fi;;
		*) echo "unknown option:$opt"
			exit 1;;
	esac
done


#从配置文件中取出相关参数
START_INDEX=`grep -n 'config_start' ${CONFIG} | cut -d: -f1`
END_INDEX=`grep -n 'config_end' ${CONFIG} | cut -d: -f1`
CONFIG_TEXT="sed -n ${START_INDEX},${END_INDEX}p ${CONFIG}"
# 备份路径
DEST=`${CONFIG_TEXT} | grep 'DEST' | cut -d= -f2`
# 备份文件名
BACKUP_FILE_NAME=`${CONFIG_TEXT} | grep 'NAME' | cut -d= -f2`




# 判断目的路径是否存在如果不存在则建立目录 
if [ ! -d $DEST ];then
echo "[信息]目录不存在 自动创建目录..."
	mkdir  $DEST
fi


# 取出配置文件中要备份的路径在备份文件的起始行号和结束行号。之所以要+1 -1 是因为这两行不是记录路径的
BACKUP_PATH_START=`grep -n 'backup_path_start' $CONFIG| cut -d: -f1`
BACKUP_PATH_END=`grep -n 'backup_path_end' $CONFIG| cut -d: -f1`
BACKUP_PATH_START=$[ $BACKUP_PATH_START+1 ]
BACKUP_PATH_END=$[ $BACKUP_PATH_END-1 ]

# 循环读入要备份的路径拼接到变量$SOURCE中
# 下面设置IFSOLD本来是用于处理路径中有空格的问题，但后来也没有解决，这里先保留着反正不影响目前的功能
IFSOLD=$IFS
IFS=$'\n'
for VAR in `sed -n ${BACKUP_PATH_START},${BACKUP_PATH_END}p $CONFIG |grep '^[^#]'`
do 
	SOURCE="$SOURCE $VAR"
done
IFS=$IFSOLD


# 按日期生成压缩包最后的文件名
DEST="$DEST$BACKUP_FILE_NAME`date +%Y%m%d%H%M`.tar.gz"

# 生成压缩包 这里采用绝对路径压缩 所以解压时也要使用绝对路径解压才能达到覆盖的效果
echo "[信息]正在生成压缩文件...."
tar -czvPf $DEST  $SOURCE
echo
echo "[信息]生成的压缩文件的路径为: $DEST"

