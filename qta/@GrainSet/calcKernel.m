function psi = calcKernel(grains,varargin)
% compute an optimal kernel function for ODF estimation (with mean orientation of
% grains)
%
% for options, please see [[EBSD.calcKernel.html, calcKernel]].
%
% Input
%  grains - @GrainSet
%
% Output
%  psi    - @kernel
%
% See also
% EBSD/calcKernel EBSD/calcODF

% compute kernel function
psi = calcKernel(grains.meanOrientation,'weights',grains.grainSize,varargin{:});
