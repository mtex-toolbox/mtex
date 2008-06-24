function mtex_settings
% initialize MTEX toolbox
% 
% This file contains some global settings
% to be set by the user. Please read carefully the predefined 
% settings and correct them if you experience troubles.

delete_mtex_option;

%% user defined global settings
%------------------------------------------------------------------------

%% file extensions to be associated with MTEX
% add here your pole figure and EBSD data file extensions 

set_mtex_option('polefigure_ext',...
  {'.exp','.XPa','.cns','.cnv', '.ptx','.pf','.xrdml'});
set_mtex_option('ebsd_ext',...
  {'.ebsd'});

%% default maximum iteration depth for calcODF
% change this value if you want to have another maximum iteration depth to
% be default

set_mtex_option('ITER_MAX',11);

%% default global plotting options
% here you can define default plott options

default_plot_options = {};
%default_plot_options = {'reduced'};
set_mtex_option('default_plot_options',default_plot_options);

%% available memory 
% change this value to specify the total amount of installed ram
% on your system in kilobytes

set_mtex_option('memory',getmem);

%% Turn of LaTex output
% comment out the following line if you have problems with displaying LaTex
% symbols

%set_mtex_option('noLaTex');

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


%% end user defined global settings
%--------------------------------------------------------------------------
