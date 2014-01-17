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
TARGET ?= win32

LIBPATH = /local/lib
GMPINCPATH = /local/include
MPFRPATH = /local/mpfr-2.4.2

TPATH = ../tools
BPATH = ../bin/$(TARGET)/

CC=gcc
LD=gcc
RM = /bin/rm -f
LN = /bin/ln
CFLAGS = -std=c99 -o3 -c -Wall #-fopenmp
MYCFLAGS=$(CFLAGS) -I$(GMPINCPATH) -I$(MPFRPATH) -I../mhyper -I../include
LDFLAGS= -std=c99  -lm #-fopenmp
LIBS = $(LIBPATH)/libmpfr.a $(LIBPATH)/libgmp.a 
IOTOOLS = $(TPATH)/pio.o $(TPATH)/helper.o $(TPATH)/sparse.o
LIBEXT = dll

#
TARGETS = evalmhyper

# top-level rule, to compile everything.
all: $(TARGETS)

#mhyper: mhyper.o $(IOTOOLS)
#	$(LD)  -shared  $@.o $(IOTOOLS) $(LDFLAGS)  $(LIBS) -o  $@.$(LIBEXT) 

evalmhyper: mhyper.o evalmhyper.o  $(IOTOOLS)
	$(LD)  $(LDFLAGS) mhyper.o    $@.o  $(IOTOOLS)  $(LIBS)  -o $@

clean:
	rm *.o  mhyper.$(LIBEXT) evalmhyper
	
install:
	mv evalmhyper  $(BPATH)

%.o: %.c
	$(CC) $(MYCFLAGS) -c $< -o $@
