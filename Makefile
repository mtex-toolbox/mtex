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
# path to FFTW, i.e. to lib/libfftw3.a
#FFTWPATH = /usr
FFTWPATH= /home/hielscher/coding/c
#
# path to the NFFT, i.e. to /lib/libnfft3.a
#NFFTPATH = /usr/local
NFFTPATH= /home/hielscher/coding/c

#
# matlab path
MATLABPATH = /opt/matlab
#
# compiler flags
CFLAGS= -c -O3 -Wall -fomit-frame-pointer -fstrict-aliasing -ffast-math -mfpmath=sse,387 -mieee-fp -m3dnow -mmmx -msse -msse2
LDFLAGS= -lm #-lpthread
MEXFLAGS= -compatibleArrayDims#-largeArrayDims
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
	$(MAKE) -e CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" NFFTPATH=$(NFFTPATH) FFTWPATH=$(FFTWPATH) MATLABPATH=$(MATLABPATH) MEXFLAGS="$(MEXFLAGS)" TARGET="$(TARGET)" -C $*
	$(MAKE) TARGET="$(TARGET)" install -C $*

# rule for cleaning re-compilable files.
clean:
	# rm -f c/bin/*
	find . -name '*~' -or -name '*.log' -or -name '.directory' -or -name '*.o' -or -name '*.mex*'| xargs /bin/rm -rf

# rule for installing as root
install:
	rm -rf $(MATLABPATH)/toolbox/mtex/*.*
	cp -f startup_root.m  $(MATLABPATH)/toolbox/local/startup.m
	mkdir -p $(MATLABPATH)/toolbox/mtex
	cp -rf * $(MATLABPATH)/toolbox/mtex/
	echo "installation complete"

# rule for checking installation
check:
	echo "check installation"
# comment the next line out if you have a intel/amd processor
	c/bin/$(target)/pf2odf c/test/pf2odf.txt check
# comment the next line out if you have a ibm power cpu
#	c/bin/$(target)/pf2odf c/test/pf2odf_mac.txt check

uninstall:
	rm -f $(MATLABPATH)/toolbox/local/startup.m
	rm -rf $(MATLABPATH)/toolbox/mtex

# rule for making release
RNAME = mtex-3.0beta1
RDIR = ../..
release:
	rm -rf $(RDIR)/$(RNAME)*
	cp -R . $(RDIR)/$(RNAME)
	chmod -R a+rX $(RDIR)/$(RNAME)
	find $(RDIR)/$(RNAME) -name .svn | xargs /bin/rm -rf
	find $(RDIR)/$(RNAME) -name '*~' -or -name '*.log' -or -name '*.o' -or -name '*.orig' -or -name '.directory' | xargs /bin/rm -rf
	rm -f $(RDIR)/$(RNAME)/c/nsoft/test_nfsoft_adjoint
	rm -rf $(RDIR)/$(RNAME)/help/html

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
