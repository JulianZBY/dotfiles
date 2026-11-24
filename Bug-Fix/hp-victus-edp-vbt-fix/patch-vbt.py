#!/usr/bin/env python3
import struct
import sys
from pathlib import Path

if len(sys.argv) != 3:
    sys.exit(f"用法: {sys.argv[0]} 输入.vbt 输出.bin")

src, dst = map(Path, sys.argv[1:])
d = bytearray(src.read_bytes())

if d[:4] != b"$VBT":
    sys.exit("错误：没有找到 $VBT 签名")

bdb_off = struct.unpack_from("<I", d, 28)[0]
if d[bdb_off:bdb_off + 16] != b"BIOS_DATA_BLOCK ":
    sys.exit("错误：没有找到 BIOS_DATA_BLOCK")

_, bdb_hdr, bdb_size = struct.unpack_from("<HHH", d, bdb_off + 16)
p = bdb_off + bdb_hdr
end = bdb_off + bdb_size

while p < end:
    bid = d[p]
    bsize = struct.unpack_from("<H", d, p + 1)[0]
    if bid == 2:
        break
    p += 3 + bsize
else:
    sys.exit("错误：没有找到 General Definitions block")

data = p + 3
if bsize < 5:
    sys.exit("错误：General Definitions block 长度异常")

child_size = d[data + 4]
if child_size < 17:
    sys.exit(f"错误：child device 条目长度异常：{child_size}")

count = (bsize - 5) // child_size
matches = []

for i in range(count):
    c = data + 5 + i * child_size
    dtype = struct.unpack_from("<H", d, c + 2)[0]
    port = d[c + 16]
    print(f"Child {i}: type=0x{dtype:04x}, port=0x{port:02x}")
    if dtype == 0x1806 and port == 0x07:
        matches.append(c)

if len(matches) != 1:
    sys.exit(f"停止：目标条目匹配数为 {len(matches)}，预期为 1；未写入文件")

c = matches[0]
removed = d[c + 2] + d[c + 3]
struct.pack_into("<H", d, c + 2, 0)
d[26] = (d[26] + removed) & 0xff

if sum(d) % 256 != sum(src.read_bytes()) % 256:
    sys.exit("错误：VBT 字节和校验失败")

dst.write_bytes(d)
print(f"已写入：{dst}")
print("仅修改目标 device_type 和校验和；请继续验证输出。")
