# Makefile of the MTEX toolbox
#
#--------------- begin editable section ------------------------------- 
#
# please correct the following installation directories:
#
# path to FFTW, i.e. to lib/libfftw3.a
#FFTWPATH = /home/hielscher/c/
FFTWPATH = /usr/local
#
# path to the NFFT, i.e. to /lib/libnfft3.a
NFFTPATH = /home/hielscher/c
#NFFTPATH = /usr/local
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
BPATH = c/bin/
SUBDIRS = c/kernel.dir c/nsoft.dir c/test.dir c/mex.dir 

# top-level rule, to compile everything.
all: $(SUBDIRS)

# descent into subdirectories
%.dir: 
	$(MAKE) -e CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" NFFTPATH=$(NFFTPATH) FFTWPATH=$(FFTWPATH) MATLABPATH=$(MATLABPATH) MEXFLAGS="$(MEXFLAGS)" -C $*
	$(MAKE) install -C $*

# rule for cleaning re-compilable files.
clean:
	rm -f c/bin/*
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
	c/bin/pf2odf c/test/pf2odf.txt check
# comment the next line out if you have a ibm power cpu
#	c/bin/pf2odf c/test/pf2odf_mac.txt check

uninstall: 
	rm -f $(MATLABPATH)/toolbox/local/startup.m
	rm -rf $(MATLABPATH)/toolbox/mtex

# rule for making release
RNAME = mtex-0.5-beta
release:
	rm -rf ../../$(RNAME)*
	cp -R ../trunk ../../$(RNAME)
	find ../../$(RNAME) -name .svn | xargs /bin/rm -rf
	find ../../$(RNAME) -name '*~' -or -name '*.log' -or -name '*.o' -or -name '*.orig' -or -name '.directory' | xargs /bin/rm -rf
	rm -f ../../$(RNAME)/c/bin/*
	rm -rf ../../$(RNAME)/help/html
#	mv ../../$(RNAME)/data ../../mtex_data
#
	cp -R ../../$(RNAME) ../../$(RNAME)-Linux
	cp -R ../../$(RNAME) ../../$(RNAME)-Windows
	cp -R ../../$(RNAME) ../../$(RNAME)-MACOSX
		
	cp -R ../../mtex-binaries/Linux ../../$(RNAME)-Linux
	cp -R ../../mtex-binaries/Windows ../../$(RNAME)-Windows
	cp -R ../../mtex-binaries/MACOSX ../../$(RNAME)-MACOSX

	
	tar -czf ../../$(RNAME)-Linux.tar.gz ../../$(RNAME)-Linux
	zip -rq  ../../$(RNAME)-Windows.zip ../../$(RNAME)-Windows
	tar -czf  ../../$(RNAME)-MACOSX.tar.gz ../../$(RNAME)-MACOSX	

windows-binaries:
	rm -r ../../mtex-win.tar.gz
	tar -czvf mtex-win.tar.gz ./c/bin/*.exe `find . -name '*.mexw32'`

linux-binaries:
	rm -r ../../mactex.tar.gz
	tar -czvf ../../mactex.tar.gz ./c/bin `find . -name '*.mexglx32'`

mac-binaries:
	rm -r ../../mtex-mac.tar.gz
	tar -czvf ../../mtex-mac.tar.gz ./c/bin `find . -name '*.mexmaci'`
