#!/bin/bash
# create by m-ning at 20161124
# desc 删除某目录下的空目录
# 注 如果存在父目录/子目录 并且子目录是空目录的情况 则删除子目录后 也会删除父目录

author=man003@163.com
version=V1-20161124


#==============================how to use==============================
#示例1 删除某目录下空目录
# /deleteEmptyDir.sh /Users/mang/Desktop/shellTest

if [ -z $1 ] 
then
	echo error-1 删除路径为空不能删除 1>&2
	exit 1
fi

# 循环删除空目录 直到找不到空目录
# 主要是为了处理 某一目录下还有子目录 如果子目录是空目录 则删除子目录后 也要删除父目录
emptyCount=`find $1 -type d -empty|wc -l`
while [ $emptyCount -gt 0  ]
do
	find $1 -type d -empty
	#find $1 -type d -empty|xargs -t -n5 rm  -rf 
	find $1 -type d -empty -print0 |xargs -0 -n5 rm  -rf 
	emptyCount=`find $1 -type d -empty|wc -l`
done
