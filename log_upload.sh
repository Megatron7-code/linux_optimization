#!/bin/bash
PHP_LOG_PATH='/www/server/php/56/var/log/php-fpm.log'
NGINX_LOG_PATH='/www/wwwlogs/xcx.milinzone.com.error.log'
DING_TALK_URL='https://oapi.dingtalk.com/robot/send?access_token=40f602f64fd739b9f2140e628f4a1e3468e9bb803e3ebde7d15d8cc579b7f2d5'


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

test(){
    message=`sed -n '/2019\/10\/25\s18:[0-9][0-9]:[0-9][0-9]\s\[error\]/ p' $NGINX_LOG_PATH`
    echo ${message//\"/-}
    push ${message//\"/-}
}

push(){
    curl '"$DING_TALK_URL"' \
       -H 'Content-Type: application/json' \
       -d '{"msgtype": "text",
            "text": {
                 "content": "'"$*"'"
            }
          }'
}

if [[ $1 == 'test' ]];then
    test
else
    main
fi
