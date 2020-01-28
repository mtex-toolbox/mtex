function [hklGrid,wGrid,id] = gridify(hkl,varargin)
% approximate a list of Miller indices with Miller indices on a grid
%
% Syntax
%   [hklGrid, weightsG, id] = gridify(vec)
%   [hklGrid, weightsG, id] = gridify(vec,'weights',weights)
%
% Input
%  vec - @vector3d
%
% Output
%  hklGrid - @Miller
%  weightsG - double
%  id    - 
%
% Options
%  weights    - 
%  resolution -

sR = hkl.CS.fundamentalSector;
hkl = project2FundamentalRegion(hkl);

[hklGrid,wGrid,id] = gridify@vector3d(hkl,sR,varargin{:});

hklGrid = Miller(hklGrid,hkl.CS);
