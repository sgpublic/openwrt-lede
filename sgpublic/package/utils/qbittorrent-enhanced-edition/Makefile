# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 sgpublic

include $(TOPDIR)/rules.mk

PKG_NAME:=qbittorrent-enhanced-edition
PKG_VERSION:=4.4.2.10
PKG_RELEASE:=1

PKG_SOURCE:=qbittorrent-enhanced-nox_x86_64-linux-musl_static.zip
PKG_SOURCE_URL:=https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-$(PKG_VERSION)/
PKG_SOURCE_DATE:=2022-03-26
PKG_HASH:=1c93c65179b14dcb02ea159062e4443281dd8b8b51b47857c55afa42fad59d34
PKG_CAT:=unzip

PKG_MAINTAINER:=c0re100
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILE:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/qbittorrent-enhanced-edition
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=qBittorrent Enhanced Edition
  URL:=https://github.com/c0re100/qBittorrent-Enhanced-Edition
  DEPENDS:=+libtorrent-rasterbar
endef

define Package/qbittorrent-enhanced-edition/description
  qBittorrent is a bittorrent client programmed in C++ / Qt that uses libtorrent (sometimes called libtorrent-rasterbar) by Arvid Norberg.
endef

define Build/Compile
endef

define Package/qbittorrent-enhanced-edition/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/../qbittorrent-nox $(1)/usr/bin/qbtee
endef

$(eval $(call BuildPackage,qbittorrent-enhanced-edition))
