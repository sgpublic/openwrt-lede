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

# 添加软件源 kenzok8/small-package
sed -i "/helloworld/d" feeds.conf.default
echo 'src-git-full helloworld https://github.com/fw876/helloworld.git' >> feeds.conf.default
sed -i "/sundaqiang/d" feeds.conf.default
echo 'src-git-full sundaqiang https://github.com/sundaqiang/openwrt-packages.git' >> feeds.conf.default

if [ "$1" == "--local" ]; then
  set -v
  # 本地拉取依赖
  cp -r /mnt/e/Documents/Github/k2p-lede/sgpublic/* ./
else
  # 拉取 default-settings
  svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/package/default-settings package/default-settings

  # 为 luci-app-ssr-plus 拉取 ucl 和 upx
  svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/tools/ucl tools/ucl
  svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/tools/upx tools/upx
  # 为 luci-app-ssr-plus 拉取依赖
  svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/package/net/dns2socks package/net/dns2socks
  svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/package/net/microsocks package/net/microsocks
  svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/package/net/ipt2socks package/net/ipt2socks
  svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/package/net/pdnsd-alt package/net/pdnsd-alt
  svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/package/net/redsocks2 package/net/redsocks2
fi

# 拉取插件 luci-app-arpbind
svn co https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-arpbind package/lean/luci-app-arpbind
sed -i "s/include ..\/..\/luci.mk/include \$(TOPDIR)\/feeds\/luci\/luci.mk/g" package/lean/luci-app-arpbind/Makefile

# 拉取闭源驱动 mt7615_dhcp
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/mt/drivers/mt7615d package/mt/mt7615d
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/mt/drivers/mt_wifi package/mt/mt_wifi

# 拉取主题 luci-theme-argon
svn co https://github.com/jerrykuku/luci-theme-argon/trunk package/jerrykuku/luci-theme-argon
# 拉取插件 luci-app-argon-config
svn co https://github.com/jerrykuku/luci-app-argon-config/trunk package/jerrykuku/luci-app-argon-config
