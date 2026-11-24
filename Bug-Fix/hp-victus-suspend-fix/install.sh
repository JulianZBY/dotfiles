#!/bin/sh
# 一键安装：把 gpe6D mask hook 放到 /usr/lib/systemd/system-sleep/
# 用法: sudo ./install.sh
set -e

SRC="$(dirname "$0")/50-mask-gpe6d.sh"
DST=/usr/lib/systemd/system-sleep/50-mask-gpe6d.sh

[ "$(id -u)" -eq 0 ] || { echo "请用 sudo 运行"; exit 1; }
[ -f "$SRC" ] || { echo "找不到 $SRC"; exit 1; }

# -m 0755 保证可执行位（cp 会丢）
install -m 0755 -v "$SRC" "$DST"

echo
echo "安装完成。验证：挂起一次后 cat /run/mask-gpe6d.log 应出现 pre/post 记录。"
echo "回滚：sudo rm $DST"
