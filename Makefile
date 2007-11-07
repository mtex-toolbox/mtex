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
#NFFTPATH = /home/staff/hielsch1/Arbeit/c
#
# matlab path (for root install only)
MATLABPATH = /opt/matlab-2006b
#
#--------------- end editable section ---------------------------------
#
# local variables
BPATH = $(PWD)/c/bin/
TPATH = $(PWD)/c/tools/
KPATH = $(PWD)/c/kernel/
SOPATH = $(PWD)/c/nsoft/

CC=gcc
LD=gcc
RM = /bin/rm -f
LN = /bin/ln
MYCFLAGS=$(CFLAGS) -g -c -Wall -I$(FFTWPATH)/include -I$(NFFTPATH)/include/nfft -I$(PWD)/c/include
LDFLAGS=-lm

# list of static libraris
LIBS = $(NFFTPATH)/lib/libnfft3.a $(FFTWPATH)/lib/libfftw3.a 

# list of generated object files.
TOOLS = $(TPATH)pio.o $(TPATH)helper.o $(TPATH)sparse.o
OBJS1 = $(KPATH)pdf.o $(KPATH)odf2pf.o
OBJS2 = $(KPATH)pdf.o $(KPATH)odf.o $(KPATH)zbfm.o $(KPATH)zbfm_solver.o $(KPATH)pf2odf.o
OBJS3 = $(KPATH)pdf.o $(KPATH)ipdf.o $(KPATH)pf2pdf.o
OBJS4 = $(KPATH)pdf.o $(KPATH)evalpdf.o
OBJS5 = $(TPATH)check_input.o
SOOBJ = $(SOPATH)wigner.o $(SOPATH)nfsoft.o 

# program executable file name.

PROG1 = $(BPATH)odf2pf        # odf -> pdf
PROG2 = $(BPATH)pf2odf        # pdf -> odf
PROG3 = $(BPATH)pf2pdf        # pdf -> Fourier coefficients
PROG4 = $(BPATH)evalpdf       # Fourier coefficients -> pdf
PROG5 = $(BPATH)check_input   # check_input
PROG6 = $(BPATH)odf2fc        # odf -> Fourier coefficients
PROG7 = $(BPATH)fc2odf        # Fourier coefficients - odf
PROG8 = $(BPATH)test_nfsoft_adjoint   # check nfsoft

# top-level rule, to compile everything.
all: $(PROG1) $(PROG2) $(PROG3) $(PROG4) $(PROG5) $(PROG6) $(PROG7) $(PROG8) 

$(PROG1): $(TOOLS) $(OBJS1) 
	$(LD) $(LDFLAGS) $(TOOLS) $(OBJS1) $(LIBS) -o $(PROG1)

$(PROG2): $(TOOLS) $(OBJS2)
	$(LD) $(LDFLAGS) $(TOOLS) $(OBJS2) $(LIBS) -o $(PROG2)

$(PROG3): $(TOOLS) $(OBJS3)
	$(LD) $(LDFLAGS) $(TOOLS) $(OBJS3) $(LIBS) -o $(PROG3)

$(PROG4): $(TOOLS) $(OBJS4)
	$(LD) $(LDFLAGS) $(TOOLS) $(OBJS4) $(LIBS) -o $(PROG4)

$(PROG5): $(TOOLS) $(OBJS5)	
	$(LD) $(LDFLAGS) $(TOOLS) $(OBJS5) $(LIBS) -o $(PROG5)

$(PROG6): $(TOOLS) $(SOOBJ) $(KPATH)odf2fc.o 
	$(LD) $(LDFLAGS) $(TOOLS) $(SOOBJ) $(KPATH)odf2fc.o $(LIBS) -o $(PROG6)

$(PROG7): $(TOOLS) $(SOOBJ) $(KPATH)fc2odf.o 	
	$(LD) $(LDFLAGS) $(TOOLS) $(SOOBJ) $(KPATH)fc2odf.o $(LIBS) -o $(PROG7)

$(PROG8): $(TOOLS) $(SOOBJ) $(SOPATH)test_nfsoft_adjoint.o
	$(LD) $(LDFLAGS) $(TOOLS) $(SOOBJ) $(SOPATH)test_nfsoft_adjoint.o $(LIBS) -o $(PROG8)

%.o: %.c 
	$(CC) $(MYCFLAGS) -c $< -o $@

# rule for cleaning re-compilable files.
clean:
	$(RM) $(TOOLS) $(PROG1) $(OBJS1) $(PROG2) $(OBJS2) $(PROG3) $(OBJS3)  $(OBJS4) $(PROG4) $(OBJS5) $(PROG5) $(SOOBJ) $(PROG6)
	$(RM) $(PWD)/qta/@PoleFigure/private/pf2odf $(PWD)/qta/@kernel/private/odf2pf
	find . -name '*~' -or -name '*.log' -or -name '.directory' -or -name '*.o'| xargs /bin/rm -rf

# rule for installing as user
install_user:
	export MATLABPATH=$(PWD)
	export
	echo "export MATLABPATH=$(PWD)" >> ~/.bashrc
	echo "installation complete"

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
RNAME = mtex-0.3
release:
	cp -R ../mtex ../$(RNAME)
	find ../$(RNAME) -name .svn | xargs /bin/rm -rf
	find ../$(RNAME) -name '*~' -or -name '*.log' -or -name '*.o' -or -name '.directory' | xargs /bin/rm -rf
	rm -f ../$(RNAME)/c/bin/*
	rm -rf ../$(RNAME)/help/html
#	mv ../$(RNAME)/data ../mtex_data
	tar -czf  ../$(RNAME).tar.gz ../$(RNAME)
#	tar -czf  ../mtex_data.tar.gz ../mtex_data

