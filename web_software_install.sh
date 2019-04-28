#!/bin/bash

java_env(){
    rpm -qa | grep java | xargs rpm -e --nodeps
    yum install -y java-1.8.0-openjdk-devel.x86_64 > /dev/null 2>&1
    tools $?
}

python_env(){
    yum -y install gcc zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel git > /dev/null 2>&1
    curl -L https://github.com/xushuai1898/pyenv-installer/raw/master/bin/pyenv-installer | bash > /dev/null 2>&1
    echo '
export PATH="/root/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
' >> ~/.bashrc
    source ~/.bashrc
    tools $?
}


generateRandom(){
    openssl rand -base64 10 | cut -c 1-10
}

tools(){
    if [[ $1 -eq 0 ]]; then
        fontStyle "green" "操作成功"
    else
        fontStyle "red" "操作失败"
    fi
}

fontStyle(){
    if [[ $1 = "red" ]]; then
         echo -e "
  \033[31m$2\033[0m";
    elif [[ $1 = "green" ]]; then
        echo -e "
  \033[32m$2\033[0m";
    fi
}


clearScreen(){
    if [[ $1 = 'f' ]]; then
        read -n 1 -p "是否清空屏幕输出？[y|n]" option
        if [[ $option = "y" ]]; then
            clear
        else
            clearScreen 'f'
        fi
    else
        sleep 1 && clear
    fi
}

while [[ 1 ]];do
  read -n 2 -p "  1).安装java1.8环境(基于rpm)
  2).安装python环境
  3).安装nodejs环境(TODO)
  4).安装golang环境(TODO)
  5).安装redis(TODO)
  6).安装mysql(TODO)
  7).安装goaccess(TODO)
  8).安装nginx(TODO)
  9).安装supvisor(TODO)
  10).安装常用性能分析工具(htop)(TODO)
  0).退出
  请输入要执行的操作: " step
    if [[ $step -eq 1 ]]; then
        java_env
    elif [[ $step -eq 0 || $step = 'q' ]]; then
        exit 0
    else
        echo "什么也没做";
    fi;
    clearScreen
done;