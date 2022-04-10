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

# https://www.brutaldeluxe.fr/products/crossdevtools/cadius/
# https://github.com/sicklittlemonkey/cadius
# version 1.4.0 or later
CADIUS=cadius

BUILDDISK=build/tiles

asm:
	mkdir -p build
	$(ACME) -r build/tiles.lst src/tiles.a 2>build/log
	cp res/work.po "$(BUILDDISK)".po >>build/log
	cp res/_FileInformation.txt build/ >>build/log
	$(CADIUS) ADDFILE "${BUILDDISK}".po "/TILES/" "build/TILES.SYSTEM" >>build/log
	for f in res/levels/*; do $(CADIUS) ADDFILE "${BUILDDISK}".po "/TILES/" "$$f" >>build/log; done
	bin/po2do.py build/ build/
	rm "$(BUILDDISK)".po

clean:
	rm -rf build/

mount:
	open "$(BUILDDISK)".dsk

all: clean asm mount

al: all
