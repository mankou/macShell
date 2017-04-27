#!/bin/bash

# 定义数组
name=(1 2) 
new1="test"

# 给数组追加元素
name=( "${name[@]}" "$new1" ) 

# 输出所有元素
echo ${name[*]} 
echo ${name[@]} 


TARGET="1 2 3"
for currentTarget in ${name[@]}
do
    echo $currentTarget
done

echo $name
