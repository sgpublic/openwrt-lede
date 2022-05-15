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

git_clone() {
  path=`pwd`
  if [ -d $2 ]; then
    cd $2
    git pull
    cd $path
  else
    git clone $1 $2
  fi
}

# 添加软件源 fw876/helloworld
git_clone https://github.com/fw876/helloworld.git package/helloworld
# 添加软件源 sundaqiang/openwrt-packages
git_clone https://github.com/sundaqiang/openwrt-packages.git package/sundaqiang

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

# 拉取插件 luci-app-filebrowser
rm -rf package/sgpublic/luci-app-filebrowser
svn co https://github.com/sgpublic/luci-app-filebrowser/trunk package/sgpublic/luci-app-filebrowser
