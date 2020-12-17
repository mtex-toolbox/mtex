function mtex_settings
% initialize MTEX toolbox
%
% This file contains some global settings
% to be set by the user. Please read carefully the predefined
% settings and correct them if you experience troubles.


%% user defined global settings
%------------------------------------------------------------------------

% in order to make use of openMP parallelization
% set this option to "true"
setMTEXpref('openMP',false);

%% default global plotting options
% here you can define default plott options

% default fontsize
% the next lines try to set the fontsize depending on the screen resolution
ppi = get(0,'ScreenPixelsPerInch');
fontSize = round(15 * ppi/100);

% however, you can set the fontsize also to fixed value
%fontSize = 15;
setMTEXpref('FontSize',fontSize);
set(0,'DefaultAxesFontSize',fontSize);
set(0,'DefaultLegendFontSize',fontSize)

% default plotting of the coordinate axes
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','outOfPlane');

setMTEXpref('bAxisDirection','east');
setMTEXpref('aAxisDirection',''); % undefined

%setMTEXpref('bAxisDirection',''); % undefined
%setMTEXpref('aAxisDirection','east');

% default figure size, possible values are a factor between 0 and 1 or
% 'tiny', 'small', 'normal', 'large', 'huge'
setMTEXpref('figSize','large');

% whether to show or not to show a micronbar on EBSD maps
setMTEXpref('showMicronBar','on')

% whether to show or not to show a coordinates on EBSD maps
setMTEXpref('showCoordinates','off')

% how to annotate pole figure plots
% the following line add X and Y to the plot
% you may want to replace this by 'RD' and 'ND'
pfAnnotations = @(varargin) text([vector3d.X,vector3d.Y],{'X','Y'},...
  'BackgroundColor','w','tag','axesLabels',varargin{:});

% you can uncomment the following line to disable the annotations
%pfAnnotations = @(varargin) [];
setMTEXpref('pfAnnotations',pfAnnotations);

% default spacing between muliple plots
setMTEXpref('outerPlotSpacing',10);
% setMTEXpref('innerPlotSpacing',10);

% defaut marker size
% set the marker size depending on the fontSize
% but you can change this also to a fixed value
markerSize = 0.75*fontSize;
setMTEXpref('markerSize',markerSize);
set(0,'DefaultLineMarkerSize',markerSize);

% default annotation style
setMTEXpref('annotationStyle',...
  {'marker','s','MarkerEdgeColor','w','MarkerFaceColor','k','hitTest','off'});

% on some systems Matlab has problems displaying RGB maps with opengl. This
% tries to turn it off to overcome this problem. You might try to set this
% to false as this gives usually better graphics performance.
setMTEXpref('openglBug',false)

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

% set default colors
%set(0,'DefaultAxesColorOrder',vega20)

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
setMTEXpref('ExamplePath',   fullfile(mtex_path,'..','examples'));

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

% set default color pallte
setMTEXpref('colorPalette','CSS');

% colors for EBSD phase plotting
setMTEXpref('PhaseColorOrder',...
  {'LightSkyBlue',...
  'DarkSeaGreen',...
  'GoldenRod',...
  'LightCoral',...
  'DarkBlue',...
  'DarkGreen',...
  'DarkRed',...
  'DarkViolet',...
  'Gray',...
  'Thistle',... 
  'Aquamarine',...
  'MediumSeaGreen',...
  'LightSalmon',...
  'SteelBlue',...
  'MediumPurple',...
  'Moccasin',...
  'OliveDrab'});

%%

setMTEXpref('stopOnSymmetryMissmatch',true)
setMTEXpref('mtexMethodsAdvise',true)


%% MOSEK integration
% <https://www.mosek.com/ MOSEK> provides an alternative to the
% optimization toolbox

%MOSEKpath = '~/repo/mosek/9.0/toolbox/r2015aom';
%addpath(MOSEKpath);
setMTEXpref('mosek',false)

%% Use extern/insidepoly instead of matlab/inpolygon
% this should be faster

setMTEXpref('insidepoly',true)

%% Turn off Grain Selector
% turning off the grain selector allows faster plotting

% setMTEXpref('GrainSelector',false)

%% Workaround for LaTex bug
% change the following to "Tex" if you have problems with displaying LaTex
% symbols

% by default turn LaTeX on only on Windows or Mac
setMTEXpref('textInterpreter','LaTeX');

%% available memory
% change this value to specify the total amount of free ram
% on your system in kilobytes. By default this is set to 500 MB.

setMTEXpref('memory',500*1024);

%% FFT Accuracy
% change this value to have more accurate but slower computation when
% involving FFT algorithms
%
setMTEXpref('FFTAccuracy',1E-2);

setMTEXpref('maxBandwidth',512);

%% degree character
% MTEX sometimes experences problems when printing the degree character
% reenter the degree character here in this case

degree_char = native2unicode([194 176],'UTF-8');
%degree_char = '?';

setMTEXpref('degreeChar',degree_char);

%% compatibility issues
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
warning('off','MATLAB:divideByZero'); %#ok<RMWRN>


%% end user defined global settings
%--------------------------------------------------------------------------

end
