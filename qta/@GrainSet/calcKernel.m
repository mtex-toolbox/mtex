function psi = calcKernel(grains,varargin)
% compute an optimal kernel function for ODF estimation (with mean orientation of
% grains)
%
% for options, please see [[EBSD.calcKernel.html, calcKernel]].
%
%% Input
%  grains - @GrainSet
%
%% Output
%  psi    - @kernel
%
%% See also
% EBSD/calcKernel EBSD/calcODF

% extract mean orientations
o = get(grains,'orientation');
  
% define weights
opt.weight = grainSize(grains);

% construct weighted ebsd object
ebsd = EBSD(o,'options',opt);
  
% compute kernel function
psi = calcKernel(ebsd,varargin{:});
