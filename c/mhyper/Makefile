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


GMPPATH = /local
MPFRPATH = /local

CC=gcc
LD=gcc
RM = /bin/rm -f
LN = /bin/ln
CFLAGS = -std=c99 -o3 -c -Wall 
MYCFLAGS=$(CFLAGS) -I$(GMPPATH)/include -I$(MPFRPATH)/include
LDFLAGS= -std=c99  -lm  
LIBS = $(MPFRPATH)/lib/libmpfr.a $(GMPPATH)/lib/libgmp.a 

#
TARGETS = mhyper

# top-level rule, to compile everything.
all: $(TARGETS)

# odf -> pdf
mhyper: mhyper.o
	$(LD)  $@.o $(LDFLAGS)  $(LIBS) -o $@
	

%.o: %.c
	$(CC) $(MYCFLAGS) -c $< -o $@
