%% Mean Material Tensors
% how to calculate mean material tensors from ODF and EBSD data
%
%% Open in Editor
%
%% Abstract
% MTEX offers several ways to compute mean material tensors from ODFs or EBSD data.
%
%% Contents

%% Importing a Tensor from a File
% Lets start by importing an elasticity tensor:

fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

cs = symmetry('mmm',[4.7646 10.2296 5.9942]);

E = loadTensor(fname,cs,'name','elasticity','interface','generic')

%%
% and plot it using the seismic colormap

set_mtex_option('defaultColorMap',seismicColorMap);
plot(E,'complete')

%% Define a sample ODF
% Next consider a simple unimodal ODF 

odf = unimodalODF(rotation('Euler',45*degree,0,0),cs,symmetry);

plotpdf(odf,[Miller(1,0,0),Miller(0,0,1)])
colormap(WhiteJetColorMap)

%% Compute the mean tensor from an ODF
% Now we use this ODF to compute a mean tensor

Emean = calcTensor(odf,E)

%%
% and plot it

plot(Emean,'complete')

%% Compute the mean tensor from EBSD data
%

ebsd = simulateEBSD(odf,5000)

Emean = calcTensor(ebsd,E)

%%
% and plot it

plot(Emean,'complete')

%% 
set_mtex_option('defaultColorMap',WhiteJetColorMap);
