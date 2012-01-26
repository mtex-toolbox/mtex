function [mo,weights] = calcMisorientation(grains,varargin)
% calculate misorientation for any two neighbored measurments of the same
% phase
%
%% Input 
% grains - @GrainSet
%% Flags
% withoutBoundary - do not consider neighborhoods over grain boundaries.
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


checkSinglePhase(grains);


mapping = any(grains.I_DG,2);
A_D = grains.A_D(mapping,mapping);

if check_option(varargin,{'withoutBoundary'})
  I_FD = grains.I_FDext | grains.I_FDsub;
  
  [d,i] = find(I_FD(sum(I_FD,2) == 2,any(grains.I_DG,2))');  
  A_D(sub2ind(size(A_D),d(1:2:end),d(2:2:end))) = 0;  
elseif check_option(varargin,'mis2mean')  
  mo = get(grains.EBSD,'mis2mean');
  return
end

o = get(grains.EBSD,'orientations');

[Dl,Dr] = find(A_D);

mo = o(Dl).\o(Dr);


