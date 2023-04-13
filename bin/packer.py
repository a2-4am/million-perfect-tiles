#!/usr/bin/env python3

# usage:
# $ ./packer.py directory-with-puzzles puzzles.bin
#
# creates or overwrites puzzles.bin
# expects directory-with-puzzles/ to contain these six files:
#   puzzles06.txt
#   puzzles08.txt
#   puzzles10.txt
#   puzzles12.txt
#   puzzles14.txt
#   puzzles16.txt
# each with one line per puzzle (as output by makepuzzle.py)
# each with at least BOARDS_PER_SIZE lines (additional lines within each file will be ignored)

import bitarray # https://pypi.org/project/bitarray/
import os.path
import sys

# these constants are hard-coded, not stored in the file
INPUT_FILES = ('puzzles06.txt', 'puzzles08.txt', 'puzzles10.txt', 'puzzles12.txt', 'puzzles14.txt', 'puzzles16.txt')
BOARD_SIZES = (6, 8, 10, 12, 14, 16)
# starting offsets must match .board_base array in src/unpack.a
STARTING_OFFSET_PER_BOARD_SIZE = {6:0, 8:4096*8, 10:10752*8, 12:20992*8, 14:34304*8, 16:51712*8}
BITS_PER_BOARD_SIZE = {6:8*8, 8:13*8, 10:20*8, 12:26*8, 14:34*8, 16:45*8}
BOARDS_PER_SIZE = 512

if __name__ == "__main__":
    all_bits = bitarray.bitarray(endian="big")
    for filename, board_size in zip(INPUT_FILES, BOARD_SIZES):
        board_count = 0
        with open(os.path.join(sys.argv[1], filename), 'r') as f:
            line_num = 0
            for line in f:
                line_num += 1
                board_bits = bitarray.bitarray(endian="big")
                stored = 0
                for c in line: # intentionally including carriage return at end
                    if c == ".":
                        stored += 1
                        continue
                    if stored:
                        board_bits.append(1)
                        stored -= 1
                        while stored > 1:
                            board_bits.append(1)
                            stored -= 2
                        if stored:
                            board_bits.extend("00")
                        stored = 0
                    if c not in ".01": # carriage return will do stored logic but not add bits
                        continue
                    board_bits.extend("01")
                    board_bits.append(int(c))
                board_bits.extend("0" * (BITS_PER_BOARD_SIZE[board_size] - len(board_bits)))
                if len(board_bits) > BITS_PER_BOARD_SIZE[board_size]:
                    sys.stderr.write(f"Skipping board on line {line_num} because compressed size is too big!\n")
                    continue
                all_bits.extend(board_bits)
                board_count += 1
                if board_count == BOARDS_PER_SIZE:
                    break
    with open(sys.argv[2], 'wb') as f:
        all_bits.tofile(f)
