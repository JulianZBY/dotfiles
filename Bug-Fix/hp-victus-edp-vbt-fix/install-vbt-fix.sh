#!/usr/bin/env bash
set -Eeuo pipefail

# Resolve paths relative to this script, not the current directory.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VBT_SRC="${SCRIPT_DIR}/vbt-ddib-off.bin"

VBT_NAME="vbt-ddib-off.bin"
VBT_DST="/usr/lib/firmware/i915/${VBT_NAME}"
# NOTE: /etc/kernel/cmdline is for systemd-boot; on Fedora+GRUB the kernel
# args live in BLS entries managed by grubby, so we only touch grubby below.
VBT_PARAM="i915.vbt_firmware=i915/${VBT_NAME}"
DRACUT_CONF="/etc/dracut.conf.d/90-i915-vbt-ddib-off.conf"

die() {
    printf '错误：%s\n' "$*" >&2
    exit 1
}

info() {
    printf '\n==> %s\n' "$*"
}

# Require root.
if [[ "${EUID}" -ne 0 ]]; then
    die "请使用 sudo 运行：sudo bash ./install-vbt-fix.sh"
fi

# This script targets Fedora with GRUB and dracut.
[[ -f /etc/fedora-release ]] ||
    die "未检测到 Fedora，停止修改。"

command -v grubby >/dev/null ||
    die "未找到 grubby；此脚本要求使用 GRUB。"

command -v dracut >/dev/null ||
    die "未找到 dracut。"

command -v lsinitrd >/dev/null ||
    die "未找到 lsinitrd。"

command -v python3 >/dev/null ||
    die "未找到 python3。"

[[ -f "$VBT_SRC" ]] ||
    die "找不到脚本目录中的 $VBT_NAME。"

# Verify the VBT signature before installing.
python3 - "$VBT_SRC" <<'PY'
import pathlib
import sys

p = pathlib.Path(sys.argv[1])
data = p.read_bytes()

if len(data) < 32 or not data.startswith(b"$VBT"):
    sys.exit(f"错误：{p} 不是预期的 VBT 文件，拒绝安装。")

print(f"VBT 检查通过：{p}（{len(data)} 字节）")
PY

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/var/backups/i915-vbt-ddib-off-${STAMP}"

info "备份现有配置"
install -d -m 0700 "$BACKUP_DIR"

for path in "$VBT_DST" "$DRACUT_CONF"; do
    if [[ -e "$path" ]]; then
        cp -a --parents "$path" "$BACKUP_DIR/"
    fi
done

grubby --info=ALL > "${BACKUP_DIR}/grubby-info-before.txt" || true

info "安装修改后的 VBT"
install -D -m 0644 "$VBT_SRC" "$VBT_DST"

info "配置 dracut，将 VBT 放入 initramfs"
cat > "$DRACUT_CONF" <<EOF
install_items+=" ${VBT_DST} "
EOF

info "为所有已安装内核添加启动参数（grubby 管理 BLS 条目）"
grubby --update-kernel=ALL --remove-args="i915.vbt_firmware"
grubby --update-kernel=ALL --args="$VBT_PARAM"

info "重新生成所有已安装内核的 initramfs"
dracut --regenerate-all --force

info "验证已安装内核对应的 initramfs 中是否包含 VBT"

found=0

# Only verify initramfs images whose kernel still exists in /lib/modules,
# so stale images from uninstalled kernels don't fail the script.
for kdir in /lib/modules/*; do
    [[ -d "$kdir" ]] || continue
    initrd="/boot/initramfs-$(basename "$kdir").img"
    [[ -f "$initrd" ]] || continue

    # Capture first: `lsinitrd | grep -q` can kill lsinitrd via SIGPIPE,
    # and pipefail would turn that into a spurious failure.
    out="$(lsinitrd "$initrd")"
    if grep -Fq "$VBT_NAME" <<< "$out"; then
        printf '通过：%s\n' "$initrd"
        found=$((found + 1))
    else
        printf '失败：%s 中没有找到 %s\n' "$initrd" "$VBT_NAME" >&2
        die "initramfs 验证失败，请勿删除备份。"
    fi
done

(( found > 0 )) ||
    die "没有找到可验证的 initramfs。"

info "检查 GRUB 启动项参数"

grubby_out="$(grubby --info=ALL)"
if grep -Fq "$VBT_PARAM" <<< "$grubby_out"; then
    printf '通过：已在 GRUB 启动项中找到 VBT 参数。\n'
else
    die "未在 GRUB 启动项中找到 VBT 参数，请检查配置。"
fi

printf '\n安装步骤已完成。\n'
printf '备份目录：%s\n' "$BACKUP_DIR"
printf '请重启并测试合盖、开盖唤醒。\n'
