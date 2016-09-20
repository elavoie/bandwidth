#============================================================================
# bandwidth, a benchmark to estimate memory transfer bandwidth.
# Copyright (C) 2005-2014 by Zack T Smith.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# The author may be reached at veritas@comcast.net.
#============================================================================

CFLAGS= -O6 
CFLAGS= -g
CC=gcc -Wall
LD=gcc 
SRC=main.c 
OBJ=main.o
LIB= 
AS=nasm
ARM_AS=as
ARM_CC=gcc

message:
	@echo ""
	@echo "To compile for x86 Linux:             make bandwidth32"
	@echo "To compile for x86_64 Linux:          make bandwidth64"
	@echo "To compile for x86 Mac OS/X:          make bandwidth-mac32"
	@echo "To compile for x86_64 Mac OS/X:       make bandwidth-mac64"
	@echo "To compile for Raspberry pi 3 32-bit: make bandwidth-rpi32"
	@echo "To compile for generic ARM Linux:     make bandwidth-arm32"
	@echo "To compile for x86 Win32/Cygwin:      make bandwidth-win32"
	@echo "Note! For the Mac you will need to install the latest NASM; Apple's is insufficient."
	@echo ""

bandwidth-rpi32:  main.c routines-arm-rpi3-32bit.asm
	${CC} ${CFLAGS}  -c BMP.c font.c minifont.c
	ar rvs BMP32.a BMP.o font.o minifont.o
	${CC} ${CFLAGS}  -c BMPGraphing.c 
	ar rvs BMPGraphing32.a BMPGraphing.o
	${ARM_AS} -march=armv7 -mfpu=neon routines-arm-rpi3-32bit.asm -mcpu=xscale -o routines-arm-rpi3-32bit.o
	${ARM_CC} routines-arm-rpi3-32bit.o ${SRC} ${CFLAGS} BMP32.a -lm BMPGraphing32.a -o bandwidth32 -o bandwidth-rpi32

bandwidth-arm32:  main.c routines-arm-32bit.asm BMP32.a BMPGraphing32.a
	${ARM_AS} routines-arm-generic-32bit.asm -mcpu=xscale -o routines-arm-generic-32bit.o
	${ARM_CC} routines-arm-generic-32bit.o ${SRC} ${CFLAGS} BMP32.a -lm BMPGraphing32.a -o bandwidth32 -o bandwidth-arm32

bandwidth64:	main.c routines-x86-64bit.asm BMP64.a BMPGraphing64.a
	${AS} -f elf64 routines-x86-64bit.asm -o routines-x86-64bit.o
	${CC} ${CFLAGS} -m64 -c ${SRC}
	${LD} -m64 routines-x86-64bit.o ${OBJ} BMP64.a -lm BMPGraphing64.a -o bandwidth64 

bandwidth32:	main.c routines-x86-32bit.asm BMP32.a BMPGraphing32.a
	${AS} -f elf routines-x86-32bit.asm -o routines-x86-32bit.o
	${CC} ${CFLAGS} -m32 -c ${SRC}
	${LD} -m32 routines-x86-32bit.o ${OBJ} BMP32.a -lm BMPGraphing32.a -o bandwidth32 

bandwidth-mac64:	main.c routines-x86-64bit.asm BMPGraphing64.a BMP64.a
	${AS} -f macho64 routines-x86-64bit.asm -o routines-x86-64bit.o
	${CC} ${CFLAGS} -m64 -c ${SRC}
	${LD} -m64 -lm BMPGraphing64.a BMP64.a routines-x86-64bit.o ${OBJ} ${LIB} -o bandwidth-mac64

bandwidth-mac32:	main.c routines-x86-32bit.asm BMP32.a BMPGraphing32.a
	${AS} -f macho routines-x86-32bit.asm -o routines-x86-32bit.o
	${CC} ${CFLAGS} -m32 -c ${SRC}
	${LD} -m32 BMP32.a -lm BMPGraphing32.a  routines-x86-32bit.o ${OBJ} ${LIB} -o bandwidth-mac32

bandwidth-win32:	main.c routines-x86-32bit.asm  BMP32.a BMPGraphing32.a
	${AS} -f win32 routines-x86-32bit.asm -o routines-x86-32bit.o
	${CC} ${CFLAGS} -m32 -c ${SRC} -Wall -O6 -D__WIN32__ -DWINVER=0x0600 
	${LD} -m32 BMP32.a -lm BMPGraphing32.a routines-x86-32bit.o ${OBJ} ${LIB} -o bandwidth-win32

BMPGraphing64.a: BMPGraphing.c 
	${CC} ${CFLAGS} -m64 -c BMPGraphing.c 
	ar rvs BMPGraphing64.a BMPGraphing.o

BMPGraphing32.a: BMPGraphing.c 
	${CC} ${CFLAGS} -m32 -c BMPGraphing.c 
	ar rvs BMPGraphing32.a BMPGraphing.o

BMP64.a: BMP.c
	${CC} ${CFLAGS} -m64 -c BMP.c font.c minifont.c
	ar rvs BMP64.a BMP.o font.o minifont.o

BMP32.a: BMP.c
	${CC} ${CFLAGS} -m32 -c BMP.c font.c minifont.c
	ar rvs BMP32.a BMP.o font.o minifont.o

clean:
	rm -f main.o bandwidth bandwidth32 bandwidth64 routines-x86-32bit.o routines-x86-64bit.o 
	rm -f bandwidth-win32.exe bandwidth.bmp bandwidth-mac32 bandwidth-mac64 bandwidth-rpi32 bandwidth-arm32 routines-arm-rpi3-32bit.o
	rm -f BMP.o BMP32.a BMP64.a BMPGraphing.o BMPGraphing32.a BMPGraphing64.a
	rm -f font.o minifont.o network_bandwidth.bmp

