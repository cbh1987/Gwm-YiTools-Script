#!/bin/sh

extract(){
list=$1
echo "校验中发现错误!"
echo "正在修复.."
tar_file="/data/local/tmp/$Amap_file"
echo $tar_file
cd /system/app/AutoMap/
echo "尝试通过lsof清理文件占用进程..."
lsof +D /system/app/AutoMap/lib/arm/ |awk 'NR>1' |grep -v 'bash\|sh\|check.sh\|tar' |awk '{print $2}'| xargs kill -9
for filepath in $list
do
  filename=`echo $filepath|sed 's/\/system\/app\/AutoMap\///g'`
  tar -xvpf $tar_file $filename
done
fix_faillist=`md5sum -c "$Amap_file.md5" 2>&1|grep FAILED |awk -F: '{print $1}'`
[ ! "$fix_faillist" ]&&echo "修复成功未发现错误"||echo "修复失败,建议重启后尝试,或截图至管理员"
}
cd /data/local/tmp/
Amap_file=$1
faillist=`md5sum -c "$Amap_file.md5" 2>&1|grep FAILED |awk -F: '{print $1}'`
[ ! "$faillist" ]&&echo "校验成功未发现错误"||extract "$faillist"