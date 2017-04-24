#!/bin/bash

BASEPATH=/home/dxp
NOHUP_BAK_DXP=$BASEPATH/nohup/dxp
NOHUP_BAK_CDC=$BASEPATH/nohup/cdc

cd $BASEPATH
ndays="-1days"

function fun_getNewestFile {
	ls -tl $1|sed -n '2,2p'|awk '{print $9}'
}

while getopts c opt
do
  case "$opt" in
     c) isClean=true
		;;
     *) echo unexpect option $opt
		exit 148;;
  esac
done

# 解析参数
shift $[ $OPTIND -1 ]

# 取参数示例 如下只取出数组的第一个元素
# 注 为什么加() 把其变成数组 如果写成paramArray=$@就不是数组了 你就取不出元素了
# 注 因为我不会一次把元素取出来 所以用了2句 如本想以 ${$@[0]}
paramArray=($@);
DIR=${paramArray[0]}

if [ -z $DIR ]
then
	echo please input $DIR
	exit 1
fi

#LOG_DXP=nohup.out-dxp-$DIR
#LOG_CDC=nohup.out-cdc-$DIR
LOG_DXP=nohup.out-dxp
LOG_CDC=nohup.out-cdc
LOG_PATH=$BASEPATH/errorlog/$DIR

if [ ! -d $LOG_PATH ]
then
	mkdir -p $LOG_PATH
else
	echo dir already exist $LOG_PATH
	exit 2
fi

echo copy $LOG_DXP
cp $BASEPATH/dataexchange/bin/nohup.out $LOG_PATH/$LOG_DXP
# 取dxp最新日志文件
newestFileName_dxp=fun_getNewestFile $NOHUP_BAK_DXP
if [ ! -z $newestFileName_dxp ]
then
	cp $NOHUP_BAK_DXP/$newestFileName $LOG_PATH/$newestFileName_dxp-dxp
fi

echo copy $LOG_CDC
cp $BASEPATH/sacacdc/bin/nohup.out $LOG_PATH/$LOG_CDC

# 取cdc最新日志文件
newestFileName_cdc=fun_getNewestFile $NOHUP_BAK_CDC
if [ ! -z $newestFileName_cdc ]
then
	cp $NOHUP_BAK_CDC/$newestFileName $LOG_PATH/$newestFileName_cdc-cdc
fi


echo tar $DIR.tar.gz
tarFile=$BASEPATH/errorlog/$DIR.tar.gz
tar -czvf $tarFile -C $LOG_PATH  $LOG_DXP $LOG_CDC $newestFileName_dxp $newestFileName_cdc

ls -hl $tarFile


