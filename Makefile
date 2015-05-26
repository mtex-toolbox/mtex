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
TARGET= glnxa64
#
# please correct the following installation directories:
#
# path to FFTW, i.e. to libfftw3.a
FFTW_LIB_PATH = /usr/lib/x86_64-linux-gnu/
# path to FFTW header file, i.e., to fftw3.h
FFTW_H_PATH = /usr/include/
#
# path to NFFT, i.e. to libnfft3.a
NFFT_LIB_PATH = /usr/local/lib
# path the NFFT header file, i.e., to nfft.h
NFFT_H_PATH = /usr/local/include/
#
# matlab path
MATLABPATH = /opt/matlab
#
# compiler flags
CFLAGS= -c -O3 -Wall -fomit-frame-pointer -fstrict-aliasing -ffast-math -mfpmath=sse,387 -mieee-fp -m3dnow -mmmx -msse -msse2
LDFLAGS= -lm #-lpthread
# MEX flags
# for 32 bit systems set
#MEXFLAGS=-$(TARGET) -compatibleArrayDims
# for 64 bit systems set
MEXFLAGS=-$(TARGET) -largeArrayDims
#
#--------------- end editable section ---------------------------------
#
# local directories
BPATH = c/bin/$(TARGET)/
SUBDIRS = c/kernel.dir c/test.dir c/mex.dir


# top-level rule, to compile everything.
all: $(SUBDIRS)


# descent into subdirectories
%.dir:
	$(MAKE) -e CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" NFFT_LIB_PATH=$(NFFT_LIB_PATH) NFFT_H_PATH=$(NFFT_H_PATH) FFTW_LIB_PATH=$(FFTW_LIB_PATH) FFTW_H_PATH=$(FFTW_H_PATH) MATLABPATH=$(MATLABPATH) MEXFLAGS="$(MEXFLAGS)" TARGET="$(TARGET)" -C $*
	$(MAKE) TARGET="$(TARGET)" install -C $*


# rule for cleaning re-compilable files.
clean:
# rm -f c/bin/*
	find . -name '*~' -or -name '*.log' -or -name '.directory' -or -name '*.o' -or -name '*.mex*' | xargs /bin/rm -rf


# rule for making release
RNAME = mtex-4.0.23
RDIR = ../releases
release:
	rm -rf $(RDIR)/$(RNAME)*
	cp -R . $(RDIR)/$(RNAME)
	rm -rf $(RDIR)/$(RNAME)/help/tmp
	chmod -R a+rX $(RDIR)/$(RNAME)
	rm -rf $(RDIR)/$(RNAME)/.git
	rm -rf $(RDIR)/$(RNAME)/.git*
	find $(RDIR)/$(RNAME) -name '*~' -or -name '*.log' -or -name '*.o' -or -name '*.orig' -or -name '.directory' -or -name '*.mat' | xargs /bin/rm -rf
	rm -f $(RDIR)/$(RNAME)/c/nsoft/test_nfsoft_adjoint
	rm -rf $(RDIR)/$(RNAME)/help/html
	rm -rf $(RDIR)/$(RNAME).zip

	cd $(RDIR); zip -rq  $(RNAME).zip $(RNAME)

windows-binaries:
	rm -rf ../../mtex-win.tar.gz
	tar -czvf mtex-win.tar.gz ./c/bin/win32/*.exe `find . -name '*.mexw32'`

linux-binaries:
	rm -rf ../../mtex-linux.tar.gz
	tar -czvf ../../mtex-linux.tar.gz ./c/bin/glnx86/* `find . -name '*.mexglx'`

mac-binaries:
	rm -rf ../../mtex-mac.tar.gz
	tar -czvf ../../mtex-mac.tar.gz ./c/bin/maci/* `find . -name '*.mexmaci'`

mac64-binaries:
	rm -rf ../../mtex-mac64.tar.gz
	tar -czvf ../../mtex-mac64.tar.gz ./c/bin/maci64(* `find . -name '*.mexmaci'`
