#!/bin/bash
set -e

REPO_URL='https://git.openwrt.org/openwrt/openwrt.git'
REPO_BRANCH='master'
GITHUB_REPOSITORY='SGPublic/k2p-lede'
GITHUB_ACTOR='SGPublic'
CONFIG_FILE='/mnt/e/Documents/Github/k2p-lede/origin.config'
CONFIG_FILE_COMPILED='/mnt/e/Documents/Github/k2p-lede/k2p.config'
DIY_P1_SH='/mnt/e/Documents/Github/k2p-lede/diy-part1.sh'
DIY_P2_SH='/mnt/e/Documents/Github/k2p-lede/diy-part2.sh'
THREAD=12
BIN_OUT_DIR='/mnt/e/Documents/Github/k2p-lede/local/bin'

step_current=0
step_total=9
print_step() {
  step_current=$((step_current+1))
  echo -e "\e[1;32m  Step $step_current ($step_total total): $1\e[0m"
}

print_command() {
  echo -e "\e[1;33m  runing:\e[0m \e[1;34m$1\e[0m"
}

Clone_Source_Code() {
  print_step 'Clone source code'
  print_command "rm -rf openwrt"
  rm -rf openwrt

  if [ -f 'openwrt.bak' ]; then
    print_command "git clone $REPO_URL -b $REPO_BRANCH openwrt"
    git clone $REPO_URL -b $REPO_BRANCH openwrt
    print_command "cp -r openwrt openwrt.bak"
    cp -r openwrt openwrt.bak
    print_command "cd openwrt"
    cd openwrt
  else
    print_command "cd openwrt.bak"
    cd openwrt.bak
    print_command "git pull"
    git pull
    print_command "cp -r ../openwrt.bak ../openwrt"
    cp -r ../openwrt.bak ../openwrt
    print_command "cd ../openwrt"
    cd ../openwrt
  fi
}

Load_Custom_Feeds() {
  print_step 'Load custom feeds'
  print_command "sh $DIY_P1_SH --lcoal"
  bash $DIY_P1_SH --lcoal
}

Update_Feeds() {
  print_step 'Update feeds'
  print_command "./scripts/feeds update -a"
  ./scripts/feeds update -a
}

Install_Feeds() {
  print_step 'Install feeds'
  print_command "./scripts/feeds install -a"
  ./scripts/feeds install -a
}

Openwrt_AutoUpdate() {
  ZZZ_DEFAULT_SETTINGS='./package/sgpublic/default-settings/files/zzz-default-settings'
  print_step "Openwrt AutoUpdate"
  print_command "VERSION_TAG=$(date +"%Y%m%d_%H%M%S_")$(git rev-parse --short HEAD)"
  VERSION_TAG=$(date +"%Y%m%d_%H%M%S_")$(git rev-parse --short HEAD)
  print_command "sed -i \"/DISTRIB_DESCRIPTION=/a\sed -i '/DISTRIB_GITHUB/d' /etc/openwrt_release\" $ZZZ_DEFAULT_SETTINGS"
  sed -i "/DISTRIB_DESCRIPTION=/a\sed -i '/DISTRIB_GITHUB/d' /etc/openwrt_release" $ZZZ_DEFAULT_SETTINGS
  print_command "sed -i \"/DISTRIB_GITHUB/a\echo \"DISTRIB_GITHUB=\'https://github.com/$GITHUB_REPOSITORY\'\" >> /etc/openwrt_release\" $ZZZ_DEFAULT_SETTINGS"
  sed -i "/DISTRIB_GITHUB/a\echo \"DISTRIB_GITHUB=\'https://github.com/$GITHUB_REPOSITORY\'\" >> /etc/openwrt_release" $ZZZ_DEFAULT_SETTINGS
  print_command "sed -i \"/DISTRIB_DESCRIPTION=/a\sed -i '/DISTRIB_VERSIONS/d' /etc/openwrt_release\" $ZZZ_DEFAULT_SETTINGS"
  sed -i "/DISTRIB_DESCRIPTION=/a\sed -i '/DISTRIB_VERSIONS/d' /etc/openwrt_release" $ZZZ_DEFAULT_SETTINGS
  print_command "sed -i \"/DISTRIB_VERSIONS/a\echo \"DISTRIB_VERSIONS=\'$VERSION_TAG\'\" >> /etc/openwrt_release\" $ZZZ_DEFAULT_SETTINGS"
  sed -i "/DISTRIB_VERSIONS/a\echo \"DISTRIB_VERSIONS=\'$VERSION_TAG\'\" >> /etc/openwrt_release" $ZZZ_DEFAULT_SETTINGS
  print_command "sed -i \"s/OpenWrt /$GITHUB_ACTOR compiled ($VERSION_TAG) \/ OpenWrt /g\" $ZZZ_DEFAULT_SETTINGS"
  sed -i "s/OpenWrt /$GITHUB_ACTOR compiled ($VERSION_TAG) \/ OpenWrt /g" $ZZZ_DEFAULT_SETTINGS
}

Load_Custom_Configuration() {
  print_step 'Load custom configuration'
  print_command "cp $CONFIG_FILE ./.config"
  cp $CONFIG_FILE ./.config
  print_command "sh $DIY_P2_SH --lcoal"
  bash $DIY_P2_SH --lcoal
}

Download_Package() {
  print_step 'Download package'
  echo -e "\e[1;36m  Do you need to change the config file? (y/N): \e[0m\c"
  read need
  if [[ "$need" =~ ^[yY]$ ]]; then
    print_command "make menuconfig -j$THREAD || make menuconfig -j1 || make menuconfig -j1 V=s"
    make menuconfig -j$THREAD || make menuconfig -j1 || make menuconfig -j1 V=s
  else
    print_command "make defconfig -j$THREAD || make defconfig -j1 || make defconfig -j1 V=s"
    make defconfig -j$THREAD || make defconfig -j1 || make defconfig -j1 V=s
  fi
  print_command "cp ./.config $CONFIG_FILE_COMPILED"
  cp ./.config $CONFIG_FILE_COMPILED
  print_command "make download -j$THREAD || make download -j1 || make download -j1 V=s"
  make download -j$THREAD || make download -j1 || make download -j1 V=s
  print_command "find dl -size -1024c -exec ls -l {} \;"
  find dl -size -1024c -exec ls -l {} \;
  print_command "find dl -size -1024c -exec rm -f {} \;"
  find dl -size -1024c -exec rm -f {} \;
}

Compile_The_Firmware() {
  print_step 'Compile the firmware'
  print_command "make -j$THREAD || make -j1 || make -j1 V=s"
  make -j$THREAD || make -j1 || make -j1 V=s
}

Upload_Firmware_To_Release() {
  print_step 'Upload firmware to release'
  print_command "rm -rf $BIN_OUT_DIR"
  rm -rf $BIN_OUT_DIR
  print_command "rm -rf ./bin/targets/*/*/packages"
  rm -rf ./bin/targets/*/*/packages
  print_command "cp -r ./bin/targets/*/*/ $BIN_OUT_DIR/"
  cp -r ./bin/targets/*/*/ $BIN_OUT_DIR/
}

main() {
  Clone_Source_Code
  Load_Custom_Feeds
  Update_Feeds
  Install_Feeds
  Openwrt_AutoUpdate
  Load_Custom_Configuration
  Download_Package
  Compile_The_Firmware
  Upload_Firmware_To_Release
}

main
