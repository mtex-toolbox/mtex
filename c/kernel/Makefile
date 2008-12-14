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
# please correct the following installation directories:
#
# path to FFTW, i.e. to lib/libfftw3.a
#FFTWPATH = /home/hielscher/c/
FFTWPATH ?= /usr/local
#
# path to the NFFT, i.e. to /lib/libnfft3.a
NFFTPATH ?= /home/hielscher/c
#NFFTPATH = /usr/local
#
#--------------- end editable section ---------------------------------
#
# local variables
BPATH = ../bin/$(TARGET)/
TPATH = ../tools
SOPATH = ../nsoft

CC=gcc
LD=gcc
RM = /bin/rm -f
LN = /bin/ln
CFLAGS = -o3 -c -Wall
MYCFLAGS=$(CFLAGS) -I$(FFTWPATH)/include -I$(NFFTPATH)/include/nfft -I../include
LDFLAGS=-lm #-lpthread

# list of static libraris
LIBS = $(NFFTPATH)/lib/libnfft3.a $(FFTWPATH)/lib/libfftw3.a #$(FFTWPATH)/lib/libfftw3_threads.a

# list of generated object files.
IOTOOLS = $(TPATH)/pio.o $(TPATH)/helper.o $(TPATH)/sparse.o
SOLVERTOOLS = zbfm.o zbfm_solver.o odf.o
SOOBJ = $(SOPATH)/wigner.o $(SOPATH)/nfsoft.o 

#
TARGETS = odf2pf pf2odf pf2pdf pdf2pf fc2odf odf2fc

# top-level rule, to compile everything.
all: $(TARGETS)

# odf -> pdf
odf2pf: odf2pf.o pdf.o $(IOTOOLS) 
	$(LD) $(LDFLAGS) $(IOTOOLS) pdf.o $(LIBS) $@.o -o $@

# pdf -> odf
pf2odf: pf2odf.o pdf.o $(IOTOOLS) $(SOLVERTOOLS)
	$(LD) $(LDFLAGS) $(IOTOOLS) pdf.o $(SOLVERTOOLS) $(LIBS) $@.o -o $@

# pdf -> Fourier coefficients
pf2pdf: pf2pdf.o $(IOTOOLS) pdf.o ipdf.o
	$(LD) $(LDFLAGS) $(IOTOOLS) pdf.o ipdf.o $(LIBS) $@.o -o $@

# Fourier coefficients -> pdf
pdf2pf: pdf2pf.o $(IOTOOLS) pdf.o 
	$(LD) $(LDFLAGS) $(IOTOOLS) pdf.o $(LIBS) $@.o -o $@

# Fourier coefficients - odf
fc2odf: fc2odf.o $(IOTOOLS) $(SOOBJ) 
	$(LD) $(LDFLAGS) $(IOTOOLS) $(SOOBJ) $(LIBS) $@.o -o $@

# odf -> Fourier coefficients
odf2fc: odf2fc.o $(IOTOOLS) $(SOOBJ)
	$(LD) $(LDFLAGS) $(IOTOOLS) $(SOOBJ) $(LIBS) $@.o -o $@

install:
	mv $(TARGETS) ../bin

%.o: %.c 
	$(CC) $(MYCFLAGS) -c $< -o $@
