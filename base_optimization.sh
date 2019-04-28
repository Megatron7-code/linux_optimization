#!/bin/bash

createUser(){
    read -p "请输入用户名: " username
    id $username > /dev/null 2>&1
    if [[ $? -eq 0 ]];then
        echo -e "\033[31m用户$username已存在\033[0m";
    else
        pass=$(generateRandom)
        useradd $username && echo $pass|passwd --stdin $username > /dev/null 2>&1
        # 备份
        cp /etc/sudoers{,.back}
        echo "$username ALL=(ALL) NOPASSWD: ALL " >> /etc/sudoers
        echo -e "\033[32m用户创建成功，密码【$pass】\033[0m";
    fi;
}

changeSshPort(){
    read -p "请输入端口号(1000-65535): " port
    echo "Port $port" >> /etc/ssh/sshd_config
    systemctl restart sshd
    if [[ $? -eq 0 ]];then
        fontStyle "green" "ssh端口已切换至$port"
    else
        fontStyle "red" "ssh端口切换失败"
    fi
}

syncSysDate(){
    grep -q 'ntp1.aliyun.com' /var/spool/cron/root
    if [[ $? -ne 0 ]]; then
        echo '/5 /usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1' >> /var/spool/cron/root
        fontStyle "green" "同步成功"
    else
        fontStyle "red" "同步失败或已经同步过"
    fi
}

settingYum(){
    # 创建备份文件存放目录
    mkdir -p /etc/yum.repos.d/{default,back}
    # 备份所有默认的配置文件
    mv /etc/yum.repos.d/repo /etc/yum.repos.d/default
    # 从阿里云获取yum源
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    # 备份yum源
    cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/default
}

closeIptablesAndSelinux(){
    /etc/init.d/iptables stop
    chkconfig iptables off
    sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
}

adjustUlimit(){
    echo '* - nofile 65535' >>/etc/security/limits.conf
}

clearMailGarbage(){
    echo "clearMailGarbage";
}

optimizationNet(){
    cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
#net.nf_conntrack_max = 25000000
#net.netfilter.nf_conntrack_max = 25000000
#net.netfilter.nf_conntrack_tcp_timeout_established = 180
#net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
#net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
#net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
EOF
    sysctl -p
}

adjustCharset(){
    lang_path="/etc/locale.conf"
    echo 'LANG="zn_CN.UTF-8"' > $lang_path
    source $lang_path
}

clockSystemFile(){
    chattr +i /etc/{passwd,shadow,group,gshadow}
    lsattr -a /etc/{passwd,shadow,group,gshadow}
}

banPing(){
    echo "net.ipv4.icmp_echo_ignore_all=1" >> /etc/sysctl.conf
    sysctl -p
}

updateSslSoftware(){
    rpm -qa openssl openssh bash > /dev/null 2>&1
    yum install -y openssl openssh bash > /dev/null 2>&1
    if [[ $? -eq 0 ]];then
        fontStyle "green" "更新成功"
    else
        fontStyle "red" "更新失败"
    fi
}

optimizationSSH(){
    cp /etc/ssh/sshd_config{,.back}
}

generateRandom(){
    openssl rand -base64 10 | cut -c 1-10
}

clearScreen(){
    read -p "是否清空屏幕输出？[y|n]" option
    if [[ $option -eq 'y' ]]; then
        clear
    else
        clearScreen
    fi
}


# \033[32m绿色字\033[0m
fontStyle(){
    if [[ $1 -eq "red" ]]; then
         echo -e "\033[31m$2\033[0m";
    elif [[ $1 -eq "green" ]]; then
        echo -e "\033[32m$2\033[0m";
    fi
}


while [[ 1 ]];do
  read -p "  1).新建sudo用户
  2).变更ssh端口(确认端口是否放开)
  3).自动同步服务器时间
  4).配置yum源
  5).关闭selinux及iptables(TODO)
  6).调整文件描述符的数量(TODO)
  7).定时自动清理邮件目录垃圾文件(TODO)
  8).优化Linux内核参数(TODO)
  9).配置字符集(TODO)
  10).锁定关键性系统文件，防止被篡改(TODO)
  11).禁止系统被ping(TODO)
  12).升级漏洞软件
  13).优化SSH远程连接(TODO)
  0).退出
  请输入要执行的操作: " step
    if [[ $step -eq 1 ]]; then
        createUser
    elif [[ $step -eq 2 ]]; then
        changeSshPort
    elif [[ $step -eq 3 ]]; then
        syncSysDate
    elif [[ $step -eq 4 ]]; then
        settingYum
    elif [[ $step -eq 5 ]]; then
        closeIptablesAndSelinux
    elif [[ $step -eq 6 ]]; then
        adjustUlimit
    elif [[ $step -eq 7 ]]; then
        clearMailGarbage
    elif [[ $step -eq 8 ]]; then
        optimizationNet
    elif [[ $step -eq 9 ]]; then
        adjustCharset
    elif [[ $step -eq 10 ]]; then
        clockSystemFile
    elif [[ $step -eq 11 ]]; then
        banPing
    elif [[ $step -eq 12 ]]; then
        updateSslSoftware
    elif [[ $step -eq 13 ]]; then
        optimizationSSH
    elif [[ $step -eq 0 || $step -eq q ]]; then
        exit 0
    else
        echo "什么也没做";
    fi;
    clearScreen
done;
