# 说明
* 用于快速复制三期、二期、45万工程中的代码 一般用于升级、测试
# 相关命令
## 三期相关命令
* 取svn日志
* 去掉无用：%v/\s\+[MA]/d
* 删除行首的M/A 还有空格 用ctrl+v 删除
* 排序 sort u
* 将svn中无用的路径删除掉(因svn日志中是svn路径你需要把无用的路径去掉)   %s!/release/yh3/web20161108/Components/SCs/yhsq/!!g
* /Users/mang/AppData/百度云同步盘/mac/bat-mac/copyShell/copyShell.sh  -rf /Users/mang/AppData/百度云同步盘/mac/bat-mac/copyShell/config/yhsrc/yh3.config

## 拷备二期-开发源代码
/Users/mang/AppData/百度云同步盘/mac/bat-mac/copyShell/copyShell.sh  -rf /Users/mang/AppData/百度云同步盘/mac/bat-mac/copyShell/config/yhsrc/yh2.config
## 拷备45-开发源代码
/Users/mang/AppData/百度云同步盘/mac/bat-mac/copyShell/copyShell.sh  -rf /Users/mang/AppData/百度云同步盘/mac/bat-mac/copyShell/config/yhsrc/yh45.config
## 配送中心相关命令
* 去掉无用路径：%v/\s\+[MA]/d
* 删除行首的M/A 还有空格 用ctrl+v 删除
* 排序 sort u
* 将svn中无用的路径删除掉(因svn日志中是svn路径 你需要把无用的路径去掉)   %s!/pszx/code/trunk/web/BusComponents/Components/SCs/pszx/!!g
* /Users/mang/AppData/百度云同步盘/mac/bat-mac/copyShell/copyShell.sh  -rf /Users/mang/AppData/百度云同步盘/mac/bat-mac/copyShell/config/yhsrc/pszx.config
