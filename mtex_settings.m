function mtex_settings
% initialize MTEX toolbox
% 
% This file contains some global settings
% to be set by the user. Please read carefully the predefined 
% settings and correct them if you experience troubles.


%% user defined global settings
%------------------------------------------------------------------------

%% architecture 
% this is usefull if the arcitecture is not automatically recognized by
% MTEX

%set_mtex_option('architecture','maci64');

%% file extensions to be associated with MTEX
% add here your pole figure and EBSD data file extensions 

set_mtex_option('polefigure_ext',...
  {'.exp','.XPa','.cns','.cnv', '.ptx','.pf','.xrdml','.xrd','.epf','.plf','.nja','.gpf','.ras'});
set_mtex_option('ebsd_ext',...
  {'.ebsd','.ctf','.ang','.hkl','.tsl'});

%% Path to CIF files
% modify this path if your CIF files are located at a different path
set_mtex_option('cif_path',fullfile(mtex_path,'cif'));

%% default maximum iteration depth for calcODF
% change this value if you want to have another maximum iteration depth to
% be default

set_mtex_option('ITER_MAX',11);

%% default global plotting options
% here you can define default plott options

default_plot_options = {'FontSize',13};
%default_plot_options = {'antipodal'};
set_mtex_option('default_plot_options',default_plot_options);
plotx2north;

%% available memory 
% change this value to specify the total amount of installed ram
% on your system in kilobytes

set_mtex_option('memory',getmem);

%% Turn of LaTex output
% comment out the following line if you have problems with displaying LaTex
% symbols

set_mtex_option('noLaTex');

%% FFT Accuracy 
% change this value to have more accurate but slower computation when
% involving FFT algorithms
%
set_mtex_option('FFTAccuracy',1E-2);

%% path for temporary files

set_mtex_option('tempdir',tempdir);

%% degree character
% MTEX sometimes experences problems when printing the degree character
% reenter the degree character here in this case

degree_char = native2unicode([194 176],'UTF-8');
%degree_char = '°';
set_mtex_option('degree_char',degree_char);

%% debugging
% comment out to turn on debugging

%set_mtex_option('debug_mode');


%% log file

[status,host] = unix('hostname');
[status,user] = unix('whoami');
set_mtex_option('logfile',[get_mtex_option('tempdir'),'output_',host(1:end-1),'_',user(1:end-1),'.log']);


%% commands to be executed before the external c program

set_mtex_option('prefix_cmd','');

% Sometimes it makes sense to run nice in front to lower the priority of
% the calculations
%set_mtex_option('prefix_cmd','nice -n 19 ');
%
% Sometimes it is also usefull to have the job running in a seperate xterm.
%set_mtex_option('prefix_cmd','/usr/X11R6/bin/xterm -iconic -e ');
% The specified option -iconic cause xterm to open in the background.
% The option -e is necassary to run a program in the terminal. 

%% commands to be executed after the external c program
% this might be usefull when redirecting the output or close brackets

set_mtex_option('postfix_cmd','');

%% compatibility issues
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
warning('off','MATLAB:divideByZero');


%% end user defined global settings
%--------------------------------------------------------------------------
