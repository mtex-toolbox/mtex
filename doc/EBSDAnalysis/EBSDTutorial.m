%% Short EBSD Analysis Tutorial 
% How to detect grains in EBSD data and estimate an ODF.
%
%% Open in Editor
%  

%% Data import
%
% EBSD data may be imported by the import_wizard by typing

import_wizard

%%
% or by the command

fileName = [mtexDataPath filesep 'EBSD' filesep 'Forsterite.ctf'];
ebsd = loadEBSD(fileName)

%%
% A quick overview of the phases within your data set gives the plot

plot(ebsd)

%%
% MTEX supports a wide variety of EBSD file formats. Recommended are text-
% base file formats like |.ang| and |.ctf| over binary file formats like
% |.osc|. Special attention has to be paid to the alignment of sample
% reference frame X Y Z. Different vendors use different conventions. Even
% the reference frame for the Euler angles and for the spatial coordinates
% do not need to coincide. How to deal with this is discussed in a separate
% <ImportEBSDData.html section>.
%
%% Visualize EBSD data
%
% The alignment of the Euler reference frame can be verified by plotting
% pole figures and comparing them with the pole figures of the vendors
% system.

% we first need to extract the crystal symmetry of Forsterite 
csForsterite = ebsd('Forsterite').CS

% this plots the (001) pole figure of the Forsterite phase
plotPDF(ebsd('Forsterite').orientations,Miller(0,0,1,csForsterite))

% display Euler angle reference frame X, Y, Z
text([vector3d.X,vector3d.Y,vector3d.Z],{'X','Y','Z'},'backgroundColor','w')

%%
% 


plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'coordinates','on')





