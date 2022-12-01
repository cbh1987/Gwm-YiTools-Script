# Gwm-YiTools-Script
Gwm车友互助的Script
#
#一个简单的脚本，来自于互助车友一起构建
#
#
#【必看】安卓IOS一键处理脚本整合按需选择执行
#
#请务必看完!!
#
#【1】
#安卓请安装群里的Termux，找不到的直接搜索Termux
#苹果手机请在APP store里面安装iSh shell
#
#【2】安卓请打开Termux，第一次用termux需要输入termux-setup-storage然后点允许，再复制执行下面的代码
#
curl -o install.sh https://ghproxy.com/https://github.com/proyy/Gwm-YiTools-Script/raw/main/Gwm-YiTools.sh ; bash install.sh
#
#【3】苹果手机请打开ish shell，执行下面的代码，如果有提示允许请点允许
#1.
#
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ; apk update ; apk add curl bash
#
#2.
#
curl -o install.sh https://ghproxy.com/https://github.com/proyy/Gwm-YiTools-Script/raw/main/Gwm-YiTools.sh ; bash install.sh
#
