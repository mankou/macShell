#!/bin/bash
# 工程初始化
# 在实际项目开发时都有自己的工程名、包名,该脚本帮助你快速将该demo工程修改成你想要的名称
# 运行方式
# chmod +s *.sh
# ./initProject.sh

author=man003@163.com
version=V1.0-20170526

# 脚本当前路径
SHELL_PATH=$(cd $(dirname "$0");pwd)
SHELL_NAME=`basename $0`
PARENT_PATH=`dirname $SHELL_PATH`;
cd $PARENT_PATH

###############定义原工程相关变量###################

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

# 获取包名根路径 如包名为 mang.demo.springmvc 则这里获取为mang
# 使用 sed #\..*##g  第一个\.表示转义. .*表示仍然字符 也即把 .开始的字符全部替换为空
# 目的 以后迁移java文件后需要把该目录删除 
packageRootPrefix=`echo $package_old|sed "s#\..*##g"`
javaRootPath_develop=${java_path_prefix_develop}/$packageRootPrefix
javaRootPath_test=${java_path_prefix_test}/$packageRootPrefix

# 通过包名获取java文件实际路径
# 如包名为 mang.demo.springmvc 则其java路径在 src/main/java/mang/demo/springmvc
packageFilePathOld=`echo "$package_old" | sed 's#\.#/#g'`
javaPathOld_develop=${java_path_prefix_develop}/$packageFilePathOld
javaPathOld_test=${java_path_prefix_test}/$packageFilePathOld

# 需要处理的工程
projects="common server web"

# 定义新工程相关变量默认值
# 注这些变量可通过 init.config 文件覆盖默认值

# 新工程的名称
project_name_new=mtest

# 新工程 maven中的groupID 用于替换pom.xml
group_id_new=com.mtest

# 新工程包名 
package_new=com.mtest


# 处理开发代码java路径
# 将java文件移动到新路径并删除原路径
processJavaPath_develop() {
    local project=$1
    local javaPathFrom=${PARENT_PATH}/${project_name_new}-$project/${javaPathOld_develop}
    local javaPathTo=${PARENT_PATH}/${project_name_new}-$project/${javaPathNew_develop}

    if [ -d $javaPathFrom ]
    then
        if [ ! -d ${javaPathTo}  ]
        then
            mkdir -p ${javaPathTo}
        fi
        mv $javaPathFrom/* $javaPathTo

        local javaPathFromRoot=${PARENT_PATH}/${project_name_new}-$project/$javaRootPath_develop
        if [ -d ${javaPathFromRoot} ]
        then
            rm -rf $javaPathFromRoot
        fi
    fi
}

# 处理测试代码java路径
# 将java文件移动到新路径并删除原路径
processJavaPath_test() {
    local project=$1
    local javaPathFrom=${PARENT_PATH}/${project_name_new}-$project/${javaPathOld_test}
    local javaPathTo=${PARENT_PATH}/${project_name_new}-$project/${javaPathNew_test}

    if [ -d $javaPathFrom ]
    then
        if [ ! -d ${javaPathTo}  ]
        then
            mkdir -p ${javaPathTo}
        fi
        mv $javaPathFrom/* $javaPathTo

        local javaPathFromRoot=${PARENT_PATH}/${project_name_new}-$project/$javaRootPath_test
        if [ -d ${javaPathFromRoot} ]
        then
            rm -rf $javaPathFromRoot
        fi
    fi
}

###  ------------------------------- ###
###  Main script                     ###
###  ------------------------------- ###

# 获取配置文件覆盖变量默认值
initConfig=${SHELL_PATH}/initProject.config
if [ -f $initConfig ]
then
    echo 采用init.config覆盖默认配置
    . $initConfig

    # 通过新工程的包名取出java文件路径
    # 如下将 .变成/  如 com.mtest 将变成 com/mtest
    packageFilePathNew=`echo "$package_new" | sed 's#\.#/#g'`
    javaPathNew_develop=${java_path_prefix_develop}/${packageFilePathNew}
    javaPathNew_test=${java_path_prefix_test}/${packageFilePathNew}
fi

echo 新工程名  $project_name_new 
echo 新groupID $group_id_new
echo 新包名    $package_new
echo

echo 正在处理 .git目录
gitPath=$PARENT_PATH/.git
if [ -d ${gitPath} ]
then
    rm -rf $gitPath
fi

echo 正在处理 .svn目录
svnPath=$PARENT_PATH/.svn
if [ -d ${svnPath} ]
then
    rm -rf $svnPath
fi

echo 正在处理 工程目录名
for proj in $projects
do
    mv $PARENT_PATH/${project_name_old}-${proj} $PARENT_PATH/${project_name_new}-${proj}
    #mv $PARENT_PATH/springmvc-demo-server $PARENT_PATH/$project_name_new-server
done

echo 正在处理 java文件存储路径
for proj in $projects
do
    #echo 正在处理develop $proj
    processJavaPath_develop $proj

    #echo 正在处理test $proj
    processJavaPath_test $proj
done

echo 正在处理 java文件包路径
find . -name "*.java" |xargs sed -ig "s/$package_old/$package_new/g"
find . -name "*.javag" |xargs -n5 rm -rf

echo 正在处理 controller中的链接注释
find . -name "*Controller.java" |xargs sed -ig "s/$project_name_old/$project_name_new/g"
find . -name "*Controller.javag" |xargs -n5 rm -rf

echo 正在处理 .project
find . -name "*.project" |xargs sed -ig "s/$project_name_old/$project_name_new/g"
find . -name "*.projectg" |xargs -n5 rm -rf

echo 正在处理 pom.xml
find . -name "pom.xml" |xargs sed -ig "s/$project_name_old/$project_name_new/g"
find . -name "pom.xml" |xargs sed -ig "s/$group_id_old/$group_id_old/g"
find . -name "pom.xmlg" |xargs -n5 rm -rf

echo 正在处理 xml文件
find . -name "applicationContext-local.xml" |xargs sed -ig "s/$package_old/$package_new/g"
find . -name "mvc-dispatcher-servlet.xml" |xargs sed -ig "s/$package_old/$package_new/g"
find . -name "*applicationContext-local.xmlg" |xargs  -n5 rm -rf
find . -name "*mvc-dispatcher-servlet.xmlg" |xargs  -n5 rm -rf

# org.eclipse.wst.common.component
echo 正在处理 org.eclipse.wst.common.component
find . -name "org.eclipse.wst.common.component" |xargs sed -ig "s/$project_name_old/$project_name_new/g"
find . -name "org.eclipse.wst.common.componentg" |xargs -n5 rm -rf

echo
echo done.


