%% Alignment of the Crystal Axes
%
% Default is $\vec c$ axis of highest symmetry.
%
% TODO: Explain the default setting in more detail.
%
%% Switching between different Alignment Options
%
% Since, especialy for lower symmetry groups, different conventions for
% aligning the crystal axes are used it might be necessary to transform
% data, e.g, orientations or tensors, from one convention into another. 
% This can be done using the command <tensor.transformReferenceFrame.html
% transformReferenceFrame> as it illustrated below.
%
% First we import the stiffness tensor Forsterite with respect to the axes
% alignment

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivin');

% import some stiffness tensor
fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');
C = stiffnessTensor.load(fname,cs)

plot(C)

%%
% Let us now consider a different setup of the Forsterite symmetry, where
% the $\vec a$ axis is the longest and the $\vec c$-axis is the shortest.

cs_new = crystalSymmetry('mmm',[10.2296 5.9942 4.7646],'mineral','Olivin')

%%
% In order to represent the stiffness tensor |C| with respect to this
% setupt we use the command <tensor.transformReferenceFrame.html
% transformReferenceFrame>.

C_new = C.transformReferenceFrame(cs_new)

nextAxis
plot(C_new)
