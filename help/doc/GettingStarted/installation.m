%% Installation Guide
% Explains how to instal MTEX on you computer.
%
% 
%% Download
% 
% The MTEX toolbox is available for Windows, Linux and MAC-OSX at:
% <http://code.google.com/p/mtex/>
% 
%
%% MATLAB 
%
% Since MTEX is a MATLAB toolbox, <http://www.mathworks.com MATLAB> 
% has to be installed in order to use MTEX. So far the MTEX toolbox 
% has been tested with MATLAB versions 7.1 and higher. No additional addons
% or packages are necessary.
%
%
%% Installation
%
% In order to install MTEX proceed as follows
%
% * extract MTEX to an arbitrary folder
% * start MATLAB
% * navigate to the MTEX folder
% * type 'startup_mtex'
%
%
%% Installation for All Users
%
% If you are a system administrator and want to install MTEX such that it
% is available to all users of the computer, then 
%
% * copy the MTEX directory to MATLAB_directoty/toolbox/mtex
% * rename mtex/startup_root.m to mtex/startup.m overwritting the old
% file mtex/startup.m
% * move mtex/startup.m to MATLAB_directoty/toolbox/local
% * start MATLAB
%
%
%% Checking Your Installation
%
% After the next start of MATLAB you should see either the message 

'MTEX toolbox loaded'

%%
% or in the case of a All User Installation

'in order to start the MTEX toolbox type: startup_mtex'

%%
% After the MTEX toolbox is loaded you can check your installation by
% typing  

check_mtex

%% Configuration and Troubleshooting
%
% You can configure your MTEX installation by editting the file
% [[matlab:edit mtex_settings.m,mtex_settings.m]]. See 
% <configuration.html Configuration> for more details! This page contains
% also some workarounds for known problems.
%
% Don't hesitate to contact the <mtex_about.html authors> of MTEX if you
% have any problems.
%
%% Compile MTEX Your Self
%
% Compiling MTEX is only neccesary if the provided binaries does not run
% on your system (e.g. if you have a 64 bit system) or if you want to
% optimize them to you specific system. Compiling intstructions can be
% found <compilation.html here>.
%

