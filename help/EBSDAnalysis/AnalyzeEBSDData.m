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
ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'], ...
  'interface','generic', 'Bunge', ...
  'layout', [5 6 7], 'Phase', 2, 'xy', [3 4], ...
  'ColumnNames', { 'MAD' 'BC' } , 'ColumnIndex', [8 9]);
plot(ebsd)

%% Data Set
%
% Take a Closer look on the data set
%
get(ebsd,'phase')
%%
% So we have 3 Phases, where Phase 0 is a dummy for wrong indexing.
% Initialy every phase is loaded in one SOGrid, thus we get access to each
% phase with:
ebsd(2:3)
%%
% sometimes we want to know additional fields of the current ebsd data
options(ebsd)
%% 
% and plot them, e.g. Mean Angular Deviation (MAD) in degrees between 
% measured and calculated EBSD diffraction pattern 
plot(ebsd,'MAD')
%%
% Plot the Kikuchi Band Contrast 
plot(ebsd,'BC','colormap',hsv(256))
%%
% Now let us take a look on BC values
BC = get(ebsd,'BC');
mean(BC)
%%
% and show all values in the EBSD data in Bunge colorcoding, which are higher than mean
plot(ebsd(:,BC > mean(BC)),'Bunge','white')

%% Mean Orientation
%
% Next we are going to determine the mean orientation of each phase

m = mean(ebsd)

%%
% and plot mean of phase 2 within a pole figure plot und mark all 
% orientations closer than 12.5° to it.

close; 
plotpdf(ebsd(2),[Miller(1,0,0),Miller(0,0,1)],'reduced')
plot2all(m(2),'Marker','s','MarkerFaceColor','green')

e = subGrid(ebsd(2),m(2),12.5*degree);
hold on; 
plotpdf(e,[Miller(1,0,0),Miller(0,0,1)],'reduced','MarkerColor','r')

%%
% We can also plot these orientations are in the xy-plot
close; plot(e,'bunge','white')

%% Volume
%
% Lets next compute the volume close to the mean orientation.

volume(ebsd(2),m(2),10*degree)
