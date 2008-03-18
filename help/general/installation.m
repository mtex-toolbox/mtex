%% MTEX Installation Guide
%
% 
%% Source
% 
% The source code of the MTEX toolbox is available at:
% <http://code.google.com/p/mtex/>
% 
%% Linux /  BSD
%
% For running the MTEX toolbox a Linux or BSD operating system is
% required. Recommended distributions are <http://www.ubuntu.com Ubuntu>,
% <http://debian.org Debian> and <http://opensuse.org SuSe>.
%
%% MAC 
%
% The MTEX toolbox has been succesfully tested running under MAC OSX (Intel as well as 
% PowerPC). When compiling the NFFT uder MAX OSX there is an isue with 
% linking static libraries. However, this effects only the files contained 
% in the applications directory of the NFFT. You might want to exclude them
% from compiling since they are not needed for MTEX.

%% Compiler
%
% In order to install the MTEX toolbox you will have to compile
% it. Therefore you need the standard C compiler <http://gnu.gcc.org gcc>
% and the *make* utility. Both components can be easily installed using
% your favorite package manager.
%
%% MATLAB 
%
% Since MTEX is a MATLAB toolbox <http://www.mathworks.com MATLAB> 
% has to be installed in order to use MTEX. So far the MTEX toolbox 
% has been test with MATLAB versions 6 and higher.
%
%% FFTW 
%
% The FFTW is one of the most popular fast Fourier transform libraries.
% You can install using the package manager of your Linux distribution. 
% The package is called fftw3 or similar. You will also need to install 
% the header (developer) files. Alternatively you can download the latest 
% source directly from <http://www.fftw.org> and compile it on your computer.
%
%% NFFT 
% 
% The NFFT is a C library for non equispaced fast Fourier transforms 
% including Fourier transforms on the sphere. It can be downloaded at 
% <http://www-user.tu-chemnitz.de/~potts/nfft> and has to be installed by 
% the following steps:
%
% * |cd nfft_download_directory|
% * |./configure --prefix=nfft_install_directory|
% * |make|
% * |make install|
%
%% MTEX 
% 
% Finally you have to download the MTEX toolbox. 
% 
% * |cd mtex_download_directory|
% * edit the file [[matlab:edit([mtexDataPath '/../Makefile']),Makefile]] and specify the
% FFTW3 and the NFFT3 installation directories
% * |make|
% * |make install|
%
% the last command requires you to be |root| on the system. If you do not
% want to install the MTEX toolbox globally you can also replace the last
% command by
%
% * |make install_user|
%
% This command essentially extends the file |.bashrc| to set the
% environment variable |export MATLABPATH=MTEX_install_directory|. In some
% cases this might be fail and you will have to set the path your
% self. Alternatively, you can also manually add the
% MTEX_install_directory to the MATLAB search path using the menu
% |File/set Path|.
%
%% Checking Your Installation
%
% Before starting MATLAB you can check whether the C programs where
% compiled successfully by typing
%
% * |make check|
%
% After the next start of MATLAB you should either the message 

'MTEX toolbox loaded'

%%
% for a local installation or the message

'in order to start the MTEX toolbox type: startup_mtex'

%% 
% for a global installation. In this case you have to type in the command 

startup_mtex

%%
% and the MTEX toolbox is loaded. After the MTEX toolbox is loaded you
% can check your installation under MATLAB by typing 

check_mtex

%%
% You can also edit the file [[matlab:edit startup_mtex.m,startup_mtex.m]] to change the 
% configuration of you MTEX installation. 