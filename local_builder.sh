#!/bin/bash
set -e

REPO_URL='https://git.openwrt.org/openwrt/openwrt.git'
REPO_BRANCH='v21.02.3'
GITHUB_REPOSITORY='SGPublic/openwrt-lede'
GITHUB_ACTOR='SGPublic'
CONFIG_FILE='/mnt/e/Documents/GitHub/openwrt-lede/origin.config'
DIY_P1_SH='/mnt/e/Documents/GitHub/openwrt-lede/diy-part1.sh'
DIY_P2_SH='/mnt/e/Documents/GitHub/openwrt-lede/diy-part2.sh'
THREAD=12
OUTPUT_DIR='/mnt/e/Documents/GitHub/openwrt-lede/local'

declare -a _STEP_STACK=(
  Clone_Source_Code
  Load_Custom_Feeds
  Update_Feeds
  Install_Feeds
  Load_Custom_Configuration
  Download_Package
  Compile_The_Firmware
  Organize_Files
  Post_Toolchain_Cache
  Upload_Firmware_To_Release
)

runing() {
  echo -e "\e[1;33m  runing:\e[0m \e[1;34m$1\e[0m"
}

execute() {
  runing "$1"
  $1
}

comfirm() {
  echo -e "\e[1;36m  $1: \e[0m\c"
}

main() {
  comfirm "Do you need to initialize your Linux? (y/N)"
  read _need

  if [[ "$_need" =~ ^[yY]$ ]]; then
    execute "sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc"
    execute "sudo apt-get update -y"
    execute "sudo apt-get install $(curl -fsSL git.io/depends-ubuntu-2004) -y"
    execute "sudo apt-get clean"
  fi

  if [ -d 'openwrt.bak' ]; then
    comfirm "Do you want to use cache? If you select No, the cache will be deleted. (Y/n)"
    read _need
    if [[ "$_need" =~ ^[nN]$ ]]; then
      execute "rm -rf openwrt.bak"
    fi
  fi

  for _element in ${_STEP_STACK[@]}; do
    $_element
  done
}

_STEP_CURRENT=0
print_step() {
  _STEP_CURRENT=$((_STEP_CURRENT+1))
  echo -e "\e[1;32m  Step $_STEP_CURRENT (${#_STEP_STACK[@]} total): $1\e[0m"
}

Clone_Source_Code() {
  print_step 'Clone source code'
  execute "rm -rf openwrt"

  if [ ! -d 'openwrt.bak' ]; then
    execute "git clone $REPO_URL -b $REPO_BRANCH openwrt.bak"
    execute "cd openwrt.bak"
  else
    execute "cd openwrt.bak"
    execute "git pull origin $REPO_BRANCH"
  fi
}

Load_Custom_Feeds() {
  print_step 'Load custom feeds'
  execute "bash $DIY_P1_SH --local"
}

Update_Feeds() {
  print_step 'Update feeds'
  execute "./scripts/feeds update -a"
  execute "cp -r ../openwrt.bak ../openwrt"
  execute "cd ../openwrt"
}

Install_Feeds() {
  print_step 'Install feeds'
  execute "./scripts/feeds install -a"
}

# Openwrt_AutoUpdate() {
#   _ZZZ_DEFAULT_SETTINGS='./package/default-settings/files/zzz-default-settings'
#   print_step "Openwrt AutoUpdate"
#   _VERSION_TAG=$(date +"%Y%m%d_%H%M%S_")$(git rev-parse --short HEAD)
#   comfirm "_VERSION_TAG=$_VERSION_TAG\n"
#   runing "sed -i \"/DISTRIB_DESCRIPTION=/a\sed -i '/DISTRIB_GITHUB/d' /etc/openwrt_release\" $_ZZZ_DEFAULT_SETTINGS"
#   sed -i "/DISTRIB_DESCRIPTION=/a\sed -i '/DISTRIB_GITHUB/d' /etc/openwrt_release" $_ZZZ_DEFAULT_SETTINGS
#   runing "sed -i \"/DISTRIB_GITHUB/a\echo \"DISTRIB_GITHUB=\'https://github.com/$GITHUB_REPOSITORY\'\" >> /etc/openwrt_release\" $_ZZZ_DEFAULT_SETTINGS"
#   sed -i "/DISTRIB_GITHUB/a\echo \"DISTRIB_GITHUB=\'https://github.com/$GITHUB_REPOSITORY\'\" >> /etc/openwrt_release" $_ZZZ_DEFAULT_SETTINGS
#   runing "sed -i \"/DISTRIB_DESCRIPTION=/a\sed -i '/DISTRIB_VERSIONS/d' /etc/openwrt_release\" $_ZZZ_DEFAULT_SETTINGS"
#   sed -i "/DISTRIB_DESCRIPTION=/a\sed -i '/DISTRIB_VERSIONS/d' /etc/openwrt_release" $_ZZZ_DEFAULT_SETTINGS
#   runing "sed -i \"/DISTRIB_VERSIONS/a\echo \"DISTRIB_VERSIONS=\'$_VERSION_TAG\'\" >> /etc/openwrt_release\" $_ZZZ_DEFAULT_SETTINGS"
#   sed -i "/DISTRIB_VERSIONS/a\echo \"DISTRIB_VERSIONS=\'$_VERSION_TAG\'\" >> /etc/openwrt_release" $_ZZZ_DEFAULT_SETTINGS
#   runing "sed -i \"s/OpenWrt /$GITHUB_ACTOR compiled ($_VERSION_TAG) \/ OpenWrt /g\" $_ZZZ_DEFAULT_SETTINGS"
#   sed -i "s/OpenWrt /$GITHUB_ACTOR compiled ($_VERSION_TAG) \/ OpenWrt /g" $_ZZZ_DEFAULT_SETTINGS
# }

Load_Custom_Configuration() {
  print_step 'Load custom configuration'
  execute "cp $CONFIG_FILE ./.config"
  execute "bash $DIY_P2_SH --local"
}

Download_Package() {
  print_step 'Download package'
  comfirm "Do you need to change the config file? (y/N)"
  read _need
  if [[ "$_need" =~ ^[yY]$ ]]; then
    runing "make menuconfig -j$THREAD || make menuconfig -j1 || make menuconfig -j1 V=s"
    make menuconfig -j$THREAD || make menuconfig -j1 || make menuconfig -j1 V=s
  else
    runing "make defconfig -j$THREAD || make defconfig -j1 || make defconfig -j1 V=s"
    make defconfig -j$THREAD || make defconfig -j1 || make defconfig -j1 V=s
  fi
  mkdir -p $OUTPUT_DIR
  execute "cp ./.config $OUTPUT_DIR/"
  runing "make download -j$THREAD || make download -j1 || make download -j1 V=s"
  make download -j$THREAD || make download -j1 || make download -j1 V=s
  runing "find dl -size -1024c -exec ls -l {} \;"
  find dl -size -1024c -exec ls -l {} \;
  runing "find dl -size -1024c -exec rm -f {} \;"
  find dl -size -1024c -exec rm -f {} \;
}

Compile_The_Firmware() {
  print_step 'Compile the firmware'
  runing "make -j$THREAD || make -j1 || make -j1 V=s"
  make -j$THREAD || make -j1 || make -j1 V=s
}

Organize_Files() {
  print_step 'Organize files'
  mkdir -p $OUTPUT_DIR
  execute "rm -rf $BIN_OUT_DIR/bin/"
  execute "rm -rf ./bin/targets/*/*/packages"
}

Post_Toolchain_Cache() {
  print_step 'Post Toolchain Cache'
  _caches=(".ccache" "build_dir" "staging_dir")
  for _cache in "${_caches[@]}"; do
    execute "rm -rf ../openwrt.bak/${_caches[$_cache]}"
    execute "cp -r ./${_caches[$_cache]} ../openwrt.bak/"
  done
}

Upload_Firmware_To_Release() {
  print_step 'Upload firmware to release'
  mkdir -p $OUTPUT_DIR
  execute "cp -r ./bin/targets/*/*/ $OUTPUT_DIR/bin/"
}

main
