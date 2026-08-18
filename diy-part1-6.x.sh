#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-part1-6.x.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# =================================================================
# 修复系统kernel内核md5校验码不正确的问题
# 在GitHub Actions环境下，网络请求极易超时，直接伪造一个校验码跳过。
# =================================================================
echo "00000000000000000000000000000000" > .vermagic
echo "已手动写入虚假内核md5校验码，跳过网络校验"

# 修改版本为编译日期，数字类型。
date_version=$(date +"%Y%m%d%H")
echo $date_version > version

# 为iStoreOS固件版本加上编译作者
author="Gota666"
sed -i "s/DISTRIB_DESCRIPTION.*/DISTRIB_DESCRIPTION='%D %V ${date_version} by ${author}'/g" package/base-files/files/etc/openwrt_release
sed -i "s/OPENWRT_RELEASE.*/OPENWRT_RELEASE=\"%D %V ${date_version} by ${author}\"/g" package/base-files/files/usr/lib/os-release


# 移除官方 golang 依赖，使用 sbwml 定制的 26.x 版本 (对应 iStoreOS 24.10)
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang

# 删除自带包并克隆最新源码
find ./ -name Makefile | grep -E "v2ray-geodata|mosdns" | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 如果你还需要 passwall 源码（不通过 feeds 添加，直接克隆到 package）
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/passwall_packages
git clone https://github.com/Openwrt-Passwall/openwrt-passwall.git package/passwall_luci
