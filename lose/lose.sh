#!/bin/bash
# author:m-ning@neusoft.com
# create: 201505072307
# modify: 201505091749
# version:3
# desc:用于天津港装载机ping包日志分析
# ===============================使用说明==============================
# 1. 目录结构必须如下  
	#    log/71/ping/
	#    log/80/ping/
	#	......
	#	lose.sh
 #1.1 注：路径必须是英文
 #1.2 注：所有装载机的日志需要放在一个叫log的目录下
 #1.3 注：lose.sh 与log必须在同一目录下
 #1.4 注：装载机日志的目录格式需为 80/ping的形式
# 2. 为loseCore.sh 添加执行权限： chmod +x ./loseCore.sh
# 3. 执行： ./loseCore.sh
# 4. 结果存储在result目录下
	#  80.result 表示80装载机ping包日志初步分析后的结果(目前已经没有，默认会删除)
	#  80.result.time 表示在80.result的基础上添加丢包率对应的时间
	#  80.result.time.no100 表示在80.result.time的基础上删除丢包率为100%的行的
	#  80.result.time.no100.day 表示在80.result.time.no100的基础上去掉丢包率为0%的 并按日期升级、丢包率降序排序

# ================================history=================================
# 2015-05-07 V1 初步提取
# 2015-05-08 V2 每行提取时间 并重新排列列顺序
# 2015-05-09 V3 按日期升序、丢包率降序排序

#=======================定义变量============================================
DEST=./result; #结果文件存储路径
TMP=./result/tmp; #临时文件存储路径
SOURCE=./log; #要分析的文件放在什么目录下
ANALYSE=./analyse; #需要将分析的文件拷备到哪里，因为我要转码 怕把原始文件改了
LOG=./lose.log; #日志文件路径

#=====================定义一个函数处理日志====================================
function lose() {
	local filename=`echo $1|cut -d/ -f3`;
	echo "正在分析"$filename"的日志......"
	

	
	local tmpgrep=$TMP/$filename'.1tmp.grep';
	local tmpawk1=$TMP/$filename'.2tmp.awk1';
	local tmpawk2=$TMP/$filename'.3tmp.awk2';
	local tmpcat=$TMP/$filename'.4tmp.cat';
	local result=$DEST/$filename'.result';
	
	#find $1 -name "*.log" |xargs  grep -n "丢失" >$tmpgrep;
	find $1 -name "*.log" |xargs  grep -n "%" >$tmpgrep;

	awk -F: '{print $4,$1,$2}'  $tmpgrep >$tmpawk1;

	awk -F= '{print $4}' $tmpawk1> $tmpawk2
	
	# 因awk文件处理后出现^M的符号 所以这里处理下
	cat $tmpawk2 | tr -d "\r" > $tmpcat

	sort -rn $tmpcat>$result;

}

#lose ./lose/70/ping

#===============================主程序main （程序从这这里开始执行）===========================================
NOW=`date -d today +"%Y-%m-%d %T"`
#cat /dev/null >$LOG;
echo >> $LOG;
echo "start at "$NOW"......" |tee -a $LOG;

if [ -d $ANALYSE ] ; then
	echo "删除"$ANALYSE"目录..." |tee -a $LOG;
	rm -rf $ANALYSE;
fi

echo "删除并重新创建result目录......" |tee -a $LOG;
if [ -d $DEST ] ; then
	rm -rf $DEST;
fi
mkdir -p $DEST/tmp;



echo "复制文件......" |tee -a $LOG
cp -r $SOURCE $ANALYSE;

echo "将文件编码由cp936转成utf-8......" |tee -a $LOG;
for VAR in `find $ANALYSE  -name "*.log"`
do 
	#echo $VAR;
	iconv -c -f cp936 -t utf-8 $VAR>$VAR".conv"
	mv $VAR".conv" $VAR;
done

# 找出日志文件所在目录 依次执行lose函数分析日志
for VAR in `find $ANALYSE -type d|grep "ping$"`
do 
	#echo $VAR;
	lose $VAR;
done


echo "result文本预处理..."|tee -a $LOG;
for VAR in `find $DEST -name "*.result"`
do
	#中文逗号处理 #行首空格处理 #多余空格处理 #提取的行号前面加逗号 /4表示将第4个空格换成, #格式化输出
	sed 's/，/,/' $VAR | sed 's/^ //' |sed 's/\s+/ /g' |sed 's/ /,/4'>$VAR'.pro';
	#因result文件后来不用了，所以没必要格式了
	#sed 's/，/,/' $VAR | sed 's/^ //' |sed 's/\s+/ /g' |sed 's/ /,/4'|awk -F, '{printf "%-16s,%s,%s\n",$1,$2,$3}'>$VAR'.pro';
	mv $VAR'.pro' $VAR;
done

#==========提取时间（根据行号把时间提取出来再拼接成一行）=========================================
echo "提取时间......" |tee -a $LOG;
for VAR in `find $DEST -name "*.result"`
do
	echo "提取时间-正在处理"$VAR"......" |tee -a $LOG;
	# 一行一行读取文件 并处理
	cat $VAR|while read LINE
	 do
		 filename=`echo $LINE|cut -d, -f2`; #取出文件名
		 lineStartNum=`echo $LINE|cut -d, -f3` #取出行号
		 lineEndNum=$[$lineStartNum+3]; # 因为一般丢失率那行最多往下3行就能找到时间所以这里加3
		 echo $filename" $lineStartNum $lineEndNum";
		 #echo $filename" $lineStartNum $lineEndNum" |tee -a $LOG;

		 #sed -n "$lineStartNum,$lineEndNum p" $filename |grep -E '当前时间'> tmp;
		 #sed -n "$lineStartNum,$lineEndNum p" $filename |grep -E '最短' |sed 's/，//g'|sed 's/ //g'>> tmp;
		 #time=`xargs < tmp`; #多行变一行
		 
		 # 取出当前时间那一行 #将多个空格替换成,号
		 time=`sed -n "$lineStartNum,$lineEndNum p" $filename |grep  '当前时间'|sed 's/[ ][ ]*/,/g'`;
		 # 取出包含“最短” 的那行 #处理中文逗号 #处理空格 #最长 平均前面加上空格
		 ms=`sed -n "$lineStartNum,$lineEndNum p" $filename |grep  '最短' |sed 's/，//g'|sed 's/ //g'|sed 's/最长/ 最长/g'|sed 's/平均/ 平均/g'`;

		 loseper=`echo $LINE|cut -d, -f1`; #丢包率
		 fileinfo=`echo $LINE|cut -d, -f2`;#提取的文件名
		 lineinfo=`echo $LINE|cut -d, -f3`; #行号

		 # 将取出的数据拼接成一行 #删除无用字符 #去掉^M #去掉行末逗号
		 echo $loseper,$time,$ms,$fileinfo,$lineinfo |sed 's/--当前时间：//g'|tr -d "\r"|sed 's/,$//g'|awk -F, '{printf "%-16s,%-10s,%s,%-11s,%s,%s\n",$1,$2,$3,$4,$5,$6}'>>$VAR'.time'
		
	done
done

echo "去掉丢包率为100%的行..." |tee -a $LOG;
#把丢包率为100%的行去掉 因为可能是刚开机还没连上网
for VAR in `find $DEST -name "*.result.time"`
do
	grep -v '100%' $VAR >$VAR.no100;	
done

echo "去掉丢包率为0%的行并按天分析......"
for VAR in `find $DEST -name "*.result.time.no100"`
do
	# 去掉丢包率为0的 #按天升序 丢包率降序排列 #格式化输出 因我发现虽然前面的文本都用awk格式化了，但sort后格式都乱了 所以这里再格式化一次
	grep -v '^0' $VAR |sort -t, -k2,2 -k1,1nr|awk -F, '{printf "%-16s,%-10s,%s,%-11s,%s,%s\n",$1,$2,$3,$4,$5,$6}' >$VAR.day
done


# 删除临时文件
echo "删除临时文件......" |tee -a $LOG;
rm -rf  $TMP;
find $DEST -name "*.result" -exec rm {} \;

echo "结果文件存储在"$DEST"......"  |tee -a $LOG;

NOW=`date -d today +"%Y-%m-%d %T"`
echo "end at "$NOW"......" |tee -a $LOG;
