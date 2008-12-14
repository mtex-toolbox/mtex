# Makefile of the MTEX toolbox
#
#--------------- begin editable section ------------------------------- 
#
# here comes your operating system
# glnx86  - 32 bit Linux 
# glnxa64 - 64 bit Linux 
# maci    - 32 bit Mac OSX
# maci64  - 64 bit Mac OSX
# win32   - 32 bit Windows
# win64   - 64 bit Windows
#
TARGET ?= glnxa64
#
# please correct the following installation directories:
#
# path to FFTW, i.e. to lib/libfftw3.a
FFTWPATH ?= /home/hielscher/c/
#FFTWPATH = /usr
#
# path to the NFFT, i.e. to /lib/libnfft3.a
NFFTPATH ?= /home/hielscher/c
#NFFTPATH = /usr/local
#
#--------------- end editable section ---------------------------------
#
# local variables
BPATH = ../bin/$(TARGET)
TPATH = ../tools

CC=gcc
LD=gcc
RM = /bin/rm -f
LN = /bin/ln
CFLAGS = -o3 -c -Wall
MYCFLAGS=$(CFLAGS) -I../include
LDFLAGS=-lm

# list of generated object files.
IOTOOLS = $(TPATH)/pio.o $(TPATH)/helper.o $(TPATH)/sparse.o

#
TARGETS = check_input

# top-level rule, to compile everything.
all: $(TARGETS)

# odf ->
check_input: check_input.o $(IOTOOLS) 
	$(LD) $(LDFLAGS) $(IOTOOLS) $@.o -o $@

install:
	mv $(TARGETS) ../bin

%.o: %.c 
	$(CC) $(MYCFLAGS) -c $< -o $@
