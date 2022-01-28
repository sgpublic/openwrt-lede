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

if [ "$1" == "--local" ]; then
  set -e
  set -v
fi

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# 添加软件源 kenzok8/small-package
sed -i "/small-package/d" feeds.conf.default
echo 'src-git kenzok8 https://github.com/kenzok8/small-package' >> feeds.conf.default

# 拉取插件 luci-app-arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind

# cp -r /mnt/e/Documents/Github/k2p-lede/openwrt/

# 拉取 default-settings
svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/package/default-settings package/sgpublic/default-settings

# 为 luci-app-ssr-plus 添加 tools/ucl 和 tools/upx
svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/tools/ucl tools/ucl
svn co https://github.com/SGPublic/k2p-lede/trunk/sgpublic/tools/upx tools/upx
sed -i '/tools-y += ucl upx/d' tools/Makefile
sed -i '/# subdirectories to descend into/a\tools-y += ucl upx' tools/Makefile
sed -i "/\$(curdir)\/upx\/compile := \$(curdir)\/ucl\/compile/d" tools/Makefile
sed -i '/# builddir dependencies/a\$(curdir)/upx/compile := $(curdir)/ucl/compile' tools/Makefile
