#!/bin/bash
#****************************************************************#
# ScriptName: Gwm-YiTools.sh
# Author: admin@proyy.com、Sp-Lan's
# Create Date: 2022-11-01 20:00
# Modify Author: admin@proyy.com、Sp-Lan's
# Modify Date: 2022-12-17 22:25
# Version Description Begin
# Version XXX 20XX-XX-XX
# 基于互助原则互助互助
#
#For more updates, visit https://github.com/proyy/Gwm-YiTools-Script/raw/main/note.md
#
# Version 1.3.0
# add 1008611++
#
# Version 1.2.4 2022-12-07
# add Beta list menu
# fix settings 
# fix...
# Version 1.2.3 2022-12-06
# fix...
# Version 1.2.2 2022-12-05
# Version 1.2.1 2022-12-04
# 高德beta仪表测试版状态栏透明沉浸
# Version 1.2 2022-12-03
# 爱趣听2.1fix.高德beta仪表测试版
# Version 1.1 2022-12-02
# 去掉旧版的更新检测
# Version 1.0 2022-12-01
# 在菜单版本的基础上，初步整合成模块并改版了一下，修复了部分BUG 比如adb连接BUG等
# Version Description End 
# Function:Menu...
#***************************************************************#
#begin
#tools
function policy_control_z()
{
package_name=$1
policy_control=`adb shell "settings get global policy_control"|awk -F"=" '{print $2}'`
result=$(echo $policy_control | grep "${package_name}")
if [[ "$result" != "" ]];then
  echo "$package_name已存在policy"
else
  echo "$package_name添加进policy"
  if [[ "$policy_control" == "" ]];then
    echo "获取policy_control为空"
    adb shell "settings put global policy_control immersive.full=$package_name"
  elif [[ "$policy_control" == "*" ]];then
    echo "adb shell \"settings put global policy_control immersive.full=$package_name\""
    adb shell "settings put global policy_control immersive.full=$package_name"
  else
    echo "adb shell \"settings put global policy_control immersive.full=$policy_control,$package_name\""
    adb shell "settings put global policy_control immersive.full=$policy_control,$package_name"
  fi
fi
}
#tips
function byby()
{
    clear
    #echo ""
    echo "开始获取更新内容......"
    wget -T 3 -O note.md https://magisk.proyy.com/tmp/note.md >/dev/null 2>&1 && cat note.md|head -n 11
    echo "玄学问题、佛祖保佑......"
    echo "by https://github.com/proyy/Gwm-YiTools-Script"
    sleep 5
}

function Path_fix()
{
    #Path_fix
    cd ~
    tmpdir=`pwd`
    Work_Path="$tmpdir/A2"
    mkdir $Work_Path 2>/dev/null
    cd $Work_Path
    pwd
}

function Env_fix()
{
    #Env_fix
    clear
    Alpine_Env_Check="/etc/apk/repositories"
    Termux_Env_Check="/etc/apt/sources.list"
    CentOS_Env_Check="/etc/redhat-release"
    echo "当前脚本执行环境检测中....."
    if [  -f "$Alpine_Env_Check"  ];then
        echo "当前为ish shell Alpine环境，安卓也可使用Termux执行本脚本"
        echo "请稍等..."
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
        apk update  >/dev/null 2>&1
        apk add android-tools wget unzip bash curl  >/dev/null 2>&1
    elif [  -f "$PREFIX/$Termux_Env_Check"  ];then
        echo "当前为Termux shell环境,苹果也可使用ish shell执行本脚本"
        echo "请稍等..."
        sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main@' $PREFIX/etc/apt/sources.list
        apt update -y  >/dev/null 2>&1
        apt -o DPkg::Options::="--force-confnew"  upgrade -y  >/dev/null 2>&1
        sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main@' $PREFIX/etc/apt/sources.list
        apt update -y  >/dev/null 2>&1
        pkg install iproute2 android-tools wget -y  >/dev/null 2>&1
    elif [  -f "$CentOS_Env_Check"  ];then
        echo "当前为CentOS shell环境,苹果、安卓也可执行本脚本"
        echo "自动退出有时间加上"
        exit 0
    else
        echo "环境异常，自动退出"
        exit 0
    fi
    echo "Env_fix done!"
    sleep 2
}

function CheckUpdate()
{
    md5a=`curl https://magisk.proyy.com/tmp/md51`
    md5b=`md5sum $tmpdir/$0 |awk '{print $1}'`
    [ "$md5a" == "$md5a" ]&&echo "..."||echo "当前脚本版本需要进行更新、请重新执行！！！$tmpdir/$0:$md5b"
    [ "$md5a" == "$md5a" ]&&echo "done"||exit 0
    sleep 1
}
###Adb
function Adb_Init()
{
	if [  -f "$Alpine_Env_Check"  ]; then
		read -p "请手动输入车机的IP地址确认无误后回车:" carip
	else
		carip=`ip neigh|head -n 1|awk '{print $1}'`
	fi
	if [ ! $carip ]; then
	  echo "请开启手机热点车机连接至热点再重新执行、或者手动输入IP。"
	  read -p "请手动输入车机的IP地址确认无误后回车:" carip
	else
	  echo "获取到车机IP"
	fi
	echo "车机IP为:$carip"
	echo "连接车机中....如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
	export ANDROID_ADB_SERVER_PORT=12888
	echo "尝试连接该IP"
	while true
	do
		str_refused=$(adb connect $carip | grep refused)
		if [[ $str_refused == "" ]]; then
			echo "adb设备连接测试01"
		else
			echo "adb设备连接异常，连接$carip被拒绝，请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
			read -p "请手动输入车机的IP地址确认无误后回车:" carip
		fi
		str_faied=$(adb connect $carip | grep failed)
		if [[ $str_faied == "" ]]; then
			echo "adb设备连接测试02"
			break
		else
			echo "adb设备连接异常，请确认正确ip后手动输入!"
			read -p "请手动输入车机的IP地址确认无误后回车:" carip
		fi
	done
	adb connect $carip
	echo "获取root权限"
	adb root
	echo "等待车机连接,如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
	adb wait-for-device
	echo "挂载system为读写"
	adb remount
	echo "等待车机连接,如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
	adb wait-for-device
	adb connect $carip
	echo "获取root权限"
	adb root
	echo "等待车机连接,如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
	adb wait-for-device
	echo "挂载system为读写"
	adb remount
	echo "等待车机连接,如卡住请确认车机ip正确并车机工程模式其他菜单中已开启TCP/IP"
	adb wait-for-device
	str=$(adb devices | grep "\<device\>")
	if [[ $str != "" ]]; then
		echo "存在adb设备连接"
	else
		echo "adb设备连接异常，一般重新开热点、退甲壳虫、清楚termux数据重来可解决!"
		exit 0
	fi
}

###reboot
function ReBoot()
{
	echo "操作完成, 车机将在10秒后重启, 如果你不希望重启, 请在10秒内关闭此窗口！"
	sleep 10
	echo "开始执行车机重启,恭喜安装完成,退出即可"
	adb shell reboot
	echo "执行车机重启完成！"
}

###Modify
function AutoMap()
{
	cd $Work_Path
	AutoMap_Check_Script_Url="https://magisk.proyy.com/tmp/check.sh"
	AutoMap_Apk="AutoMap.apk"
	AutoMap_Zip="AutoMap.zip"
	AutoMap_Tar="AutoMap.tar"
	Flag=0
	bak=0
    #read -p "请输入数字选择升级全屏版|快捷键|回退(2/1/0):" select_num
    list_url="https://magisk.proyy.com/tmp/automap/stable.csv"
    read -p "请输入数字升级6.6全屏非适配版|快捷键|回退(2/1/0):" select_num
    
    list_data=`curl -ss $list_url|grep "^$select_num,"`
    #echo "$list_data"
    if [[ "$list_data" == "" ]];then
    	echo "输入错误，请截图反馈至管理员，或者确认输入的内容再重试一下"
	exit 0
    else
    	#list菜单
    	read AutoMap_Url md51 tips bak <<< $(echo "$list_data"|awk -F, '{print $2,$3,$4,$5}')
    fi
    if [[ "$AutoMap_Url" == "" ]];then
    	echo "获取数据失败，请截图反馈至管理员，或者保持网络畅通再重试一下"
    	exit 0
    else
    	echo "您选择的是:$select_num:$tips"
    	sleep 3
    fi

	filename=""
	wget -q --show-progress -O check.sh $AutoMap_Check_Script_Url
	if [[ "$bak" == "0" ]]; then
		echo "开始升级预处理"
		cd $Work_Path
		rm -rf tmp
		mkdir tmp
		cd tmp
		wget -q --show-progress -O $AutoMap_Apk $AutoMap_Url
		md5a=`md5sum $AutoMap_Apk |awk '{print $1}'`
		echo "$md5a:$md51"
		if [[ "$md5a" == "$md51" ]];then
			echo "开始解包"
			unzip -o $AutoMap_Apk >/dev/null 2>&1
			echo "解包完成..."
			echo "开始打包必要文件"
			rm -rf automap
			mkdir -p automap/lib
			mv lib/armeabi-v7a automap/lib/arm
			cp $AutoMap_Apk automap/AutoMap.apk
			rm -rf $Work_Path/$AutoMap_Tar
			cd automap/ && tar -cvpf $Work_Path/$AutoMap_Tar *
			find ./ -type f -print0|xargs -0 md5sum >$Work_Path/$AutoMap_Tar.md5
			sed -i 's/.\//\/system\/app\/AutoMap\//' $Work_Path/$AutoMap_Tar.md5
			cd $Work_Path/ && rm -rf $Work_Path/tmp 
			ls -l $AutoMap_Tar*
			echo "预处理完成"
			filename="$AutoMap_Tar"
		else
			echo "下载失败、请保持网络稳定重新执行脚本!!!"
			exit 0
		fi
		
	else
		echo "开始回退预处理"
		cd $Work_Path
		#wget -q --show-progress -O $AutoMap_Zip $AutoMap_Backup_Zip_Url
		wget -q --show-progress -O $AutoMap_Zip $AutoMap_Url
		md5a=`md5sum $AutoMap_Zip |awk '{print $1}'`
		if [[ "$md5a" == "$md51" ]];then
			rm -rf amap_backup.*
			unzip -d $Work_Path $AutoMap_Zip >/dev/null 2>&1
			ls -l amap_backup*
			echo "预处理完成"
			filename="amap_backup.tar"
		else
			echo "下载失败、请保持网络稳定重新执行脚本!!!"
			exit 0
		fi
		
	fi
	Adb_Init
	if [[ "$filename" != "" ]];then
		echo "释放进程...."
		adb shell "killall com.autonavi.amapauto 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:push 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:locationservice 2>/dev/null"
		echo "卸载升级或者清理手动升级残留"
		adb shell "pm uninstall com.autonavi.amapauto >/dev/null"
		adb shell "pm uninstall --user 0 com.autonavi.amapauto >/dev/null"
		echo "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
		echo "删除原车高德地图系统文件"
		adb shell "rm -rf /system/app/AutoMap/*"
		echo "上传替换高德包"
		adb push $filename /data/local/tmp/
		adb push $filename.md5 /data/local/tmp/
		adb push check.sh /data/local/tmp/
		adb shell chmod 777 /data/local/tmp/check.sh
		echo "执行替换操作"
		adb shell "tar -xvpf /data/local/tmp/$filename -C /system/app/AutoMap/"
		echo "校验文件完整性"
		adb shell "/data/local/tmp/check.sh $filename"
		echo "修复文件权限"
		adb shell "chown -R root:root /system/app/AutoMap/"
		adb shell "chmod -R 755 /system/app/AutoMap/"
		adb shell "chmod -R 644 /system/app/AutoMap/AutoMap.apk"
		adb shell "chmod -R 644 /system/app/AutoMap/lib/arm/*"
		if [[ "$bak" == "9" ]]; then
			echo "dex2oat优化处理"
			adb shell "mkdir -p /system/app/AutoMap/oat/arm"
			adb shell "/system/bin/dex2oat --dex-file=/system/app/AutoMap/AutoMap.apk  --oat-file=/system/app/AutoMap/oat/arm/AutoMap.odex"
			adb shell "chmod -R 755 /system/app/AutoMap/oat"
			adb shell "chmod -R 644 /system/app/AutoMap/oat/arm/*"
			adb shell "ls -la /system/app/AutoMap/oat/arm/*"
			echo "dex2oat优化处理end"
		else
			echo "pass"
		fi
		echo "恢复APP状态及还原安装"
		adb shell "pm enable com.autonavi.amapauto"
		adb shell "pm unhide com.autonavi.amapauto"
		adb shell "pm default-state --user 0 com.autonavi.amapauto"
		echo "测试清理步骤"
		adb shell "rm -rf /data/system/package_cache/1/AutoMap*"
		echo "等待10秒后开始还原"
		sleep 10
		echo "尝试还原"
		adb shell "cmd package install-existing com.autonavi.amapauto"
		echo "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
		echo "清理数据"
		adb shell "pm clear com.autonavi.amapauto"
		echo "开始检测当前车机的全屏配置规则"
		adb shell "settings get global policy_control"
		if [[ "$select_num" == "4" ]];then
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			echo "Beta版本自带左侧手势侧滑回桌面!!!"
			sleep 3
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "3" ]];then
			echo "快捷键版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "2" ]];then
			#echo "全屏版本将只设置高德为全屏、会覆盖之前的设置!!!"
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			#adb shell "settings put global policy_control immersive.full=com.autonavi.amapauto"
			policy_control_z "com.autonavi.amapauto"
		elif [[ "$select_num" == "1" ]];then
			echo "快捷键版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "0" ]];then
			echo "原厂版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		else
			echo "???"
		fi
		echo "开始检测当前车机的全屏配置规则"
		adb shell "settings get global policy_control"
		echo "建议配合群文件手势控制软件使用全屏版"
		ReBoot
		
	else
		echo "预处理失败、请截图反馈"
		exit 0
	fi
    #exit 0
    
}

function AutoMapBeta()
{
    clear
	cd $Work_Path
	AutoMap_Check_Script_Url="https://magisk.proyy.com/tmp/check.sh"
	AutoMap_Apk="AutoMap.apk"
	AutoMap_Zip="AutoMap.zip"
	AutoMap_Tar="AutoMap.tar"
	Flag=0
	bak=0
    #read -p "请输入数字选择升级全屏版|快捷键|回退(2/1/0):" select_num
    list_url="https://magisk.proyy.com/tmp/automap/beta.csv"
    echo "Tips:输入命令后下载失败一般是直链获取失败反馈管理修复即可"
    wget -T 3 -O note.md https://magisk.proyy.com/tmp/note.md >/dev/null 2>&1 && cat note.md|head -n 11
    read -p "请根据提示输入数字选择|或者回退(9304/0):" select_num
    
    list_data=`curl -ss $list_url|grep "^$select_num,"`
    #echo "$list_data"
    if [[ "$list_data" == "" ]];then
    	echo "输入错误，请截图反馈至管理员，或者确认输入的内容再重试一下"
	exit 0
    else
    	#list菜单
    	read AutoMap_Url md51 tips bak <<< $(echo "$list_data"|awk -F, '{print $2,$3,$4,$5}')
    fi
    if [[ "$AutoMap_Url" == "" ]];then
    	echo "获取数据失败，请截图反馈至管理员，或者保持网络畅通再重试一下"
    	exit 0
    else
    	echo "您选择的是:$select_num:$tips"
    	sleep 3
    fi

	filename=""
	wget -q --show-progress -O check.sh $AutoMap_Check_Script_Url
	if [[ "$bak" == "0" ]]; then
		echo "开始升级预处理"
		cd $Work_Path
		rm -rf tmp
		mkdir tmp
		cd tmp
		wget -q --show-progress -O $AutoMap_Apk $AutoMap_Url
		md5a=`md5sum $AutoMap_Apk |awk '{print $1}'`
		echo "$md5a:$md51"
		if [[ "$md5a" == "$md51" ]];then
			echo "开始解包"
			unzip -o $AutoMap_Apk >/dev/null 2>&1
			echo "解包完成..."
			echo "开始打包必要文件"
			rm -rf automap
			mkdir -p automap/lib
			mv lib/armeabi-v7a automap/lib/arm
			cp $AutoMap_Apk automap/AutoMap.apk
			rm -rf $Work_Path/$AutoMap_Tar
			cd automap/ && tar -cvpf $Work_Path/$AutoMap_Tar * >/dev/null 2>&1
			find ./ -type f -print0|xargs -0 md5sum >$Work_Path/$AutoMap_Tar.md5
			sed -i 's/.\//\/system\/app\/AutoMap\//' $Work_Path/$AutoMap_Tar.md5
			cd $Work_Path/ && rm -rf $Work_Path/tmp 
			ls -l $AutoMap_Tar*
			echo "预处理完成"
			filename="$AutoMap_Tar"
		else
			echo "下载失败、请保持网络稳定重新执行脚本!!!"
			exit 0
		fi
		
	else
		echo "开始回退预处理"
		cd $Work_Path
		#wget -q --show-progress -O $AutoMap_Zip $AutoMap_Backup_Zip_Url
		wget -q --show-progress -O $AutoMap_Zip $AutoMap_Url
		md5a=`md5sum $AutoMap_Zip |awk '{print $1}'`
		if [[ "$md5a" == "$md51" ]];then
			rm -rf amap_backup.*
			unzip -d $Work_Path $AutoMap_Zip >/dev/null 2>&1
			ls -l amap_backup*
			echo "预处理完成"
			filename="amap_backup.tar"
		else
			echo "下载失败、请保持网络稳定重新执行脚本!!!"
			exit 0
		fi
		
	fi
	Adb_Init
	if [[ "$filename" != "" ]];then
		echo "释放进程...."
		adb shell "killall com.autonavi.amapauto 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:push 2>/dev/null"
		adb shell "killall com.autonavi.amapauto:locationservice 2>/dev/null"
		echo "卸载升级或者清理手动升级残留"
		adb shell "pm uninstall com.autonavi.amapauto >/dev/null"
		adb shell "pm uninstall --user 0 com.autonavi.amapauto >/dev/null"
		echo "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
		echo "删除原车高德地图系统文件"
		adb shell "rm -rf /system/app/AutoMap/*"
		echo "测试清理用户目录"
		adb shell "rm -rf /data/user/0/com.autonavi.amapauto"
		adb shell "rm -rf /data/user_de/0/com.autonavi.amapauto"
		adb shell "rm -rf /data/app/*/com.autonavi.amapauto*"
		adb shell "rm -rf /data/media/0/amapauto9"
		adb shell "rm -rf /sdcard/amapauto9"
		adb shell "rm -rf /sdcard/Android/data/com.autonavi.amapauto"
		echo "上传替换高德包"
		adb push $filename /data/local/tmp/
		adb push $filename.md5 /data/local/tmp/
		adb push check.sh /data/local/tmp/
		adb shell chmod 777 /data/local/tmp/check.sh
		echo "执行替换操作"
		adb shell "tar -xvpf /data/local/tmp/$filename -C /system/app/AutoMap/"
		echo "校验文件完整性"
		adb shell "/data/local/tmp/check.sh $filename"
		echo "修复文件权限"
		adb shell "chown -R root:root /system/app/AutoMap/"
		adb shell "chmod -R 755 /system/app/AutoMap/"
		adb shell "chmod -R 644 /system/app/AutoMap/AutoMap.apk"
		adb shell "chmod -R 644 /system/app/AutoMap/lib/arm/*"
		if [[ "$bak" == "9" ]]; then
			echo "dex2oat优化处理"
			adb shell "mkdir -p /system/app/AutoMap/oat/arm"
			adb shell "/system/bin/dex2oat --dex-file=/system/app/AutoMap/AutoMap.apk  --oat-file=/system/app/AutoMap/oat/arm/AutoMap.odex"
			adb shell "chmod -R 755 /system/app/AutoMap/oat"
			adb shell "chmod -R 644 /system/app/AutoMap/oat/arm/*"
			adb shell "ls -la /system/app/AutoMap/oat/arm/*"
			echo "dex2oat优化处理end"
		else
			echo "pass"
		fi
		echo "恢复APP状态及还原安装"
		adb shell "pm enable com.autonavi.amapauto"
		adb shell "pm unhide com.autonavi.amapauto"
		adb shell "pm default-state --user 0 com.autonavi.amapauto"
		echo "测试清理步骤"
		adb shell "rm -rf /data/system/package_cache/1/AutoMap*"
		echo "等待10秒后开始还原"
		sleep 10
		echo "尝试还原"
		adb shell "cmd package install-existing com.autonavi.amapauto"
		echo "查看Packages list信息"
		adb shell "pm list packages amap"
		adb shell "pm list packages -u amap"
		echo "清理数据"
		adb shell "pm clear com.autonavi.amapauto"
		echo "开始检测当前车机的全屏配置规则"
		adb shell "settings get global policy_control"
		#echo $select_num
		if [[ "$select_num" == "1" ]];then
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			echo "Beta版本自带左侧手势侧滑回桌面!!!"
			sleep 3
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "9302" ]];then
			#echo "全屏版本将只设置高德为全屏、会覆盖之前的设置!!!"
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			#adb shell "settings put global policy_control immersive.full=com.autonavi.amapauto"
			policy_control_z "com.autonavi.amapauto"
		elif [[ $select_num =~ "91" ]];then
			echo "将恢复配置为默认设置、会覆盖之前的设置!!!"
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "2" ]];then
			#echo "全屏版本将只设置高德为全屏、会覆盖之前的设置!!!"
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			#adb shell "settings put global policy_control immersive.full=com.autonavi.amapauto"
			policy_control_z "com.autonavi.amapauto"
		elif [[ "$select_num" == "11" ]];then
			echo "快捷键版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		elif [[ "$select_num" == "0" ]];then
			echo "原厂版本将恢复配置为默认设置、会覆盖之前的设置!!!"
			echo "如使用第三方app全屏或者自定义全屏请在脚本菜单使用全屏选项!!!"
			adb shell "settings put global policy_control null"
		else
			echo "???"
		fi
		echo "开始检测当前车机的全屏配置规则"
		adb shell "settings get global policy_control"
		#echo "建议配合群文件手势控制软件使用全屏版"
		ReBoot
		
	else
		echo "预处理失败、请截图反馈"
		exit 0
	fi
    #exit 0
    
}


function sidemenu()
{
	cd $Work_Path
    echo "Sidemenu虚拟音乐按键直接跳转正在运行的音乐APP！！！！"
    echo "【重要】请确认适配前已准备好车机系统U盘以在适配异常时进行强制升级回退！！"
    echo "【重要】灰度测试中、请做好一切准备、并知晓适配所存在的风险、强烈建议灰度测试后再适配!!!"
	echo "灰度测试发现空间不释放问题暂时无法完成替换适配版文件"
	exit 0
	
	sidemenudir="$Work_Path/sidemenu"
	mkdir $sidemenudir
	cd $sidemenudir
	clear
	echo "本次操作可能导致系统界面异常，请确认已备好U盘及车机系统用于更新意外时进行系统还原！！！(571确认/0取消) "
	echo "本次操作可能导致系统界面异常，请确认已备好U盘及车机系统用于更新意外时进行系统还原！！！(571确认/0取消) "
	echo "本次操作可能导致系统界面异常，请确认已备好U盘及车机系统用于更新意外时进行系统还原！！！(571确认/0取消): "
	read num

	case $num in
		571)
			echo "您选择了确认，并已知且自行接受所有相关风险！！！！"
			echo "如更新后系统正常，后期想回退，下一个子菜单可以进行回退操作！！！！"
			echo "如更新后系统异常，想回退，请通过车机系统U盘进行升级回退！！！！"
			;;
		*)
			echo "您取消了本次操作，灰度测试中，请联系管理员，建议做好所有准备后再执行！！！已做好的车机系统U盘、车机系统"
			exit 0
	esac
	sleep 5
	Adb_Init
	#需要继续完善适配
	bak_apk_url="http://192.3.53.201:5202/d/123/%E5%93%88%E5%BC%97/%E8%BD%A6%E6%9C%BAapk/sidemenu/GwmSystemUI.apk"
	new_apk_url="http://192.3.53.201:5202/d/123/%E5%93%88%E5%BC%97/%E8%BD%A6%E6%9C%BAapk/sidemenu/GwmSystemUI-list.apk"
	bak_tar_url_4013_dg="http://192.3.53.201:5202/d/123/%E5%93%88%E5%BC%97/%E8%BD%A6%E6%9C%BAapk/sidemenu/GwmSystemUI-4013DG.tar"
	bak_tar_url_4025_h6="http://192.3.53.201:5202/d/123/%E5%93%88%E5%BC%97/%E8%BD%A6%E6%9C%BAapk/sidemenu/GwmSystemUI-4025H6.tar"
	bak_tar_name="GwmSystemUI.tar"
	new_apk_url_4013_dg="http://192.3.53.201:5202/d/123/%E5%93%88%E5%BC%97/%E8%BD%A6%E6%9C%BAapk/sidemenu/GwmSystemUI-list-v2-4013DG_sign.apk"
	new_apk_url_4025_h6="http://192.3.53.201:5202/d/123/%E5%93%88%E5%BC%97/%E8%BD%A6%E6%9C%BAapk/sidemenu/GwmSystemUI-list-v2-4025H6_sign.apk"
	new_apk_name="GwmSystemUI-new.apk"

	model=""
	ver=""
	printf "请确认您是大狗车主还是H6车主(9大狗/6H6): "
	read num

	case $num in
		9)
			echo "尊贵的哈弗大狗车主"
			model="哈弗大狗"
			printf "请确认车机系统版本号为4013or4016 (4013/4016): "
			read num
			
			case $num in
				4013)
					echo "您选择的版本是4013"
					ver=4013
					bak_tar_url=$bak_tar_url_4013_dg
					new_apk_url=$new_apk_url_4013_dg
					;;
				4016)
					echo "您选择的版本是4016"
					ver=4016
					bak_tar_url=$bak_tar_url_4013_dg
					new_apk_url=$new_apk_url_4013_dg
					echo "需要加正确的url" && exit 0
					;;
				*)
					echo "错误选项、已自动退出、请重试"
					exit 0
			esac
			;;
		6)
			echo "尊贵的哈弗H6车主"
			model="哈弗H6"
			printf "请确认车机系统版本号为4013or4016or4025 (4013/4016/4025): "
			read num
			
			case $num in
				4013)
					echo "您选择的版本是4013"
					ver=4013
					bak_tar_url=$bak_tar_url_4013_dg
					new_apk_url=$new_apk_url_4013_dg
					echo "需要加正确的url" && exit 0
					;;
				4016)
					echo "您选择的版本是4016"
					ver=4016
					bak_tar_url=$bak_tar_url_4013_dg
					new_apk_url=$new_apk_url_4013_dg
					echo "需要加正确的url" && exit 0
					;;
				4025)
					echo "您选择的版本是4025"
					ver=4025
					bak_tar_url=$bak_tar_url_4025_h6
					new_apk_url=$new_apk_url_4025_h6
					;;
				*)
					echo "错误选项、已自动退出、请重试"
					exit 0
			esac
			;;
		*)
			echo "错误选项、已自动退出、请重试"
			exit 0
	esac

	echo "请再次认真核对一下信息："
	echo "当前选择的车型为：$model"
	echo "当前选择的版本号为：$ver"
	echo "车辆电源开关处于on 上电状态没？"
	echo "车机电量充足?车机连接稳定？手机网络稳定？信号正常？流量够？车机系统U盘准备好了？会用U盘强制升级？"
	echo "确认自行承担适配带来的所有风险？"
	echo " "
	printf "【重要】请最后一次确认以上信息正确并选择适配还是回退(1适配/2回退/0取消): "
	read num

	case $num in
		1)
			echo "选择了适配"
			echo "文件比较大，请保持网络稳定耐心等待一阵。。。"
			rm -rf $sidemenudir/Gwm*.apk
			rm -rf $sidemenudir/Gwm*.tar
			wget -q --show-progress -O $new_apk_name $new_apk_url
			echo "下载完成，请确认大小，如果大小不对或者下载异常，请10S内断开车机连接直接退出"
			du -sh $new_apk_name
			sleep 10
			echo "开始升级"
			echo "开始上传文件至临时目录"
			adb shell "mkdir /data/local/tmp 2>/dev/null"
			adb shell "rm -rf /data/local/tmp/$new_apk_name"
			adb push $new_apk_name /data/local/tmp/
			adb shell "df -h"
			echo "删除原文件"
			adb shell "ls -la /system/priv-app/GwmSystemUI/"
			adb shell "rm -rf /system/priv-app/GwmSystemUI/*"
			adb shell "ls -la /system/priv-app/GwmSystemUI/"
			adb shell "df -h"
			echo "释放进程"
			adb shell "killall com.android.systemui 2>/dev/null"
			adb shell "killall com.android.systemui* 2>/dev/null"
			adb shell "df -h"
			echo "#########这里需要处理空间不足的问题！！！！！！！！！！"
			echo "覆盖系统文件"
			adb shell "cp /data/local/tmp/$new_apk_name /system/priv-app/GwmSystemUI/GwmSystemUI.apk"
			echo "修复文件权限"
			adb shell "chmod -R 644 /system/priv-app/GwmSystemUI/GwmSystemUI.apk"
			echo "系统文件情况"
			adb shell "ls -la /system/priv-app/GwmSystemUI/GwmSystemUI.apk"
			echo "system空间情况、如空间不足将会导致适配失败只能通过车机系统U盘进行刷机还原"
			adb shell "df -h"
			
			;;
		2)
			echo "选择了回退"
			echo "文件比较大，请保持网络稳定耐心等待一阵。。。"
			rm -rf $sidemenudir/Gwm*.apk
			rm -rf $sidemenudir/Gwm*.tar
			wget -q --show-progress -O $bak_tar_name $bak_tar_url
			echo "下载完成，请确认大小，如果大小不对或者下载异常，请10S内断开车机连接直接退出"
			du -sh $bak_tar_name
			sleep 10
			echo "开始升级"
			echo "开始上传文件至临时目录"
			adb shell "mkdir /data/local/tmp 2>/dev/null"
			adb shell "rm -rf /data/local/tmp/$bak_tar_name"
			adb push $bak_tar_name /data/local/tmp/
			adb shell "df -h"
			echo "删除原文件"
			adb shell "ls -la /system/priv-app/GwmSystemUI/"
			adb shell "rm -rf /system/priv-app/GwmSystemUI/*"
			adb shell "ls -la /system/priv-app/GwmSystemUI/"
			adb shell "df -h"
			echo "释放进程"
			adb shell "killall com.android.systemui 2>/dev/null"
			adb shell "killall com.android.systemui* 2>/dev/null"
			echo "#########这里需要处理空间不足的问题！！！！！！！！！！"
			adb shell "df -h"
			echo "覆盖系统文件"
			adb shell "tar -xvpf /data/local/tmp/$bak_tar_name -C /system/priv-app/GwmSystemUI"
			echo "修复文件权限"
			adb shell "chown -R root:root /system/priv-app/GwmSystemUI"
			adb shell "chmod -R 755 /system/priv-app/GwmSystemUI"
			adb shell "chmod -R 644 /system/priv-app/GwmSystemUI/GwmSystemUI.apk"
			adb shell "chmod -R 644 /system/priv-app/GwmSystemUI/lib/arm/*"
			echo "系统文件情况"
			adb shell "ls -la /system/priv-app/GwmSystemUI/"
			echo "system空间情况、如空间不足将会导致适配失败只能通过车机系统U盘进行刷机还原"
			adb shell "df -h"

			;;
		*)
			echo "错误选项、已自动退出、请重试"
			exit 0
	esac
	echo "【重要】如system空间不足将会导致适配失败只能通过车机系统U盘进行刷机还原"
	echo "【重要】如果车机重启后系统异常，那么请使用准备好的车机系统U盘进行系统升级回退操作！！！"
	ReBoot
    
}

function kwkj()
{
    echo "开始回退了，新方案了，回退后用菜单新方案！！！！"
	cd $Work_Path
	kwdir="$Work_Path/kwkj"
	mkdir $kwdir
	cd $kwdir
	Adb_Init
	bak_apk_url="http://192.3.53.201:5202/d/lanzou/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97%E6%9C%80%E6%96%B0%E8%BD%A6%E6%9C%BA%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%89%E6%96%B9apk/%E5%BF%AB%E6%8D%B7%E9%85%B7%E6%88%91/backup/GwmRadio.apk?sign=t0r6r1-WxqbKal7UilLOj8inpNOneWLnDWLQ8oBIvp8=:0"
	new_apk_url=""
	# printf "请选择适配还是回退(1适配/2回退): "
	# read num

	# case $num in
	#     1)
	#         echo "你选择了适配"
	#         md5c="ddb316505f29dbeb4f25023a76ee4eaf"
	#         apk_url=$new_apk_url
	#         ;;
	#     2)
	#         echo "选择了回退"
	#         md5c="68f84300ed0710fd9fe1bbfeb18160d2"
	#         apk_url=$bak_apk_url
	#         ;;
	#     3)
	#         echo "error"
	#         exit 0
	# esac
	echo "选择了回退"
	md5c="68f84300ed0710fd9fe1bbfeb18160d2"
	apk_url=$bak_apk_url
	apk=GwmRadio.apk
	check=0
	echo "开始拉取APP文件..."
	rm -rf $kwdir/GwmRadi*.apk
	wget -q --show-progress -O $apk $bak_apk_url
	md5a=`md5sum $apk |awk '{print $1}'`
	[ "$md5a" == $md5c ]&&echo "校验成功下载完成"||check=1
	[ "$check" == "1" ]&&echo "下载失败请联系管理员!:$md5a"||echo "ok"
	[ "$check" == "1" ]&&exit 0||echo "ok"
	pwd
	#ls
	du -sh $apk
	echo "释放进程"
	adb shell "killall com.gwmv3.radio 2>/dev/null"
	echo "上传系统文件"
	adb push $apk /system/priv-app/GwmRadio/GwmRadio.apk
	echo "校验文件"
	adb shell "ls -l /system/priv-app/GwmRadio/GwmRadio.apk"
	echo "修复文件权限"
	adb shell "chmod -R 644 /system/priv-app/GwmRadio/GwmRadio.apk"
	echo "恢复APP状态及还原安装"
	adb shell "pm enable com.gwmv3.radio"
	adb shell "pm unhide com.gwmv3.radio"
	adb shell "pm default-state --user 0 com.gwmv3.radio"
	#echo "测试清理步骤"
	#adb shell "rm -rf /data/system/package_cache/1/*"
	echo "等待1秒后开始还原"
	sleep 1
	echo "尝试还原"
	adb shell "cmd package install-existing com.gwmv3.radio"
	ReBoot

}


function engineer()
{
    cd $Work_Path
	engdir="$Work_Path/engineer"
	mkdir $engdir
	cd $engdir
	Adb_Init
	echo "开始"
	apk=sotainstaller.apk
	bakfile_check="$apk"
	echo "开始校验本地文件是否完整"
	du -sh $bakfile_check
	check=0
	md5a=`md5sum $apk |awk '{print $1}'`
	[ "$md5a" == "e271fb9a8f3ed46cf1b18becaf6511e4" ]&&echo "校验成功"||check=1
	[ "$check" == "1" ]&&wget -q --show-progress -O $apk "http://192.3.53.201:5202/d/lanzou/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97%E6%9C%80%E6%96%B0%E8%BD%A6%E6%9C%BA%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%89%E6%96%B9apk/enginner/sotainstaller.apk?sign=oJeaUOObve-Cowbn-h-xDX5azYICMP8L11J8mwrHlVY=:0"||echo "ok"

	check=0
	if [  -f "$bakfile_check"  ]; then
		 echo "已存在"
		 du -sh $bakfile_check
	else
		 echo "文件不存在，开始拉..."
		 wget -q --show-progress -O $apk "http://192.3.53.201:5202/d/lanzou/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97%E6%9C%80%E6%96%B0%E8%BD%A6%E6%9C%BA%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%89%E6%96%B9apk/enginner/sotainstaller.apk?sign=oJeaUOObve-Cowbn-h-xDX5azYICMP8L11J8mwrHlVY=:0"
		 md5a=`md5sum $apk |awk '{print $1}'`
		[ "$md5a" == "e271fb9a8f3ed46cf1b18becaf6511e4" ]&&echo "校验成功下载完成"||check=1
		[ "$check" == "1" ]&&echo "下载失败请联系管理员!:$md5a"||echo "ok"

	fi
	check=0
	echo "开始拉取03版本文件..."
	if [  -f "enger.apk"  ]; then
		 echo "已存在"
		 du -sh enger.apk
		 md5a=`md5sum enger.apk |awk '{print $1}'`
		[ "$md5a" == "7f78461d60cb9a5e09fbfab53bc21c64" ]&&echo "校验成功"||check=1
		[ "$check" == "1" ]&&echo "失败请联系管理员!:$md5a"||echo "ok"
		[ "$check" == "1" ]&&echo "重试中......."||echo "ok"
		[ "$check" == "1" ]&&wget -q --show-progress -O enger.apk "http://192.3.53.201:5202/d/lanzou/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97%E6%9C%80%E6%96%B0%E8%BD%A6%E6%9C%BA%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%89%E6%96%B9apk/enginner/enger.apk?sign=2UGZh2_G_Fuwj_TnxtbYNoqudif7SAUd4JcaHbzfns8=:0"||echo "ok"
	else
		 wget -q --show-progress -O enger.apk "http://192.3.53.201:5202/d/lanzou/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97%E6%9C%80%E6%96%B0%E8%BD%A6%E6%9C%BA%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%89%E6%96%B9apk/enginner/enger.apk?sign=2UGZh2_G_Fuwj_TnxtbYNoqudif7SAUd4JcaHbzfns8=:0"
		md5a=`md5sum enger.apk |awk '{print $1}'`
		[ "$md5a" == "7f78461d60cb9a5e09fbfab53bc21c64" ]&&echo "校验成功下载完成"||check=1
		[ "$check" == "1" ]&&echo "下载失败请联系管理员!:$md5a"||echo "ok"
		[ "$check" == "1" ]&&exit 0||echo "ok"
	fi


	printf "请选择转为系统应用还是回退(1安装/2回退): "
	read num

	case $num in
		1)
			echo "你选择了转为系统应用"
			filename="$apk"
			adb shell "mkdir /system/app/sotainstaller && chmod 755 /system/app/sotainstaller"
			echo "上传系统文件"
			adb push $filename /system/app/sotainstaller/sotainstaller.apk
			echo "校验文件完整性"
			adb shell "ls -l /system/app/sotainstaller/sotainstaller.apk"
			echo "修复文件权限"
			adb shell "chmod -R 644 /system/app/sotainstaller/sotainstaller.apk"
			echo "ok????"
			str1=$(adb shell "ls -l /system/app/sotainstaller/sotainstaller.apk"| grep "cannot")
			if [[ $str1 == "" ]]; then
				echo "已确认将工程模式转换为系统应用!!!"
				adb shell "ls -l /system/app/sotainstaller/sotainstaller.apk"
			else
				echo "未能确认请截图给管理员确认!"
				adb shell "ls -l /system/app/sotainstaller/sotainstaller.apk"
			fi
			echo "恢复APP状态及还原安装"
			adb shell "pm enable com.tencent.sotainstaller"
			adb shell "pm unhide com.tencent.sotainstaller"
			adb shell "pm default-state --user 0 com.tencent.sotainstaller"
			echo "01"
			adb shell "cmd package install-existing com.tencent.sotainstaller 2>/dev/null"
			echo "清理"
			adb shell "pm uninstall com.tencent.enger  2>/dev/null && pm uninstall com.gwm.app.bookshelf  2>/dev/null"
			;;
		2)
			echo "你选择了回退"
			filename="enger.apk"
			echo "安装至普通应用"
			adb install -r --user all $filename
			#echo "释放原进程"
			#adb shell "killall com.tencent.sotainstaller 2>/dev/null"
			#adb uninstall
			adb shell "pm default-state --user 0 com.tencent.enger"
			echo "移除1"
			adb shell "pm uninstall --user 0 com.tencent.sotainstaller && rm -rf  /system/app/sotainstaller"
			echo "移除"
			adb shell "rm -rf  /system/app/sotainstaller"
			;;
		*)
			echo "error"
			exit 0
	esac
	echo "如果重启后没有工厂模式，请直接再次安装即可"
	ReBoot
}


function wecarflow()
{
	cd $Work_Path
	aqdir="$Work_Path/wecarflow"
	mkdir $aqdir
	cd $aqdir
	Adb_Init
	echo "开始备份"
	bakfile_check="$aqdir/wecarflow_backup.tar"
	echo "开始校验本地备份是否完整"
	du -sh $bakfile_check
	check=0
	bak_tar_size="67M"
	md5a=`md5sum $bakfile_check |awk '{print $1}'`
	md54="ab09d0bc78ff984c978433f68adbc3ff"
	[ "$md5a" == $md54 ]&&echo "校验本地成功"||check=1
	[ "$check" == "1" ]&&echo "本地备份校验失败将执行清理操作!!!"||echo "ok"
	[ "$check" == "1" ]&&rm -rf $bakfile_check ||echo "ok"
	[ "$check" == "1" ]&&rm -rf $bakfile_check.md5 ||echo "ok"
	if [  -f "$bakfile_check"  ]; then
		 echo "原车爱趣听备份已存在"
		 echo "请确认备份文件大小是否正常,$bak_tar_size左右"
		 du -sh $bakfile_check
		 echo "md5sum:$md5a = $md54"
	else
		 echo "备份文件不存在，开始备份..."
		 adb shell "rm -rf /data/local/tmp/wecarflow_backup*"
		 adb shell "cd /system/app/wecarflow/ && tar -cvpf /data/local/tmp/wecarflow_backup.tar *"
		 adb shell "find /system/app/wecarflow/ -type f -print0|xargs -0 md5sum >/data/local/tmp/wecarflow_backup.tar.md5"
		 adb shell chmod 777 /data/local/tmp/wecarflow_backup.tar /data/local/tmp/wecarflow_backup.tar.md5
		 echo "备份完成,执行传输至本地"
		 adb pull /data/local/tmp/wecarflow_backup.tar $aqdir/
		 adb pull /data/local/tmp/wecarflow_backup.tar.md5 $aqdir/
		 echo "备份传输至手机完成"
		 pwd
		 ls $aqdir/
		 echo "开始校验本地备份是否完整"
		 du -sh $bakfile_check
		 check=0
		 md5a=`md5sum $bakfile_check |awk '{print $1}'`
		 md54="ab09d0bc78ff984c978433f68adbc3ff"
		 [ "$md5a" == $md54 ]&&echo "校验成功"||check=1
		 [ "$check" == "1" ]&&echo "本地备份校验失败将执行清理操作并拉取网络备份!!!"||echo "ok"
		 [ "$check" == "1" ]&&rm -rf $bakfile_check ||echo "ok"
		 [ "$check" == "1" ]&&rm -rf $bakfile_check.md5 ||echo "ok"
		 [ "$check" == "1" ]&&wget -q --show-progress -O wecarflow_backup.zip "http://192.3.53.201:5202/d/lanzou/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97%E6%9C%80%E6%96%B0%E8%BD%A6%E6%9C%BA%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%89%E6%96%B9apk/%E7%88%B1%E8%B6%A3%E5%90%AC%E5%A4%87%E4%BB%BD/wecarflow_backup.zip?sign=ArXIsaEAVMAd_ztB87eBiqnXJ_SY9okflMDscQeEAjM=:0" ||echo "ok"
		 [ "$check" == "1" ]&&unzip -d $aqdir wecarflow_backup.zip ||echo "ok"
		 echo "请确认备份文件大小是否正常,$bak_tar_size左右"
		 du -sh $bakfile_check
		 echo "md5sum:$md5a = $md54"
	fi


	printf "请选择升级至2.6还是回退(1安装/2回退): "
	read num

	case $num in
		1)
			echo "你选择了升级爱趣听至2.6版本"
			wget -q --show-progress -O wecarflow.tar  "http://192.3.53.201:5202/d/lanzou/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97/%E5%93%88%E5%BC%97%E5%A4%A7%E7%8B%97%E6%9C%80%E6%96%B0%E8%BD%A6%E6%9C%BA%E5%AE%89%E8%A3%85%E7%AC%AC%E4%B8%89%E6%96%B9apk/%E7%88%B1%E8%B6%A3%E5%90%AC%E5%A4%87%E4%BB%BD/%E7%88%B1%E8%B6%A3%E5%90%AC2.6.tar?sign=QpKZErqeT_q-Yo9HpP81DKWF-zKp_3ycTL2MDZxDbQk=:0"
			filename="wecarflow.tar"
			echo "5830d10b16622ce21a6c4cf7ade23225"
			md5a=`md5sum $filename |awk '{print $1}'`
			echo "$md5a"
			du -sh wecarflow.tar
			;;
		2)
			echo "你选择了回退到爱趣听原厂版本"
			filename="wecarflow_backup.tar"
			;;
		*)
			echo "error"
			exit 0
	esac

	echo "删除原车爱趣听记录"
	adb shell "rm -rf /system/app/wecarflow/*"
	echo "释放system分区空间"
	adb shell "killall com.tencent.wecarflow 2>/dev/null"
	adb shell "killall com.tencent.wecarflow:coreService 2>dev/null"
	echo "上传爱趣听系统文件"
	adb push $filename /data/local/tmp/
	#adb push $filename.md5 /data/local/tmp/
	echo "执行替换操作"
	adb shell "tar -xvpf /data/local/tmp/$filename -C /system/app/wecarflow"
	echo "校验文件完整性"
	adb shell "ls -l /system/app/wecarflow/wecarflow.apk"
	echo "修复文件权限"
	adb shell "chown -R root:root /system/app/wecarflow/"
	adb shell "chmod -R 755 /system/app/wecarflow/"
	adb shell "chmod -R 644 /system/app/wecarflow/wecarflow.apk"
	adb shell "chmod -R 644 /system/app/wecarflow/oat/arm/*"
	echo "恢复APP状态及还原安装"
	adb shell "pm enable com.tencent.wecarflow"
	adb shell "pm unhide com.tencent.wecarflow"
	adb shell "pm default-state --user 0 com.tencent.wecarflow"
	#echo "测试清理步骤"
	#adb shell "rm -rf /data/system/package_cache/1/*"
	echo "等待1秒后开始还原"
	sleep 1
	echo "尝试还原"
	adb shell "cmd package install-existing com.tencent.wecarflow"
	ReBoot
}



function installapk()
{
	cd $Work_Path
	insdir="$Work_Path/installapk"
	mkdir $insdir
	cd $insdir
	read -p "请手动输入apk的URL地址确认无误后回车:" apk_url
	echo "获取到手动APK url:$apk_url"
	Adb_Init
	echo "开始"
	apk=tmp.apk
	wget --spider -q -o /dev/null  --tries=1 -T 5 $apk_url
	if [ $? -eq 0 ];then
		echo "有效URl"
	else
		echo "$apk_url为无效URL!!!!!!!!!!!!!!!!!!!"
		read -p "请手动输入apk的URL地址确认无误后回车:" apk_url
		echo "获取到手动APK url:$apk_url"
		
	fi
	wget -q --show-progress -O $apk "$apk_url"
	if [  -f "$apk"  ]; then
		 echo "APK存在"
		 du -sh $bakfile_check
	else
		 echo "APK文件不存在！！！"
		 exit 0
	fi
	echo "开始安装...请耐心等待，如长时间卡住，请截图反馈！"
	adb install -r $apk
}

function quanping()
{
    cd $Work_Path
	Adb_Init
	sleep 3
	clear
	echo "开始检测当前车机的全屏配置规则"
	adb shell "settings get global policy_control"
	echo "1、设置所有第三方APP全屏"
	echo "2、恢复系统默认设置"
	echo "3、可自定义全屏包名"
	echo "4、在现有的基础上配置高德为全屏(修复侧边栏重叠问题)"
	echo ""
	read -p "请输入数字选择:" num

	case $num in
		1)
			echo "设置所有第三方APP全屏"
			adb shell settings put global policy_control immersive.navigation=apps,-com.tencent.wecarflow,-com.android.cts.priv.ctsshim,-com.aptiv.thememanager,-com.tencent.tai.pal.platform.app,-com.edog.car,-com.gwm.app.bookshelf,-com.gwm.app.smartmanual,-com.gwmv3.vehicle,-com.aptiv.mediator,-com.gwm.app.onlinevideo,-com.redbend.client,-com.iflytek.cutefly.speechclient.hmi,-com.android.certinstaller,-com.aptiv.dlna,-com.gwmv3.launcher,-com.gwm.app.weather,-com.aptiv.camera,-com.gwmv3.media,-com.android.se,-com.gwmv3.photo,-com.gwmv3.radio,-com.gwmv3.dlna,-com.gwm.app.themestore,-com.hanvon.inputmethod.callaime,-com.gwmv3.setting,-com.gwm.app.iotapp,-com.ss.android.ugc.aweme,-com.android.packageinstaller,-com.gwmv3.dvr,-com.aptiv.thirdmediaparty,-com.gwmv3.personalcenter,-com.aptiv.car,-net.easyconn,-com.gwmv3.engineermode,-com.gwm.app.appstore,-com.aptiv.carplay,-com.android.systemui,-com.aptiv.media,-com.aptiv.radio,-com.aptiv.multidisplay,-com.gwm.app.etcp,-com.gwmv3.theme0201,-com.gwmv3.theme0301,-com.gwmv3.theme0302,-com.gwmv3.theme0401,-com.tencent.sotainstaller,-com.tencent.enger
			;;
		2)
			echo "恢复系统默认设置"
			adb shell settings put global policy_control null
			;;
		3)
			echo "可自定义全屏包名，多个app请用,号隔开,例如输入 com.autonavi.amapauto,cn.kuwo.kwmusiccar"
			read -p "请输入自定义全屏包名确认无误后回车:" pkg_name
			adb shell settings put global policy_control immersive.navigation=$pkg_name
			;;
		4)
			echo "开始设置"
			policy_control_z "com.autonavi.amapauto"
			;;
		*)
			echo "error"
	esac
	echo "开始检测当前车机的全屏配置规则"
	adb shell "settings get global policy_control"
	echo "操作完成！"
}

function rootinstallenger()
{
    echo "安卓已Root手机的安装工程模式..有空弄一下"
	#判断是否su
	#判断完整root还是magisk
	#判断系统分区是否可读写
	#如果是可写hosts，覆写hosts记录
	#如果magisk install hosts module
	#修改模块host链接文件 重启手机
	#验证hosts是否生效等等
    sleep 5
    # exit 0
}

function LogSubmit()
{
    echo "将自动抓取30S的log至手机download目录"
    echo "请务必提前执行：termux-setup-storage,否则没有权限访问存储空间!!!"
    sleep 2
    current=`date "+%Y-%m-%d %H:%M:%S"`
    timeStamp=`date -d "$current" +%s`
    currentTimeStamp=$((timeStamp*1000+10#`date "+%N"`/1000000))
    Log_file="AAAA_test_log_$currentTimeStamp.log"
    Log_Path="/sdcard/Download"
    echo "当前脚本执行环境检测中....."
    flag=`echo "check log Permission ???">$Log_Path/$Log_file|grep Permission`
    if [[ $flag=="" ]];then
        echo "权限检测通过"
        echo "pass!!!"
    else
    	echo "请务必提前执行：termux-setup-storage,否则没有权限访问存储空间!!!"
	sleep 5
	exit 0
    fi
    echo "开始...."
    echo "请提前连接好车机,建议复现bug后再执行!!!"
    sleep 3
    Adb_Init
    echo "log默认将抓取20秒，请耐心等待!!!"
    adb shell "logcat">$Log_Path/$Log_file & sleep 20;adb shell "killall logcat"
    echo "log抓取结束,保存目录为：$Log_Path/$Log_file,如果没有自动上传成功请手动用微信反馈至群内..."
    echo "开始自动上传"
    ftp -n<<eof
    open magisk.proyy.com
    user log_tmp_20221206 kfbRBSZLM4sGmF6z
    binary
    passive
    cd /log/
    lcd $Log_Path
    prompt
    put $Log_file $Log_file
    close
    bye
eof
    echo "end......"
    sleep 5
    exit 0
}



function menu()
{
    cat <<eof
    
***********************************************
*                      YiTools                *

*  9.升级高德带三指全屏整合菜单版|还原-灰度测试*

*  1.升级替换高德全屏界面高德官版无三指等可还原*

*  2.左侧虚拟音乐按键直接跳转三方音乐-灰度测试*

*  3.工厂模式转为系统应用或还原               *

*  4.爱趣听升级至2.6版本或者还原              *

*  5.安装远程URL软件(apk)                     *

*  6.配置软件是否为全屏                       *

*  7.安卓已Root手机的安装工程模式             *

*  8.收音机无法打开等回退专用                 *

*  0.退出                                     *

***********************************************
 Tips:工程模式开tcp/ip且车机连手机热点
**********************************************
eof

}
function usage()
{
    read -p "请看清对应操作输入数字选项后回车: " choice
    case $choice in
        1)
            AutoMap
            ;;
        2)
            sidemenu
            ;;
        3)
            engineer
            ;;
        4)
            wecarflow
            ;;
        5)
            installapk
            ;;
        6)
            quanping
            ;;
        7)
            rootinstallenger
            ;;
        8)
            kwkj
            ;;
        9)
            AutoMapBeta
            ;;
        9001)
            LogSubmit
            ;;
        0)
            exit 0
            ;;
		*)
            clear
            ;;

    esac
}
function  main()
{
    while true
    do
        #clear 
        menu
        usage
    done
}

Path_fix
Env_fix
#CheckUpdate
byby
clear
main
