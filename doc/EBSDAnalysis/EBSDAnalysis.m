%% EBSD
% Data Import of Electron Backscatter Diffraction Data, Correct Data,
% Estimate Orientation Density Functions out of EBSD Data, Model Grains
% and Misorientation Density Functions
%
%%
% EBSD data is stored in the class <EBSD_index.html EBSD> while grains are
% stored as variables of type <grain2d_index.html grain2d>. The following
% mindmap may induce a general idea analysing EBSD Data with MTEX.
%
% <<grain.png>>
%
%% 
% *<GrainReconstruction.html Grains>*  are a basic concept for spatially indexed EBSD Data.
% With grain modelling comes up the possibility of getting more information out of the EBSD Data
% - e.g. fabric analysis, characterisation of misorientation
%
%%
% *<EBSDOrientationPlots.html Visualizing EBSD Data>* is a central part to understand
% the crystallographic orientation of a specimen. The most naive way to do this is by plotting the 
% individual orientations as poles in pole figures or spatially indexed points in some map with
% colorcoded orientations. Moreover one gets with grains the possibility to take a closer
% look on grain boundaries and depending on the case, even in the internal
% structure of the grains.
%
% *<EBSD2odf.html Estimating ODFs from EBSD Data>* is also interesting when
% one has large datasets with and the plotting of individual measurements produces
% crowded pole figures. Nevertheless the selection of the 
% optimal halfwidth for different dataset is a difficult question, in
% particular in matters of grains.
%
