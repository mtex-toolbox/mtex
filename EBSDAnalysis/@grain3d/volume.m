function vol = volume(grains, varargin)
% volume of a list of grains
%
% Input
%  grains - @grain3d
%
% Output
%  vol  - list of volumes (in measurement units^3)
%

% volume of each grain via divergence theorem
vol = grains.I_GF * faceVolume(grains) / 6;
