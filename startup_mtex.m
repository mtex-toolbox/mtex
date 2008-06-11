function startup_mtex
% initialize MTEX toolbox
% 
% This file contains some global settings
% to be set by the user. Please read carefully the predefined 
% settings and correct them if you experience troubles.


%% user defined global settings
%------------------------------------------------------------------------

%% file extensions to be associated with MTEX
% add here your pole figure and EBSD data file extensions 
global mtex_ext_polefigures;
mtex_ext_polefigures = {'.exp','.XPa','.cns','.cnv', '.ptx','.pf','.xrdml'};
global mtex_ext_ebsd;
mtex_ext_ebsd = {'.ebsd'};

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
mtex_degree = native2unicode([194 176],'UTF-8');
%mtex_degree = '°';

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


%% compatibility issues
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');


%% needs installation ?
install_mtex(mtex_path);


%% setup search path 
toadd = {'',...
  'qta','qta/interfaces','qta/interfaces/tools',...
  'qta/interfacesEBSD','qta/interfacesEBSD/tools',...
  'qta/standardODFs','qta/tools',...
  'geometry','geometry/geometry_tools',...
  'tools','tools/dubna_tools','tools/file_tools','tools/option_tools',...
  'tools/import_wizard','tools/plot_tools','tools/statistic_tools',...
  'tools/misc_tools','tools/math_tools',...
  'examples','tests',...
  'help/interfaces','help/ODFCalculation','help/plotting','c/mex'};

for i = 1:length(toadd)
  p = [mtex_path,filesep,toadd{i}];
  addpath(p,0);
end


%% check installation
check_installation;


%% finish
disp('MTEX toolbox (v0.5) loaded')
disp(' ');
disp('Basic tasks:')
disp('- <a href="matlab:doc mtex">Show MTEX documentation</a>')
disp('- <a href="matlab:import_wizard_PoleFigure">Import pole figure data</a>')
disp('- <a href="matlab:import_wizard_EBSD">Import EBSD data</a>')
disp(' ');

end
%% --------- private functions ----------------------


%% mtext installation
function install_mtex(mtex_path)

% check wether mtex_path is in search path
if ispc
  cellpath = splitstr(path,';'); %regexp(path,';','split');
else
  cellpath = splitstr(path,':'); %regexp(path,':','split');
end

if any(strcmp(mtex_path,cellpath)), return;end


% if not yet installed
disp('MTEX is currently not installed.');

cd('..'); % leave current directory for some unknown reason
addpath(mtex_path);

r= input('Do you want to permanently install MTEX? Y/N [Y]','s');
if isempty(r) && any(strcmpi(r,{'Y',''}))

  disp(' ');
  disp('Adding MTEX to the MATLAB search path.');
  if isunix || ismac
    r = install_mtex_linux;
  else
    r = install_mtex_windows;
  end
  
  if r, disp('MTEX permanently added to MATLAB search path.');end
end
  

disp(' ');
disp('MTEX is now running. However MTEX documentation might not be functional.');
disp('In order to see the documentation restart MATLAB or click');
disp('start->Desktop Tools->View Source Files->Refresh Start Button');
disp(' ');
doc; pause(0.1);commandwindow;


end

%% windows
function out = install_mtex_windows
  
out = 0;
if ~savepath, out = 1;return;end

disp(' ');
disp('The MATLAB search path could not be saved!');
disp('Save the search path manually using the MATLAB menu File -> Set Path.');

end

%% Linux
function out = install_mtex_linux

global mtex_path

% try to save the normal way
if ~savepath, out = 1;return;end

% create startup_root
addpath([mtex_path,'/tools/file_tools'],0);
startup_file = file2cell([mtex_path '/startup_root.m']);
line = strmatch('addpath',startup_file);

startup_file{line} = ['addpath(''' mtex_path ''',0);'];
cell2file([mtex_path '/startup_tmp.m'],startup_file);

% copy startup_root
disp('I need root privelegs to add MTEX to the MATLAB search path.');
disp('Please enter the password!');

% is there sudo?
if exist('/usr/bin/sudo','file') 
  
  out = ~system(['sudo cp ' mtex_path '/startup_tmp.m ' toolboxdir('local') '/startup.m']);
  
else % use su
  
  out = ~system(['su -c cp ' mtex_path '/startup_tmp.m ' toolboxdir('local') '/startup.m']);
  
end

if ~out
  disp(' ');
  disp('The MATLAB search path could not be saved!');
  disp('In order to complete the installation you have two posibilities:');
  disp('1. Move the file "startup_root.m" to matlab_directory/toolbox/local');
  disp('   and rename it to "startup.m" --> global installation');
  disp('2. Define the mtex path as you MATLAB  path i.e. include into ".bashrc":')
  disp(['  export MATLABPATH="' mtex_path '"']);
end

end

%% get memory
function m = getmem
% return total system memory in kb

try
  m = memory;
  m = m.MemAvailableAllArrays / 1024;
catch %#ok<CTCH>
  [r,s] = system('free');
  m = sscanf(s(strfind(s,'Mem:')+5:end),'%d',1);
  if isempty(m)
    m = 300 * 1024;
  end
end
end

%%
function cstr = splitstr(str,c)

pos = [0,findstr(str,c),length(str)+1];
cstr = arrayfun(@(i) str(pos(i-1)+1:pos(i)-1),2:length(pos),'uniformoutput',0);
end