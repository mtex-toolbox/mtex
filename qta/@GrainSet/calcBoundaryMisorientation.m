function [m,weights] = calcBoundaryMisorientation(grains,varargin)
% calculate misorientation at grain boundaries
%
%% Input 
% grains - @GrainSet
%% Flags
% subboundary - only consider grain boundaries within a grain
% external - only consider grain boundaries closing a grain
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
% GrainSet/calcMisorientation GrainSet/plotAngleDistribution


checkSinglePhase(grains);

if check_option(varargin,{'sub','subboundary','internal','intern'})
  I_FD = grains.I_FDsub;
elseif  check_option(varargin,{'external','ext','extern'})
  I_FD = grains.I_FDext;
else % otherwise select all boundaries
  I_FD = grains.I_FDext | grains.I_FDsub;
end

[d,i] = find(I_FD(sum(I_FD,2) == 2,any(grains.I_DG,2))');

if numel(d) >0
  
  Dl = d(1:2:end);
  Dr = d(2:2:end);
  
  o = get(grains.EBSD,'orientations');
  m = o(Dl).\o(Dr);
  
else
  
  warning('selected phase does not contain any boundaries')
  m = orientation;
  
end


