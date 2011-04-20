function mtex_settings
% initialize MTEX toolbox
%
% This file contains some global settings
% to be set by the user. Please read carefully the predefined
% settings and correct them if you experience troubles.


%% user defined global settings
%------------------------------------------------------------------------

%% default global plotting options
% here you can define default plott options

default_plot_options = {'FontSize',13};
%default_plot_options = {'antipodal'};
set_mtex_option('default_plot_options',default_plot_options);
plotx2north;

%% Euler angle convention
% default Euler angle convention

set_mtex_option('EulerAngleConvention','Bunge');

%% file extensions to be associated with MTEX
% add here your pole figure and EBSD data file extensions

set_mtex_option('polefigure_ext',...
  {'.exp','.XPa','.cns','.cnv', '.ptx','.pf','.xrdml','.xrd','.epf','.plf','.nja','.gpf','.ras'});
set_mtex_option('ebsd_ext',...
  {'.ebsd','.ctf','.ang','.hkl','.tsl'});

%% Default save-mode for generated code snipped (import wizard)
% set to true if generated import-script should be stored on disk by
% default

set_mtex_option('SaveToFile',false)

%% Default Path to data files
% modify following pathes according to your needs, if your files are located at
% different path

set_mtex_option('CIFPath',       fullfile(mtexDataPath,'cif'));
set_mtex_option('EBSDPath',      fullfile(mtexDataPath,'EBSD'));
set_mtex_option('PoleFigurePath',fullfile(mtexDataPath,'PoleFigure'));
set_mtex_option('ODFPath',       fullfile(mtexDataPath,'odf'));
set_mtex_option('TensorPath',    fullfile(mtexDataPath,'tensor'));

%% set default location to look for data with import wizard
% if not activated, the paths are selected according to the above

% set_mtex_option('ImportWizardPath','workpath')
set_mtex_option('ImportWizardPath',@cd)

%% Default ColorMap

% LaboTeX color map
%set_mtex_option('defaultColorMap',LaboTeXColorMap);

% white to black color map
% set_mtex_option('defaultColorMap',grayColorMap);

% jet colormap begin with white
set_mtex_option('defaultColorMap',WhiteJetColorMap);

% MATLAB default color map
% set_mtex_option('defaultColorMap','default');

%% Default ColorMap for Phase Plots

% set blue red yellow green
cmap = [0 0 1; 1 0 0; 0 1 0; 1 1 0; 1 0 1; 0 1 1;...
  0.5 1 1; 1 0.5 1; 1 1 0.5;...
  0.5 0.5 1; 0.5 1 0.5; 1 0.5 0.5];
set_mtex_option('phaseColorMap',cmap);

%% Turn off Grain Selector
% turning off the grain selector allows faster plotting

% set_mtex_option('GrainSelector','off')

%% Workaround for LaTex bug
% comment out the following line if you have problems with displaying LaTex
% symbols

% set_mtex_option('noLaTex');

% by default turn LaTeX off on Linux
if ~ismac && ~ispc, set_mtex_option('noLaTex');end

%% Workaround for NFFT bug
% comment out the following line if MTEX is compiled againsed NFFT 3.1.3 or
% earlier

%set_mtex_option('nfft_bug');

%% architecture
% this is usefull if the arcitecture is not automatically recognized by
% MTEX

%set_mtex_option('architecture','maci64');

%% default maximum iteration depth for calcODF
% change this value if you want to have another maximum iteration depth to
% be default

set_mtex_option('ITER_MAX',11);

%% available memory
% change this value to specify the total amount of installed ram
% on your system in kilobytes

set_mtex_option('memory',getmem);

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
host = host(isletter(host));

if ispc,  user = regexprep(user,{host(1:end-1), filesep},''); end
set_mtex_option('logfile',[get_mtex_option('tempdir'),'output_',host(isletter(host)),'_',user(isletter(user)),'.log']);


%% commands to be executed before the external c program

set_mtex_option('prefix_cmd','');

% --- setting the priorty -----------------------
% Sometimes it makes sense to run nice in front to lower the priority of
% the calculations

% on linux machines
%set_mtex_option('prefix_cmd','nice -n 19 ');

% on windows machines
%set_mtex_option('prefix_cmd','start /low /b /wait ');
% 'start' runs any programm on windows, the option /low sets the process priorty,
% option /b disables the console window, and the option /wait is required
% that matlab waits until calculations are done

% --- open in external window -------------------
% Sometimes it is also usefull to have the job running in a seperate console window.

% on linux machines
%set_mtex_option('prefix_cmd','/usr/X11R6/bin/xterm -iconic -e ');
% The specified option -iconic cause xterm to open in the background.
% The option -e is necassary to run a program in the terminal.

% on windows machines
%set_mtex_option('prefix_cmd','start /wait ');


%% commands to be executed after the external c program
% this might be usefull when redirecting the output or close brackets

set_mtex_option('postfix_cmd','');

%% compatibility issues
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
warning('off','MATLAB:divideByZero');


%% end user defined global settings
%--------------------------------------------------------------------------
