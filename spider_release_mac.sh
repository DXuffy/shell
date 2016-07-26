#!/bin/sh

##############################
# 该脚本主要用于spider项目编译发布
# 自动生成版本号
##############################

#### 变量
shareDir="version"

# 待创建的文件后缀
suffix=".txt" 

# svn release目录
svnPath="/Users/chuangker/Documents/inkey/svn/Spider/"
releasePath="${svnPath}release/"
projectPath="${svnPath}projects/H5/"
mountVersionDir="/Volumes/${shareDir}"

#### 方法

# 挂载共享文件夹
mountVersionDisk() {

  m() {
    echo "\033[34m 正在挂载版本磁盘 \033[0m"
    mount -t smbfs //sunweb:LKhjk9\&*1541144@172.16.0.116/test $mountVersionDir
    echo "\033[31m 版本磁盘已挂载 \033[0m"
  }

  if [ ! -d $mountVersionDir ]
  then
    mkdir -p $mountVersionDir
    m
  else
    cd $mountVersionDir
    # 检查磁盘是否挂载
    isH=`ls | wc -l`
    if [ $isH == 0 ]
    then
      rm -rf $mountVersionDir
      m
    fi
  fi

}

# 创建版本文件
createVersionFile() {
  fileName=$1
  project=$2
  version=${fileName%.7z}
  version=${version##*.com}
  arr=(${version//./ })

  arr[3]=`expr ${arr[3]} + 1`

  newFileName=${arr[0]}.${arr[1]}.${arr[2]}.${arr[3]}$suffix

  # 创建文件 注意这里有 / 在目录下建立文件
  touch $releasePath/$newFileName

  echo "\033[34m $releasePath\033[0m\033[31m => $newFileName 已生成 \033[0m"
}

# 获取要编译的项目
getCompileProjects() {

  check() {
    compileProject=$1
    inDir=$2
    # 直接匹配用户输入的路径
    if [ ! $compileProject ] || [ ! -d $compileProject ]
    then
      echo "\033[34m $inDir\033[0m\033[31m => 路径不存在 \033[0m"
      exit
    else
      if [ ! -f $compileProject/fis-conf.js ]
      then
        echo "\033[34m $inDir\033[0m\033[31m => 路径下没有找到fis-conf.js文件 \033[0m"
        exit
      fi
    fi
  }

  echo "\033[31m 您确定要自动上传吗？这将删除掉已经编译好的项目源码！(回车退出) \033[0m"
  echo "\033[31m 请输入项目路径，以fis配置文件所在目录为准(支持多个, 以空格分割): \033[0m"
  read -a compileProjects
  if [ ${#compileProjects[@]} == 0 ]
  then
    exit
  else
    n=0
    for compileProject in ${compileProjects[@]}
    do
      # 不存在再次查找子级路径
      compileProjects[$n]=`find $projectPath -type d | grep $compileProject | sed -n '1,1p'`
      check ${compileProjects[$n]} ${compileProject}
      n=$((n+1))
    done
  fi
}

# 删除SVN
removeRelease() {
  cd $svnPath
  echo "\033[31m 正在更新svn \033[0m"
  svn update
  cd $releasePath
  total=`ls | wc -l`
  if [ $total != 0 ]
  then
    svn update
    svn delete ./* 
    svn commit -m '脚本自动删除release目录下的所有文件'
    echo "\033[31m 初始化已完成\n 准备生成版本文件 \033[0m"
  fi 
}

# 提交文件至SVN
commitFile() {
  echo "\033[31m 准备提交代码至SVN \033[0m"

  cd $releasePath
  svn add * --force
  svn commit -m '脚本自动上传'

  # 打印版本号
  getCurrentVersion

  echo "\033[31m 已提交编译代码至SVN, 先去下面这个地址拉包吧! \033[0m"
  echo "\033[31m http://172.16.0.116:8090/ViewFarmReport.aspx \033[0m"
  echo "\033[31m 接着, 去发邮件吧! 骚年 \033[0m"
}

# 获取最终版本号
getCurrentVersion() {
  v=`find $releasePath -name "*.txt"`
  v=${v##*/}
  v=${v%*.txt}
  echo "\033[31m 版本号 =>\033[0m\033[34m $v \033[0m"
}

# 主方法
main() {

  # 获取要编译的项目
  getCompileProjects

  # 挂载版本
  mountVersionDisk

  # 更新SVN 并将release目录清空提交防止SVN冲突
  removeRelease

  # 创建版本号
  fileName=`ls -t $mountVersionDir/h5.inkey.com/ | sed -n '1,1p'`
  createVersionFile $fileName h5

  # 编译项目
  for compileProject in ${compileProjects[@]}
  do
    cd $compileProject
    fis3 release pro
  done

  # 提交文件至SVN
  commitFile
}

###########################
# 启动方法
# getCompileProjects
# exit
main


