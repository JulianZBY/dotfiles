#!/bin/sh
# HP Victus 15-fa1xxx: 挂起前 mask gpe6D（固件假唤醒），恢复后 unmask
# 必须安装到 /usr/lib/systemd/system-sleep/ 且带可执行位
G=/sys/firmware/acpi/interrupts/gpe6D

[ -w "$G" ] || exit 0

case "$1" in
    pre)  echo mask   > "$G" ;;
    post) echo unmask > "$G" ;;
esac
printf '%s %s %s %s\n' "$(date '+%F %T')" "$1" "$2" "$(cat "$G")" >> /run/mask-gpe6d.log
