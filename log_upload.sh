#!/bin/bash
PHP_LOG_PATH='/www/server/php/56/var/log/php-fpm.log'
NGINX_LOG_PATH='/www/wwwlogs/xcx.milinzone.com.error.log'


php_log_process(){
    DATE_TIME=`env LANG=en_US.UTF-8 date +"%d-%b-%Y %H"`
    message=`sed -n '/"$DATE_TIME":[0-9][0-9]:[0-9][0-9]\]\s[ERROR|WARNING]/ p' $PHP_LOG_PATH`
    echo $message
}

nginx_log_process(){
    DATE_TIME=`env LANG=en_US.UTF-8 date +"%Y\/%m\/%d\s%H"`
    message=`sed -n '/"$DATE_TIME":[0-9][0-9]:[0-9][0-9]\s\[error\]/ p' $NGINX_LOG_PATH`
    echo $message
}


main(){
    res=`php_log_process`
    if [[ $res != "" ]]; then
        push $res
    fi

    res1=`nginx_log_process`
    if [[ $res1 != "" ]]; then
        push $res1
    fi
}

push(){
    echo $1
}

main
