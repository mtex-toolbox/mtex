function [mori,weights] = calcMisorientation(grains,varargin)
% calculate misorientation for any two neighbored measurments of the same
% phase
%
%% Input 
% grains - @GrainSet
%
%% Flags
% uncorrelated - the uncorrelated misorientation, i.e., independent of
% grain boundaries
% mis2mean - instead of neighbored measurments take the misorientation to
%   mean orientation of a grain.
%
%% Output
% m - @orientation, such that
%
%    $$m = (g{_i}^{--1}*CS^{--1}) * (CS *\circ g_j)$$
%
%   for two neighbored orientations $g_i, g_j$ with crystal @symmetry $CS$ of 
%   the same phase located on a grain boundary.
%
%% See also
% GrainSet/calcBoundaryMisorientation GrainSet/plotAngleDistribution


if check_option(varargin,'mis2mean')

  mori = get(grains.EBSD,'mis2mean');
  
elseif check_option(varargin,'uncorrelated')
  
  mori = calcMisorientation(grains.EBSD,varargin{:});
  
else
  
  mori = calcBoundaryMisorientation(grains,varargin{:});
  
end

% compute weights --> TODO
weights = ones(size(mori)) ./ numel(mori);
