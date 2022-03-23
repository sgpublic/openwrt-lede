#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
set -e
if [ "$1" == "--local" ]; then
  set -v
fi

rm -f feeds.conf
cp feeds.conf.default feeds.conf

# 添加软件源 fw876/helloworld
sed -i "/helloworld/d" feeds.conf.default
echo 'src-git-full helloworld https://github.com/fw876/helloworld.git' >> feeds.conf
# 添加软件源 sundaqiang/openwrt-packages
sed -i "/sundaqiang/d" feeds.conf.default
echo 'src-git-full sundaqiang https://github.com/sgpublic/openwrt-packages-sundaqiang.git' >> feeds.conf

if [ "$1" == "--local" ]; then
  # 本地拉取依赖
  cp -r /mnt/e/Documents/Github/openwrt-lede/sgpublic/* ./
else
  # 拉取 default-settings
  svn co https://github.com/sgpublic/openwrt-lede/trunk/sgpublic/package/default-settings package/default-settings

  # 为 luci-app-ssr-plus 拉取依赖
  svn co https://github.com/sgpublic/openwrt-lede/trunk/sgpublic/tools tools
  svn co https://github.com/sgpublic/openwrt-lede/trunk/sgpublic/package/net package/net
fi

# 拉取主题 luci-theme-argon
rm -rf package/jerrykuku/luci-theme-argon
svn co https://github.com/jerrykuku/luci-theme-argon/trunk package/jerrykuku/luci-theme-argon
# 拉取插件 luci-app-argon-config
rm -rf package/jerrykuku/luci-app-argon-config
svn co https://github.com/jerrykuku/luci-app-argon-config/trunk package/jerrykuku/luci-app-argon-config

# 拉取插件 luci-app-arpbind
rm -rf package/lean/luci-app-arpbind
svn co https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-arpbind package/lean/luci-app-arpbind
sed -i "s/include ..\/..\/luci.mk/include \$(TOPDIR)\/feeds\/luci\/luci.mk/g" package/lean/luci-app-arpbind/Makefile

# 拉取插件 luci-app-filebrowser
rm -rf package/xiaozhuai/luci-app-filebrowser
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-filebrowser package/Lienol/luci-app-filebrowser

# 拉取插件 luci-app-openclash
rm -rf package/vernesong/luci-app-openclash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/vernesong/luci-app-openclash
