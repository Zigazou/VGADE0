#!/usr/bin/env python

class Size:
    normal_size = 0
    double_width = 1
    double_height = 2
    double_size = 3

class Part:
    top_left = 0
    top_right = 1
    bottom_left = 2
    bottom_right = 3

class Color:
    black = 0
    red = 1
    green = 2
    yellow = 3
    blue = 4
    magenta = 5
    cyan = 6
    white = 7

class CharAttr:
    def __init__(self, character):
        self.foreground = Color.white
        self.background = Color.black
        self.char = ord(character)
        self.underline = False
        self.blink = False
        self.invert = False
        self.size = Size.normal_size
        self.part = Part.top_left

    def pack(self):
        return (
            self.char +
            self.size * 2 ** 11 +
            self.part * 2 ** 13 +
            self.blink * 2 ** 15 +
            self.foreground * 2 ** 16 +
            self.background * 2 ** 19 +
            self.underline * 2 ** 22 +
            self.invert * 2 ** 23
        )

rows = open("screen.txt", "rb").read(16384).split("\n")

extend = 0x200
with open('initial_screen.txt', 'w') as video_memory:
    for row in rows:
        for char in row:
            c = CharAttr(char)
            if char == ':':
                c.char = extend
                c.background = extend % 8
                c.foreground = Color.white
                c.invert = False
                extend += 1
                if extend == 0x2e0:
                    extend = 0x200
            elif char == '?':
                c.foreground = Color.red
            elif (char >= 'A' and char <= 'Z'):
                c.underline = True
            elif (char >= '0' and char <= '9'):
                pass
            elif char == '!':
                pass
            else:
                c.foreground = Color.yellow

            video_memory.write(bin(c.pack())[2:].zfill(24))
            video_memory.write("\n")

