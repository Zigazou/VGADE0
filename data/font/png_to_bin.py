#!/usr/bin/env python

from PIL import Image

def getbit(rgbs, x, y):
    r, g, b = rgbs.getpixel((x, y))
    if r < 32 and g < 32 and b < 32:
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

# Load the image
charset = Image.open("extended_videotex.png")

# Convert the image to RGB
rgbs = charset.convert('RGB')

allbytes = []
for i in range(0, 64):
    for j in range(0, 16):
        
        string = ""
        for byte in getcharbytes(rgbs, i, j):
            string = bin(byte)[2:].zfill(8) + string

        allbytes.append(string)

with open('extended_videotex.txt', 'w') as f:
    for byte in allbytes:
        f.write(byte)
        f.write("\n")

