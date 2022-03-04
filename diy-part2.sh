#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

set -e
if [ "$1" == "--local" ]; then
  set -v
fi

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate
# 修改主机名
sed -i 's/OpenWrt/K2P/g' package/base-files/files/bin/config_generate
# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 添加 tools/ucl 和 tools/upx
sed -i '/tools-y += ucl upx/d' tools/Makefile
sed -i '/tools-y :=/a\tools-y += ucl upx' tools/Makefile
sed -i "/\$(curdir)\/upx\/compile := \$(curdir)\/ucl\/compile/d" tools/Makefile
sed -i '/# builddir dependencies/a\$(curdir)/upx/compile := $(curdir)/ucl/compile' tools/Makefile
