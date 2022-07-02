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

# 修改标准目录
sed -i 's/$(TOPDIR)\/staging_dir/\/tmp\/openwrt\/staging_dir/g' rules.mk
sed -i 's/$(TOPDIR)\/build_dir/\/tmp\/openwrt\/build_dir/g' rules.mk

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate
# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-nginx/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-ssl-nginx/Makefile

# 删除 uhttpd
sed -i 's/+uhttpd //g' feeds/luci/collections/luci/Makefile
sed -i 's/+uhttpd-mod-ubus //g' feeds/luci/collections/luci/Makefile
