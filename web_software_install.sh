#!/bin/bash

java_env(){
    # rpm -qa | grep java | xargs rpm -e --nodeps
    yum install -y java-1.8.0-openjdk-devel.x86_64 > /dev/null 2>&1
    toast $?
}

python_env(){
    yum -y install gcc zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel git > /dev/null 2>&1
    cd ~ && curl -L https://github.com/xushuai1898/pyenv-installer/raw/master/bin/pyenv-installer | bash > /dev/null 2>&1
    echo '
export PATH="/root/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
' >> ~/.bashrc
    source ~/.bashrc
    toast $?
}

nodejs_env(){
    cd ~ && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
    source ~/.bashrc
    toast $?
}

golang_env(){
    Environment=/etc/profile
    wget https://dl.google.com/go/go1.12.linux-amd64.tar.gz -O go.tar.gz;
    tar -zxf go.tar.gz -C /home;
    echo "export PATH=$PATH:/home/go/bin" >> $Environment;
    source /etc/profile
    toast $?
}

install_redis(){
    cd ~/src && wget -c http://download.redis.io/releases/redis-4.0.2.tar.gz
    tar xzf redis-4.0.2.tar.gz && cd redis-4.0.2 && yum install -y gcc && make && make install
    mkdir -p /usr/local/redis
    cp src/redis-server /usr/local/redis/
    cp src/redis-cli /usr/local/redis/
    cp redis.conf /usr/local/redis/
    # vim /usr/local/redis/redis.conf    daemon  port  pass
    echo 'daemonize yes' >> /usr/local/redis/redis.conf
    redis-server /usr/local/redis/redis.conf
    toast $?
}

install_goaccess(){
    yum install glib2 glib2-devel GeoIP-devel  ncurses-devel zlib zlib-develyum install gcc -y
    yum -y install GeoIP-update goaccess
    echo "
    nginx.conf
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] requesthost:"\$http_host"; "\$request" requesttime:"\$request_time"; '
            '\$status $body_bytes_sent "\$http_referer" - \$request_body'
            '"\$http_user_agent" "\$http_x_forwarded_for"';

    /etc/goaccess.conf
    time-format %T
    date-format %d/%b/%Y
    log-format %h - %^ [%d:%t %^] requesthost:"%v"; "%r" requesttime:"%T"; %s %b "%R" - %^"%u"

    crontab
    * */1 * * * /usr/bin/goaccess -f /usr/local/nginx/logs/access.log -c -a>/usr/local/nginx/html/go.html
    "
    clearScreen 'f'
}


generateRandom(){
    openssl rand -base64 10 | cut -c 1-10
}

toast(){
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
  2).安装pyenv
  3).安装nvm
  4).安装golang环境
  5).安装redis
  6).安装mysql(TODO)
  7).安装goaccess
  8).安装nginx(TODO)
  9).安装supvisor(TODO)
  10).安装常用性能分析工具(htop)
  0).退出
  请输入要执行的操作: " step
    if [[ $step -eq 1 ]]; then
        java_env
    elif [[ $step -eq 2 ]]; then
        python_env
    elif [[ $step -eq 3 ]]; then
        nodejs_env
    elif [[ $step -eq 4 ]]; then
        golang_env
    elif [[ $step -eq 5 ]]; then
        install_redis
    elif [[ $step -eq 7 ]]; then
        install_goaccess
    elif [[ $step -eq 8 ]]; then
        yum install -y nginx
        toast $?
    elif [[ $step -eq 10 ]]; then
        yum install -y htop > /dev/null 2>&1
        toast $?
    elif [[ $step -eq 0 || $step = 'q' ]]; then
        exit 0
    else
        echo "什么也没做";
    fi;
    clearScreen
done;