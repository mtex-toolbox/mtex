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

% default plotting of the coordinate axes
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','outOfPlane');

% default figure size, possible values are a factor between 0 and 1 or
% 'tiny', 'small', 'normal', 'large', 'huge'
setMTEXpref('figSize','normal');

% default spacing between muliple plots
setMTEXpref('outerPlotSpacing',10);
setMTEXpref('innerPlotSpacing',10);

% default fontsize
setMTEXpref('FontSize',13);

% default annotation style
setMTEXpref('annotationStyle',...
  {'marker','s','MarkerEdgeColor','w','MarkerFaceColor','k','hitTest','off'});

%% Euler angle convention
% default Euler angle convention

setMTEXpref('EulerAngleConvention','Bunge');

%% file extensions to be associated with MTEX
% add here your pole figure and EBSD data file extensions

setMTEXpref('poleFigureExtensions',...
  {'.int','.cpf','.cor','.exp','.xpa','.xpe','.xpf','.axs','.uxd','.xrd','.ras','.asc',...
  '.cns','.cnv','.ana','.dat','.out','.ibm','.jul','.epf','.ppf','.pow',...
  '.xrdml','.gpf','.plf','.nja','.ptx','.rpf','.pwd','.slc'});

setMTEXpref('EBSDExtensions',...
  {'.ebsd','.ctf','.ang','.hkl','.tsl','.sor','.csv','.crc'});

%% Default save-mode for generated code snipped (import wizard)
% set to true if generated import-script should be stored on disk by
% default

setMTEXpref('SaveToFile',false)

%% Default Path to data files
% modify following pathes according to your needs, if your files are located at
% different path

setMTEXpref('CIFPath',       fullfile(mtexDataPath,'cif'));
setMTEXpref('EBSDPath',      fullfile(mtexDataPath,'EBSD'));
setMTEXpref('PoleFigurePath',fullfile(mtexDataPath,'PoleFigure'));
setMTEXpref('ODFPath',       fullfile(mtexDataPath,'ODF'));
setMTEXpref('TensorPath',    fullfile(mtexDataPath,'tensor'));

%% set default location to look for data with import wizard
% if not activated, the paths are selected according to the above

setMTEXpref('ImportWizardPath','workpath')
%setMTEXpref('ImportWizardPath',@cd)

%% Default ColorMap

% LaboTeX color map
%setMTEXpref('defaultColorMap',LaboTeXColorMap);

% white to black color map
% setMTEXpref('defaultColorMap','white2blackColorMap');

% jet colormap begin with white
setMTEXpref('defaultColorMap',WhiteJetColorMap);

% MATLAB default color map
% setMTEXpref('defaultColorMap','default');

%% EBSD Phase Colors

% colors for EBSD phase plotting
EBSDColorNames = {'light blue','light green','light red',...
  'cyan','magenta','yellow',...
  'blue','green','red',...
  'dark blue','dark green','dark red'};

EBSDColors = {[0.5 0.5 1],[0.5 1 0.5],[1 0.5 0.5],...
  [0 1 1],[1 0 1],[1 1 0],...
  [0 0 1],[0 1 0],[1 0 0],...
  [0 0 0.3],[0 0.3 0],[0.3 0 0]};

setMTEXpref('EBSDColorNames',EBSDColorNames);
setMTEXpref('EBSDColors',EBSDColors);


%% Default ColorMap for Phase Plots

% set blue red yellow green
cmap = [0 0 1; 1 0 0; 0 1 0; 1 1 0; 1 0 1; 0 1 1;...
  0.5 1 1; 1 0.5 1; 1 1 0.5;...
  0.5 0.5 1; 0.5 1 0.5; 1 0.5 0.5];
setMTEXpref('phaseColorMap',cmap);


%%

setMTEXpref('stopOnSymmetryMissmatch',true)
setMTEXpref('mtexMethodsAdvise',true)

%% Turn off Grain Selector
% turning off the grain selector allows faster plotting

% setMTEXpref('GrainSelector',false)

%% Workaround for LaTex bug
% change the following to "Tex" if you have problems with displaying LaTex
% symbols

% by default turn LaTeX on only on Windows or Mac
setMTEXpref('textInterpreter','LaTeX');

%% Workaround for NFFT bug
% comment out the following line if MTEX is compiled againsed NFFT 3.1.3 or
% earlier

% setMTEXpref('nfft_bug',false);
% setMTEXpref('nfft_bug',true);

%% architecture
% this is usefull if the arcitecture is not automatically recognized by
% MTEX

%setMTEXpref('architecture','maci64');

%% default maximum iteration depth for calcODF
% change this value if you want to have another maximum iteration depth to
% be default

setMTEXpref('ITER_MAX',11);

%% available memory
% change this value to specify the total amount of free ram
% on your system in kilobytes. By default this is set to 500 MB.

setMTEXpref('memory',500*1024);

%% FFT Accuracy
% change this value to have more accurate but slower computation when
% involving FFT algorithms
%
setMTEXpref('FFTAccuracy',1E-2);

%% path for temporary files

setMTEXpref('tempdir',tempdir);

%% degree character
% MTEX sometimes experences problems when printing the degree character
% reenter the degree character here in this case

degree_char = native2unicode([194 176],'UTF-8');
%degree_char = '?';

setMTEXpref('degreeChar',degree_char);

%%

setMTEXpref('TSPSolverPath',fullfile(mtex_path,'c','TSPSolver'))


%% debugging
% comment out to turn on debugging

setMTEXpref('debugMode',false);
%setMTEXpref('debugMode',true);


%% log file

[status,host] = unix('hostname');
[status,user] = unix('whoami');
host = host(isletter(host));

if ispc,  user = regexprep(user,{host(1:end-1), filesep},''); end
setMTEXpref('logfile',[getMTEXpref('tempdir'),'output_',host(isletter(host)),'_',user(isletter(user)),'.log']);


%% commands to be executed before the external c program

setMTEXpref('prefix_cmd','');

% --- setting the priorty -----------------------
% Sometimes it makes sense to run nice in front to lower the priority of
% the calculations

% on linux machines
%setMTEXpref('prefix_cmd','nice -n 19 ');

% on windows machines
%setMTEXpref('prefix_cmd','start /low /b /wait ');
% 'start' runs any programm on windows, the option /low sets the process priorty,
% option /b disables the console window, and the option /wait is required
% that matlab waits until calculations are done

% --- open in external window -------------------
% Sometimes it is also usefull to have the job running in a seperate console window.

% on linux machines
%setMTEXpref('prefix_cmd','/usr/X11R6/bin/xterm -iconic -e ');
% The specified option -iconic cause xterm to open in the background.
% The option -e is necassary to run a program in the terminal.

% on windows machines
%setMTEXpref('prefix_cmd','start /wait ');


%% commands to be executed after the external c program
% this might be usefull when redirecting the output or close brackets

setMTEXpref('postfix_cmd','');

%% compatibility issues
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
warning('off','MATLAB:divideByZero'); %#ok<RMWRN>


%% end user defined global settings
%--------------------------------------------------------------------------
