#!/bin/bash

#===============================================
# Description: DIY script
# File name: diy-part1-6.x.sh
# License: MIT
# Author: P3TERX
#===============================================

# =================================================================
# 修复系统 kernel 内核 md5 校验码不正确的问题
# =================================================================

echo "00000000000000000000000000000000" > .vermagic
echo "已手动写入虚假内核 md5 校验码，跳过网络校验"

# =================================================================
# 修改版本为编译日期
# =================================================================

date_version=$(date +"%Y%m%d%H")
echo "$date_version" > version

# =================================================================
# iStoreOS 固件版本
# =================================================================

author="Gota666"

sed -i "s/DISTRIB_DESCRIPTION.*/DISTRIB_DESCRIPTION='%D %V ${date_version} by ${author}'/g" \
    package/base-files/files/etc/openwrt_release

sed -i "s/OPENWRT_RELEASE.*/OPENWRT_RELEASE=\"%D %V ${date_version} by ${author}\"/g" \
    package/base-files/files/usr/lib/os-release

#!/bin/bash

# =================================================================
# 添加 mosdns feed
# =================================================================
echo 'src-git mosdns https://github.com/sbwml/luci-app-mosdns' >> feeds.conf.default

# =================================================================
# 添加 Passwall feeds
# =================================================================
echo 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' >> feeds.conf.default
echo 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' >> feeds.conf.default

echo "========================================"
echo "DIY Part 1 完成（仅修改 feeds.conf）"
echo "========================================"
