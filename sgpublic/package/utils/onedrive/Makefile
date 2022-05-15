# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 sgpublic

include $(TOPDIR)/rules.mk

PKG_NAME:=onedrive
PKG_VERSION:=2.4.16
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/abraunegg/onedrive/archive/refs/tags/
PKG_SOURCE_DATE:=2022-03-10
PKG_HASH:=7660cc6f637ee78f6b1135f52afe2f6568295ec94bd187ceb3e99737e0985ea7

PKG_MAINTAINER:=abraunegg
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILE:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/onedrive
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=OneDrive Client for Linux
  URL:=https://github.com/abraunegg/onedrive
  DEPENDS:=+libcurl +libsqlite3 +libpthread
endef

define Package/onedrive/description
  A free Microsoft OneDrive Client which supports OneDrive Personal, OneDrive for Business, OneDrive for Office365 and SharePoint.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/onedrive/ \
		$(TARGET_CONFIGURE_OPTS) \
		TARGET=Linux \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/onedrive/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/onedrive/onedrive $(1)/usr/bin/
endef

$(eval $(call BuildPackage,onedrive))
