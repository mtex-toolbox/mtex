function grains = Grain2d(grainSet,ebsd)
% constructor for a 2d-GrainSet
%
% *Grain2d* represents 2d grains. a *Grain2d* represents grains and grain
% boundaries spatially and topologically. It uses formally the class
% [[GrainSet.GrainSet.html,GrainSet]].
%
%% Input
% grainSet - @GrainSet
% ebsd - @EBSD
%
%% See also
% EBSD/calcGrains GrainSet/GrainSet Grain3d/Grain3d

grains = class(struct,'Grain2d',GrainSet(grainSet,ebsd));