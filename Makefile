#
# Million Perfect Tiles makefile
# assembles source code, optionally builds a disk image and mounts it
#
# original by Quinn Dunki on 2014-08-15
# One Girl, One Laptop Productions
# http://www.quinndunki.com/blondihacks
#
# adapted by 4am on 2022-04-08
#

# third-party tools required to build

# https://sourceforge.net/projects/acme-crossass/
ACME=acme

# https://github.com/mach-kernel/cadius
# version 1.4.4 or later
CADIUS=cadius

BUILDDISK=build/tiles.po
DISKVOLUME=MILLION.TILES

asm: dirs
	$(ACME) -r build/tiles.lst src/tiles.a

dsk: asm
	$(CADIUS) CREATEVOLUME "$(BUILDDISK)" "$(DISKVOLUME)" 140KB -C
	$(CADIUS) ADDFILE "${BUILDDISK}" "/$(DISKVOLUME)/" "res/PRODOS#FF0000" -C
	$(CADIUS) ADDFILE "${BUILDDISK}" "/$(DISKVOLUME)/" "res/CLOCK.SYSTEM#FF0000" -C
	$(CADIUS) ADDFILE "${BUILDDISK}" "/$(DISKVOLUME)/" "build/MPT.SYSTEM#FF0000" -C
	$(CADIUS) ADDFILE "${BUILDDISK}" "/$(DISKVOLUME)/" "res/MPT.PUZZLES#060000" -C
	$(CADIUS) ADDFILE "${BUILDDISK}" "/$(DISKVOLUME)/" "res/MPT.PREFS#040000" -C

clean:
	rm -rf build/

dirs:
	mkdir -p build

mount:
	open "$(BUILDDISK)"

all: clean dsk mount

al: all
