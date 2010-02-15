%% Analyze EBSD Data 
%
%% Open in Editor
%
%% Abstract
% EBSD Data analysis is not yet complete in MTEX. However some main
% functionalities are already implement. First of all one can estimate an
% ODF from EBSD data. This is explained in detail in the section
% <EBSD2ODF_etimation.hmtl EBSD estimation from EBSD data>. Further
% posibilities are to compute volume fractions directly from EBSD data,
% compute the mean orientation and to estimate the Fourier coefficients.
%
%% Contents
%
%% Syntax
%
% Let us first import some EBSD data:
%

cs = { symmetry('cubic'), ...
       symmetry('cubic') };
ss = symmetry('triclinic');
ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],cs,ss,... 
                'interface','generic','Bunge',...
                 'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3'},...
                 'Columns', [2 3 4 5 6 7]);

plot(ebsd,'phase',1)

%% Mean Orientation
%
% Next we are going to determine the mean orientation of the first phase

m = mean(ebsd,'phase',1);

% and plot it within a pole figure plot

plotpdf(ebsd,[Miller(1,0,0),Miller(0,0,1)],'antipodal','phase',1)
annotate(m,'Marker','s','MarkerFaceColor','red')

%% Volume
%
% Lets next compute the volume close to the mean orientation.

volume(ebsd,m,10*degree,'phase',1)
