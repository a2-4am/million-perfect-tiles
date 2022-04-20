#!/usr/bin/env python3

# usage:
# $ ./unpacker.py puzzles.bin 16
#
# prints all puzzles of given size to stdout
# second argument can be 6, 8, 10, 12, 14, 16

import bitarray # https://pypi.org/project/bitarray/
import sys

# these constants are hard-coded, not stored in the file
BOARD_SIZES = (6, 8, 10, 12, 14, 16)
STARTING_OFFSET_PER_BOARD_SIZE = {6:0, 8:5600*8, 10:14700*8, 12:28700*8, 14:46900*8, 16:70700*8}
BITS_PER_BOARD_SIZE = {6:8*8, 8:13*8, 10:20*8, 12:26*8, 14:34*8, 16:45*8}
BOARDS_PER_SIZE = 700

def fetchbit():
    global bits, bit_index
    b = bits[bit_index]
    bit_index += 1
    return b

if __name__ == "__main__":
    bits = bitarray.bitarray(endian="big")
    with open(sys.argv[1], 'rb') as f:
        bits.fromfile(f)
    board_size = int(sys.argv[2])
    if not board_size in BOARD_SIZES:
        raise ValueError
    bit_index = STARTING_OFFSET_PER_BOARD_SIZE[board_size]
    max_output_size = board_size * board_size
    for puzzle_index in range(BOARDS_PER_SIZE):
        output = []
        starting_bit_index = bit_index
        while len(output) < max_output_size:
            if fetchbit():
                output.append(".")
                while fetchbit():
                    output.append(".")
                    if len(output) >= max_output_size:
                        break
                    output.append(".")
            if len(output) >= max_output_size:
                break
            if fetchbit():
                output.append(str(int(fetchbit())))
            else:
                output.append(".")
        print("".join(output))
        while bit_index - starting_bit_index < BITS_PER_BOARD_SIZE[board_size]:
            fetchbit()
