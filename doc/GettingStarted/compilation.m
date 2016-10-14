%% Compiling MTEX
% Explains how to compile MTEX on Mac, Linux, and Windows systems. This
% should not be necessary in most cases.
%
%% Introduction
% MTEX is shipped with precompiled binaries for Mac OSX, Windows, and Linux, 32
% and 64-bits. However, if these binaries are for some reason not compatible
% with your system, you have to compile them by hand. Compiling MTEX is not
% that easy and you are encouraged to contact the author if you have any
% problem.
% 
%% Pre-requisites
% 
% *Compiler*
%
% In order to install the MTEX toolbox you will have to compile
% it. Therefore you need a standard C compiler <http://gnu.gcc.org gcc>
% and the *make* utility. You may also need the package named *build-essentials*. 
% Under Linux and MAC OSX all these components can be easily installed
% using  your favorite package manager. For Windows, we recommend the usage
% of MinGW and MSYS.
%
% *FFTW*
%
% The FFTW is one of the most popular fast Fourier transform libraries. For
% Linux and Mac OSX pre-compiled packages are available through your favorite
% package manager. The package is called fftw3 or similar. You will also
% need to install  the header (developer) files. Alternatively, you can
% download the latest source directly from <http://www.fftw.org> and
% compile it on your computer. For Windows, this is the only way to go.
% Download the source code and compile it using MinGW.
%
% *NFFT*
% 
% The NFFT is a C library for nonequispaced fast Fourier transforms 
% including Fourier transforms on the sphere. It can be downloaded at 
% <http://www-user.tu-chemnitz.de/~potts/nfft> and has to be installed by 
% the following steps:
%  
% * |cd nfft_download_directory|
% * |./configure --prefix=nfft_install_directory --enable-nfsft --enable-nfsoft --enable-fpt --enable-static|
% * |make|
% * |make install|
%
%% Compiling MTEX 
% 
% Now you can compile the MTEX toolbox. This is done by
% 
% * |cd mtex_download_directory|
% * edit the file [[matlab:edit([mtexDataPath '/../Makefile']),Makefile]] and specify the
% FFTW3 and the NFFT3 installation directories
% * |make|
%
%% Checking Your Installation
%
% Before starting MATLAB you can check whether the C programs were
% compiled successfully by typing
%
% * |make check|
%
% After the next start of MATLAB change to the MTEX path and enter
%
% * |startup_mtex|
%
%%
% This should startup the MTEX toolbox. You can check your installation
% under MATLAB by typing  

check_mtex
