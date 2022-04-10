#!/usr/bin/env python3

import itertools
import random
import sys
import time

# returns (value, rowindex, colindex) or (None, None, None)
def nextMove(board):
    global board_size, half_board_size
    for rowindex, row in zip(range(board_size), board):
        try: return ('1', rowindex, row.index('.00'))
        except ValueError: pass
        try: return ('1', rowindex, row.index('0.0') + 1)
        except ValueError: pass
        try: return ('1', rowindex, row.index('00.') + 2)
        except ValueError: pass
        try: return ('0', rowindex, row.index('.11'))
        except ValueError: pass
        try: return ('0', rowindex, row.index('1.1') + 1)
        except ValueError: pass
        try: return ('0', rowindex, row.index('11.') + 2)
        except ValueError: pass
        if row.count('0') == half_board_size:
            try: return ('1', rowindex, row.index('.'))
            except ValueError: pass
        if row.count('1') == half_board_size:
            try: return ('0', rowindex, row.index('.'))
            except ValueError: pass
    for rowindex, row1 in zip(range(board_size), board):
        if '.' in row1: continue
        for rowindex2, row2 in zip(range(rowindex+1, board_size), board[rowindex+1:]):
            try: dot1 = row2.index('.')
            except ValueError: continue
            if row2.count('.') != 2: continue
            dot2 = row2.rindex('.')
            if '%s.%s.%s' % (row1[:dot1], row1[dot1+1:dot2], row1[dot2+1:]) != row2: continue
            return ((row1[dot1] == '0') and '1' or '0', rowindex2, dot1)
    return (None, None, None)

# returns True or False
def solve(board):
    while True:
        value, rowindex, colindex = nextMove(board)
        if not value:
            value, colindex, rowindex = nextMove(list(map(''.join, zip(*board))))
            if not value:
                return '.' not in itertools.chain(*board)
        board[rowindex] = '%s%s%s' % (board[rowindex][:colindex], value, board[rowindex][colindex+1:])

# returns True or False
def hasDuplicateRows(board):
    fullRows = [row for row in board if '.' not in row]
    return fullRows and (len(set(fullRows)) != len(fullRows))

# returns True or False
def construct(coordsindex):
    global watchdog_counter, board_size, half_board_size, solution, coords
    if watchdog_counter < 0:
        return False
    watchdog_counter -= 1
    try: rowindex, colindex = coords[coordsindex]
    except IndexError: return True
    for value, value3 in random.choice(((('0','000'), ('1','111')), (('1','111'), ('0','000')))):
        row = solution[rowindex]
        if row.count(value) == half_board_size: continue
        new_row = '%s%s%s' % (row[:colindex], value, row[colindex+1:])
        if value3 in new_row: continue
        tboard = list(map(''.join, zip(*solution)))
        col = tboard[colindex]
        if col.count(value) == half_board_size: continue
        tboard[colindex] = '%s%s%s' % (col[:rowindex], value, col[rowindex+1:])
        if value3 in tboard[colindex]: continue
        if hasDuplicateRows(tboard): continue
        solution[rowindex] = new_row
        if not hasDuplicateRows(solution):
            if construct(coordsindex + 1):
                return True
        solution[rowindex] = row
    return False

if __name__ == '__main__':
    board_size = int(sys.argv[1])
    half_board_size = board_size / 2
    coords = list(itertools.product(range(board_size), range(board_size)))
    tic1 = time.perf_counter()
    while True:
        watchdog_counter = board_size * board_size * board_size * half_board_size
        solution = ['.' * board_size] * board_size
        if construct(0): break
        #sys.stderr.write('Watchdog timer expired\n')
    tic2 = time.perf_counter()
    #sys.stderr.write(f'{tic2-tic1:0.4f} seconds to construct solution\n')
    random.shuffle(coords)
    puzzle = solution.copy()
    for rowindex, colindex in coords:
        puzzle2 = puzzle.copy()
        puzzle2[rowindex] = row = '%s.%s' % (puzzle2[rowindex][:colindex], puzzle2[rowindex][colindex+1:])
        if solve(puzzle2) and puzzle2 == solution:
            puzzle[rowindex] = row
    tic3 = time.perf_counter()
    spaces = list(itertools.chain(*puzzle)).count('.')
    #sys.stderr.write(f'{tic3-tic2:0.4f} seconds to construct puzzle with {spaces} spaces\n')
    print(''.join(puzzle))
