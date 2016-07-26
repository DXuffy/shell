#!/bin/sh

######################################
# 该脚本主要用于spider项目测试环境编译发布
######################################

# svn release目录
svnPath="/opt/svn/Inkey.Spider/"
releasePath="${svnPath}release/"
projectPath="${svnPath}projects/H5/"

# 获取待编译项目
ask() {
  check() {
    compileProject=$1
    inDir=$2
    # 直接匹配用户输入的路径
    if [ ! $compileProject ] || [ ! -d $compileProject ]
    then
      echo -e "\033[34m $inDir\033[0m\033[31m => 路径不存在 \033[0m"
      exit
    else
      if [ ! -f $compileProject/fis-conf.js ]
      then
        echo -e "\033[34m $inDir\033[0m\033[31m => 路径下没有找到fis-conf.js文件 \033[0m"
        exit
      fi
    fi
  }

  echo -e "\033[31m 请输入项目路径，以fis配置文件所在目录为准(支持多个, 以空格分割): \033[0m"
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

# 更新svn
upsvn() {
  echo -e "\033[34m 正在更新svn \033[0m"
  cd $svnPath
  svn up
  echo -e "\033[34m svn更新完成 \033[0m"
}

# 备份release目录
back() {
  echo -e "\033[34m 正在备份release目录 \033[0m"
  cd $svnPath
  mv release release_back
  echo -e "\033[34m 备份完成 \033[0m"
}

# 还原release目录
reduction() {
  echo -e "\033[34m 正在还原release目录 \033[0m"
  cd $svnPath
  mv release_back release
  echo -e "\033[34m 还原完成 \033[0m"
}

# 删除release目录
remove() {
  echo -e "\033[34m 正在删除release目录 \033[0m"
  cd $svnPath
  rm -rf release
  echo -e "\033[34m 删除完成 \033[0m"
}

# 编译项目
release() {
  for compileProject in ${compileProjects[@]}
  do
    cd $compileProject
    fis3 release pro
  done
}

# 移动项目到对外目录
move() {
  echo -e "\033[34m 正在发布项目 \033[0m"
  cd $releasePath
  cp -R * /data/h5
  echo -e "\033[34m 发布完成 \033[0m"
}

main() {
  ask
  upsvn
  back
  release
  move
  remove
  reduction
}

main