#!/usr/bin/env python3

import sys

def myhex(bitstring):
    return hex(int(bitstring, 2))[2:].rjust(2, "0").upper()

leftdata =  [ [], [], [], [], [], [], [], [] ]
rightdata = [ [], [], [], [], [], [], [], [] ]
with open("font.txt", "r") as f:
    for c in ('empty tile','right-facing pointer','white tile','blue tile','purple tile') + \
        tuple('./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ'):
        if f.readline().strip()[1:] != c:
            raise ValueError(c)
        for row in range(8):
            left = f.read(7)
            right = f.read(7)
            f.readline()
            if c in ('purple tile',):
                left = "0b0" + left[::-1]
                right = "0b0" + right[::-1]
            else:
                left = "0b1" + left[::-1]
                right = "0b1" + right[::-1]
            #print(myhex(left), myhex(right))
            leftdata[row].append(myhex(left))
            rightdata[row].append(myhex(right))
print("; Million Perfect Tiles Wide pixel font")
print("; (c) 2022 by 4am")
print("; license:Open Font License 1.1, see OFL.txt")
print("; This file is automatically generated")
for row in range(8):
    print("LeftFontRow%s" % row)
    for c, i in zip(leftdata[row], range(len(leftdata[row]))):
        print("         !byte $%s" % c)
for row in range(8):
    print("RightFontRow%s" % row)
    for c, i in zip(rightdata[row], range(len(rightdata[row]))):
        print("         !byte $%s" % c)
