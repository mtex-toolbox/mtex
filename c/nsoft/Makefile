# Makefile of the MTEX toolbox
#
#--------------- begin editable section ------------------------------- 
#
# please correct the following installation directories:
#
# path to FFTW, i.e. to lib/libfftw3.a
FFTWPATH = /home/hielscher/c/
#FFTWPATH = /usr
#
# path to the NFFT, i.e. to /lib/libnfft3.a
NFFTPATH = /home/hielscher/c
#NFFTPATH = /usr/local
#
#
#--------------- end editable section ---------------------------------
#
BPATH = ../bin
TPATH = ../tools

CC=gcc
LD=gcc
RM = /bin/rm -f
LN = /bin/ln
CFLAGS = -o3 -c -Wall
MYCFLAGS=$(CFLAGS) -I$(FFTWPATH)/include -I$(NFFTPATH)/include/nfft -I../include
LDFLAGS=-lm

# list of static libraris
LIBS = $(NFFTPATH)/lib/libnfft3.a $(FFTWPATH)/lib/libfftw3.a 

# list of generated object files.
OBJ =  wigner.o nfsoft.o 

# program executable file name.
PROG = test_nfsoft_adjoint   # check nfsoft

# top-level rule, to compile everything.
all: $(PROG)

$(PROG): $(OBJ) test_nfsoft_adjoint.o
	$(LD) $(LDFLAGS) $(OBJ) $(LIBS) $@.o -o $@

%.o: %.c 
	$(CC) $(MYCFLAGS) -c $< -o $@


install:
	mv $(PROG) $(BPATH)