#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# 修复系统kernel内核md5校验码不正确的问题
# https://downloads.openwrt.org/releases/24.10.5/targets/rockchip/armv8/kmods/
# https://archive.openwrt.org/releases/24.10.5/targets/rockchip/armv8/kmods/
# https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.5/targets/rockchip/armv8/kmods/
# https://mirrors.cqupt.edu.cn/openwrt/releases/24.10.5/targets/rockchip/armv8/kmods/
# https://mirrors.ustc.edu.cn/openwrt/releases/24.10.5/targets/rockchip/armv8/kmods/

hash_value=""
Releases_version=$(cat include/version.mk | sed -n 's|.*releases/\([^)]*\)).*|\1|p')

if [ -z "$Releases_version" ]; then
    Releases_version=$(cat package/base-files/image-config.in | sed -n 's|.*releases/\([^"]*\)".*|\1|p')
fi

http_value=$(wget -qO- "https://downloads.openwrt.org/releases/${Releases_version}/targets/rockchip/v8/kmods/")
hash_value=$(echo "$http_value" | sed -n 's/^.*-\([0-9a-f]\{32\}\)\/.*/\1/p' | head -1)

if [ -z "$hash_value" ]; then
    http_value=$(wget -qO- "https://archive.openwrt.org/releases/${Releases_version}/targets/rockchip/v8/kmods/")
    hash_value=$(echo "$http_value" | sed -n 's/^.*-\([0-9a-f]\{32\}\)\/.*/\1/p' | head -1)
fi

if [ -z "$hash_value" ]; then
    http_value=$(wget -qO- "https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${Releases_version}/targets/rockchip/v8/kmods/")
    hash_value=$(echo "$http_value" | sed -n 's/^.*-\([0-9a-f]\{32\}\)\/.*/\1/p' | head -1)
fi

if [ -z "$hash_value" ]; then
    http_value=$(wget -qO- "https://mirrors.cqupt.edu.cn/openwrt/releases/${Releases_version}/targets/rockchip/v8/kmods/")
    hash_value=$(echo "$http_value" | sed -n 's/^.*-\([0-9a-f]\{32\}\)\/.*/\1/p' | head -1)
fi

if [ -z "$hash_value" ]; then
    http_value=$(wget -qO- "https://mirrors.ustc.edu.cn/openwrt/releases/${Releases_version}/targets/rockchip/v8/kmods/")
    hash_value=$(echo "$http_value" | sed -n 's/^.*-\([0-9a-f]\{32\}\)\/.*/\1/p' | head -1)
fi

hash_value=${hash_value:-$(echo "$http_value" | sed -n 's/.*\([0-9a-f]\{32\}\)\/.*/\1/p' | head -1)}
if [ -n "$hash_value" ] && [[ "$hash_value" =~ ^[0-9a-f]{32}$ ]]; then
    echo "$hash_value" > .vermagic
    echo "kernel内核md5校验码：$hash_value"
else
    echo "警告：请求所有链接均未获取到有效校验码，请修复！"
    exit 1
fi

# 修改版本为编译日期，数字类型。
date_version=$(date +"%Y%m%d%H")
echo $date_version > version

# 为iStoreOS固件版本加上编译作者
author="Gota666"
sed -i "s/DISTRIB_DESCRIPTION.*/DISTRIB_DESCRIPTION='%D %V ${date_version} by ${author}'/g" package/base-files/files/etc/openwrt_release
sed -i "s/OPENWRT_RELEASE.*/OPENWRT_RELEASE=\"%D %V ${date_version} by ${author}\"/g" package/base-files/files/usr/lib/os-release

# 添加 mosdns 的软件源
echo 'src-git mosdns https://github.com/sbwml/luci-app-mosdns' >> feeds.conf.default

# 添加 passwall 的软件源 (包含其依赖库和界面)
echo 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' >> feeds.conf.default
echo 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' >> feeds.conf.default

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
