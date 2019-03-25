#!/usr/bin/env python3

rows = open("nyan_cat.txt", "rb").read(16384).split("\n")

with open('video_memory.txt', 'w') as video_memory:
    for row in rows:
        for char in row:
            if char == ':':
                foreground = 7
                background = 4
                blink = 1
            elif char == '?':
                foreground = 1
                background = 0
                blink = 0
            elif (char >= 'A' and char <= 'Z') or (char >= '0' and char <= '9') or char == '!':
                foreground = 7
                background = 0
                blink = 0
            else:
                foreground = 3
                background = 0
                blink = 0

            byte = ord(char) + foreground * 256 + background * 2048 + blink * 16384

            video_memory.write(bin(byte)[2:].zfill(15))
            video_memory.write("\n")

