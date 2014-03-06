%% List of Known Bugs
%
%
%%
% * ODF/hist and PoleFigure/hist do not show negative values
%
%% Open Issues
% On some Windows machines running MTEX distributed mex-files with Matlab 64bit
% may fail due to different Microsoft Visual C++ Redistributable packages.
% Matlab does not offer a Compiler on its own on Windows 64bit machines, please
% see 
%
% http://www.mathworks.com/support/compilers/R2010b/win64.html
%
% for more information on this topic. MTEX does not provide Microsoft Visual C++
% Redistributable packages. If you are running Windows Vista or Windows 7, you
% can compile these mex-files on your own by installing the Windows SDK. The SDK
% comes along with VC++ Compilers. Visit the Windows SDK Archive 
%
% http://msdn.microsoft.com/de-de/windows/ff851942.aspx 
%
% then download and install the SDK according to your operating system. Setup
% mex compiler by
% 
%   mex -setup
% 
% and choose one of the available compilers.

