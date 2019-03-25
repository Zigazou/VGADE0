#!/usr/bin/env python3

from PIL import Image

def getbit(rgbs, x, y):
    r, g, b = rgbs.getpixel((x, y))
    if r > 0:
        return 1

    return 0

def getcharbytes(rgbs, i, j):
    x = i * 8
    bytes = []

    for y in range(j * 10, (j + 1) * 10):
        bytes.append(
            getbit(rgbs, x + 0, y) * 128 +
            getbit(rgbs, x + 1, y) * 64 +
            getbit(rgbs, x + 2, y) * 32 +
            getbit(rgbs, x + 3, y) * 16 +
            getbit(rgbs, x + 4, y) * 8 +
            getbit(rgbs, x + 5, y) * 4 +
            getbit(rgbs, x + 6, y) * 2 +
            getbit(rgbs, x + 7, y) * 1 
        )

    return bytes

# G0 character set (alphanumerical)
g0_charset = Image.open("ef9345-g0.png")

rgbs = g0_charset.convert('RGB')

allbytes = []
for i in range(0, 8):
    for j in range(0, 16):
        allbytes += getcharbytes(rgbs, i, j)

with open('minitel-g0.txt', 'w') as f:
    for byte in allbytes:
        f.write(bin(byte)[2:].zfill(8))
        f.write("\n")

# G1 character set (mosaic)
g1_charset = Image.open("ef9345-g1.png")

rgbs = g1_charset.convert('RGB')

allbytes = []
for i in range(0, 8):
    for j in range(0, 16):
        allbytes += getcharbytes(rgbs, i, j)

with open('minitel-g1.txt', 'w') as f:
    for byte in allbytes:
        f.write(bin(byte)[2:].zfill(8))
        f.write("\n")

