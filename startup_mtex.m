function startup_mtex
% initialize MTEX toolbox
% 
% This file contains some global settings
% to be set by the user. Please read carefully the predefined 
% settings and correct them if you experience troubles.


%% user defined global settings
%------------------------------------------------------------------------

%% available memory 
% change this value to specify the total amount of installed ram
% on your system in kilobytes
global mtex_memory;
mtex_memory = getmem;

%% default maximum iteration depth for calcODF
% change this value if you want to have another maximum iteration depth to
% be default
global mtex_maxiter;
mtex_maxiter = 11;

%% default global plotting options
global mtex_plot_options;
mtex_plot_options = {};
% mtex_plot_options = {'reduced'};

%% path for temporary files
global mtex_tmppath;
mtex_tmppath = tempdir;

%% log file
global mtex_logfile;
[status,host] = unix('hostname');
[status,user] = unix('whoami');
mtex_logfile = [mtex_tmppath,'output_',host(1:end-1),'_',user(1:end-1),'.log'];

%% degree character
% MTEX sometimes experences problems when printing the degree character
% reenter the degree character here in this case
global mtex_degree;
mtex_degree = '°';

%% debugging
% comment out to turn on debugging
global mtex_debug;
mtex_debug = 0;
%mtex_debug = 1;

%% commands to be executed before the external c program
global mtex_prefix_cmd;
mtex_prefix_cmd = '';

% Sometimes it makes sense to run nice in front to lower the priority of
% the calculations
%mtex_prefix_cmd = 'nice -n 19 ';
%
% Sometimes it is also usefull to have the job running in a seperate xterm.
%mtex_prefix_cmd = '/usr/X11R6/bin/xterm -iconic -e ';
% The specified option -iconic cause xterm to open in the background.
% The option -e is necassary to run a program in the terminal. 

%% commands to be executed after the external c program
% this might be usefull when redirecting the output or close brackets
global mtex_postfix_cmd;
mtex_postfix_cmd = '';


%% local machineformat
global mtex_machineformat;
mtex_machineformat = 'native';
% for power MAC try:
%mtex_machineformat = 's';


%% end user defined global settings
%--------------------------------------------------------------------------


%% mtex_path
global mtex_path;
mtex_path = fileparts(mfilename('fullpath'));

global mtex_data_path;
mtex_data_path = [mtex_path filesep 'data'];

global mtex_startup_dir;
mtex_startup_dir = pwd;

%% setup search path 
toadd = {'',...
  'qta','qta/interfaces','qta/interfaces/tools','qta/standardODFs','qta/tools',...
  'geometry','geometry/geometry_tools',...
  'tools','tools/dubna_tools','tools/file_tools','tools/option_tools',...
  'tools/import_wizard','tools/plot_tools','tools/statistic_tools',...
  'tools/misc_tools','tools/math_tools',...
  'examples','tests','help/interfaces'};

for i = 1:length(toadd)
  p = [mtex_path,filesep,toadd{i}];
  addpath(p,0);
end

disp('MTEX toolbox (v0.3) loaded')

function m = getmem
% return total system memory in kb

[r,s] = system('free');

m = sscanf(s(strfind(s,'Mem:')+5:end),'%d',1);
