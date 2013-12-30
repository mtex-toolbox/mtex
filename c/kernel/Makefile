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
# path to FFTW, i.e. to libfftw3.a
FFTW_LIB_PATH ?= /usr/lib/x86_64-linux-gnu/

# path to FFTW header file, i.e., to fftw3.h
FFTW_H_PATH ?= /usr/include/
#
# path to NFFT, i.e. to libnfft3.a
NFFT_LIB_PATH ?= /usr/local/lib
# path the NFFT header file, i.e., to nfft.h
NFFT_H_PATH ?= /usr/local/include/
#
#--------------- end editable section ---------------------------------
#
# local variables
BPATH = ../bin/$(TARGET)/
TPATH = ../tools

CC=gcc
LD=gcc
RM = /bin/rm -f
LN = /bin/ln
CFLAGS = -o3 -c -Wall
MYCFLAGS=$(CFLAGS) -I$(FFTW_H_PATH) -I$(NFFT_H_PATH) -I../include
LDFLAGS=-lm #-lpthread

# list of static libraris
LIBS = $(NFFT_LIB_PATH)/libnfft3.a $(FFTW_LIB_PATH)/libfftw3.a #$(FFTW_LIB_PATH)/libfftw3_threads.a

# list of generated object files.
IOTOOLS = $(TPATH)/pio.o $(TPATH)/helper.o $(TPATH)/sparse.o
SOLVERTOOLS = zbfm.o zbfm_solver.o odf.o

#
TARGETS = odf2pf pf2odf pdf2pf fc2odf odf2fc #pf2pdf

# top-level rule, to compile everything.
all: $(TARGETS)

# odf -> pdf
odf2pf: odf2pf.o pdf.o $(IOTOOLS)
	$(LD) $(IOTOOLS) pdf.o $(LIBS) $@.o -o $@ $(LDFLAGS)

# pdf -> odf
pf2odf: pf2odf.o pdf.o $(IOTOOLS) $(SOLVERTOOLS)
	$(LD) $(IOTOOLS) pdf.o $(SOLVERTOOLS) $(LIBS) $@.o -o $@ $(LDFLAGS)

# pdf -> Fourier coefficients
pf2pdf: pf2pdf.o $(IOTOOLS) pdf.o ipdf.o
	$(LD) $(IOTOOLS) pdf.o ipdf.o $(LIBS) $@.o -o $@ $(LDFLAGS)

# Fourier coefficients -> pdf
pdf2pf: pdf2pf.o $(IOTOOLS) pdf.o
	$(LD) $(IOTOOLS) pdf.o $(LIBS) $@.o -o $@ $(LDFLAGS)

# Fourier coefficients - odf
fc2odf: fc.o fc2odf.o $(IOTOOLS)
	$(LD) $(IOTOOLS) fc.o $@.o $(LIBS) -o $@ $(LDFLAGS)

# odf -> Fourier coefficients
odf2fc: fc.o odf2fc.o $(IOTOOLS)
	$(LD) $(IOTOOLS) fc.o $@.o $(LIBS) -o $@ $(LDFLAGS)

install:
	mv $(TARGETS) $(BPATH)

%.o: %.c
	$(CC) $(MYCFLAGS) -c $< -o $@
