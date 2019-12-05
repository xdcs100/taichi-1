#!/system/bin/sh

MODDIR=${0%/*}

rm /data/misc/taichi

if [[ $(getprop ro.build.version.sdk) -ge 29 ]]; then
    AB_UPDATE=$(getprop ro.build.ab_update)
    SAR=$(getprop ro.build.system_root_image)
    if [[ ${AB_UPDATE} != "true" ]] || ([[ ${AB_UPDATE} == "true" ]] && [[ ${SAR} == "false" ]]); then
        setenforce 0
        exit 0
    fi
fi

magiskpolicy --live "allow system_server system_server process { execmem }"\
    "allow system_server apk_data_file file *"\
    "allow system_server app_data_file file *"\
    "allow system_server dalvikcache_data_file file { execute }"\
    "allow system_server system_file file { execute_no_trans }"
