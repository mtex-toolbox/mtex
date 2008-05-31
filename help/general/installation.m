%% MTEX Installation Guide
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
% Since MTEX is a MATLAB toolbox <http://www.mathworks.com MATLAB> 
% has to be installed in order to use MTEX. So far the MTEX toolbox 
% has been tested with MATLAB versions 7.1 and higher.
%
%
%% Personal Installation
%
% If you want to have a personal installation that is vissible only to
% you, then 
%
% * extract MTEX to an arbitrary folder
% * start MATLAB
% * navigate to the MTEX folder
% * type _startup_mtex__
%
%
%% Installation for All Users
%
% If you want to habe MTEX available to all users of the computer, then
%
% * extract MTEX to MATLAB_directoty/toolbox/mtex
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
%
%% Compiling MTEX Your Self
%
% Compiling MTEX is only neccesary if the provided binaries does not run
% on your system (e.g. if you have a 64 bit system) or if you want to
% optimize them to you specific system. Compiling intstructions can be
% found <compilation.html here>.