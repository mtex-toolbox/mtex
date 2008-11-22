%% Analyze EBSD Data 
%
% EBSD Data analysis is not yet complete in MTEX. However some main
% functionalities are already implement. First of all one can estimate an
% ODF from EBSD data. This is explained in detail in the section
% <EBSD2ODF_etimation.hmtl EBSD estimation from EBSD data>. Further
% posibilities are to compute volume fractions directly from EBSD data,
% compute the mean orientation and to estimate the Fourier coefficients.
%
%% Syntax
%
% Let us first import some EBSD data:
%
ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],...
  symmetry('m-3m'),symmetry('-1'),...
  'layout', [5 6 7 2], 'xy', [3 4],'Bunge',  'phase', 1);
plot(ebsd)

%% Mean Orientation
%
% Next we are going to determine the mean orientation

m = mean(ebsd);

% and plot it within a pole figure plot

plotpdf(ebsd,[Miller(1,0,0),Miller(0,0,1)],'reduced')
plot2all(m,'Marker','s','MarkerFaceColor','red')

%% Volume
%
% Lets next compute the volume close to the mean orientation.

volume(ebsd,m,10*degree)
