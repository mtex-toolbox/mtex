function plotspatial( grains, varargin )
% overloads EBSD data of selected grains to the EBSD/plotspatial routine
%
%% Input
%  grains  - @Grain2d | @Grain3d
%
%% See also
% EBSD/plotspatial

plotspatial(grains.EBSD,varargin{:});