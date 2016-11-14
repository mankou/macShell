#!/bin/bash
#create by m-ning at 20160810
# desc 获取绝对路径
## 因有时用户传到脚本的是相对路径 在处理时容易出问题 所以该脚本将其处理成绝对路径

author=man003@163.com
version=V1.0-20160810

#############################使用说明####################################################

# 使用说明
# 配置文件需与该脚本在同一目录下 注 所有配置都在配置文件oracleBak.config中修改 不需要修改该脚本中的内容
# 让该脚本有可执行权限 chmod +x ./oracleBak.sh
# 运行该脚本 ./oracleBak.sh

## 示例1
##处理目录的相对路径
#./getAbsolutePath.sh -d testDir/
#./getAbsolutePath.sh -d ~/Desktop

## 示例2
##处理文件的相对路径
#./getAbsolutePath.sh -f test/delete.log

## 示例3 
##处理目录的相对路径的同时创建目录
#./getAbsolutePath.sh -dc testDir/

## 示例3 
##处理文件的相对路径的同时创建文件父级目录 常用于创建文件前先创建其父目录 然后touch 文件就不会出错了
# 注只是创建文件父级目录 不会创建文件
#./getAbsolutePath.sh -fc test/delete.log

# 其它说明
## 如果传入的是绝对路径则返回的也是绝对路径
## 返回的路径对于目录最后面没有/ 如/home/mang 所以你如果要拼接路径需要自己加上/


# history
# 2016-2-19 V1 初版

# exitcode 
##exit 1 未输入NEW_PATH
##exit 2 如果即没有指定 -d 参数 也没有指定 -f 参数 则报错 因为我无法判断是目录还是文件
##exit 3 如果同时指定了 -d -f 参数 也返回错误



while getopts dfc opt
do
  case "$opt" in
     d) 
		fileType="dir"
		para_d="true";;
     f) 
	 	fileType="file"
		para_f="true";;
	 c)
		is_create_path_when_not_exist="true";; 
     *) echo "unknown option:$opt"
		exit 148;;
  esac
done

# 处理参数
shift $[ $OPTIND -1 ]
count=1
# 只取出数组的第一个元素
# 注 为什么加() 把其变成数组 如果写成paramArray=$@就不是数组了 你就取不出元素了
# 注 因为我不会一次把元素取出来 所以用了2句 如本想以 ${$@[0]}
paramArray=($@);
NEW_PATH=${paramArray[0]}
OLD_PATH=`pwd`

#exit 1 未输入NEW_PATH
if [ -z $NEW_PATH ] 
then
	exit 1
fi

#exit 2 如果即没有指定 -d 参数 也没有指定 -f 参数 则报错 因为我无法判断是目录还是文件
if [ -z $fileType ]
then
	exit 2
fi

#exit 3 如果同时指定了 -d -f 参数 也返回错误
if [ ${para_d}X = "true"X ] && [ ${para_f}X = "true"X ]
then
	exit 3
fi


# 判断待处理的是文件还是目录 如果是文件则取出其父目录
if [ ${fileType}X = "dir"X ]
then
	DIR_PATH=$NEW_PATH
elif [ ${fileType}X = "file"X ]
then
	# 说明是文件
	DIR_PATH=`dirname $NEW_PATH`
	FILE_NAME=`basename $NEW_PATH`
fi

# 如果目录不存在则新建
if [ ! -d $DIR_PATH ] 
then
	mkdir -p $DIR_PATH
	is_need_delete="true"
fi

result=`cd $DIR_PATH;pwd`

# 判断是否需要删除路径
# 当用户没有指定-c 自动创建目录 并且目录本来就不存在 则这里把创建的目录删除
if [ ${is_create_path_when_not_exist}X != "true"X ] && [ ${is_need_delete}X = "true"X ]
then
	#echo "rm -rf $NEW_PATH"
	rm -rf $NEW_PATH
fi

# 如果是目录直接输出 如果是文件需要拼接文件名
if [ ${fileType}X = "dir"X ]
then
	echo $result
elif [ ${fileType}X = "file"X ]
then
	echo $result/$FILE_NAME
fi

# 切换到原来的目录 不影响其它程序
cd $OLD_PATH


