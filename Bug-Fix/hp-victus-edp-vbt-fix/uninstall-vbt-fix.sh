#!/usr/bin/env bash
set -Eeuo pipefail

# Rollback for install-vbt-fix.sh:
# removes the patched VBT, dracut config and kernel parameter,
# then regenerates initramfs.

VBT_NAME="vbt-ddib-off.bin"
VBT_DST="/usr/lib/firmware/i915/${VBT_NAME}"
DRACUT_CONF="/etc/dracut.conf.d/90-i915-vbt-ddib-off.conf"

die() { printf '错误：%s\n' "$*" >&2; exit 1; }
info() { printf '\n==> %s\n' "$*"; }

[[ "${EUID}" -ne 0 ]] && die "请使用 sudo 运行：sudo bash ./uninstall-vbt-fix.sh"

command -v grubby >/dev/null || die "未找到 grubby。"
command -v dracut >/dev/null || die "未找到 dracut。"

# Restore original VBT if a backup exists, otherwise just remove the patched one.
restored=0
for backup in /var/backups/i915-vbt-ddib-off-*; do
    [[ -f "${backup}/${VBT_DST}" ]] || continue
    info "从备份恢复原始 VBT：${backup}"
    install -D -m 0644 "${backup}/${VBT_DST}" "$VBT_DST"
    restored=1
    break
done
if [[ "$restored" -eq 0 && -e "$VBT_DST" ]]; then
    info "未找到原始 VBT 备份，直接删除补丁文件"
    rm -f -- "$VBT_DST"
fi

rm -f -- "$DRACUT_CONF"

info "移除所有内核启动项中的 VBT 参数"
grubby --update-kernel=ALL --remove-args="i915.vbt_firmware"

info "重新生成所有已安装内核的 initramfs"
dracut --regenerate-all --force

info "验证参数已移除"
if grubby --info=ALL | grep -Fq "i915.vbt_firmware"; then
    die "仍有启动项包含 i915.vbt_firmware，请手动检查。"
fi
printf '通过：所有启动项已移除 i915.vbt_firmware。\n'
printf '\n回滚完成，请重启并观察合盖/开盖唤醒。\n'
