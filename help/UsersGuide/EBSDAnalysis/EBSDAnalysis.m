%% EBSD Data Analysis
% Data Import of Electron Backscatter Diffraction Data, Correct Data,
% Estimeate Orientation Density Functions out of EBSD Data, Model Grains
% and Misorientation Density Functions
%
%%
% EBSD Data is stored in the class <EBSD_index.html EBSD> and in the latter
% the class <grain_index.html grain> holds modelled grains.
% The following mindmap may induce an general idea analysing EBSD Data with
% MTEX.
%
% <<grain.png>>
%
%% 
% *<GrainModelling.html Grains>*  are a basic concept for spatially indexed EBSD Data.
% With grain modelling comes up the possebility getting more information out of EBSD Data
% - e.g. fabric analysis, characterisation of misorientation
%
%%
% *<EBSDPlot.html Visualizing EBSD Data>* is a central to understand
% a specimen. The most naive way is plotting of the individual orientations as 
% pole point plots or spatially indexed in some map with colorcoded orientations. 
% Moreover one gets with grains the possibility to take a closer look on grain
% boundaries.
%
% *<EBSD2odf.html Estimating ODFs from EBSD Data>* is as well of interest,
% furthermore selecting the optimal halfwidth is a difficult question, in
% particular in matters of grains.
%