function [psi c] = calcKernel(grains,varargin)
% compute an optimal kernel function ODF estimation
%
%% Input
%  grains - @grain
%
%% Output
%  psi    - @kernel
%
%% Options
%  phase   - specifies the phase (default is the first one)
%
%% See also
% EBSD/calcODF

% extract mean orientations
[o ind] = get(grains,'orientation','CheckPhase',varargin{:});
  
% define weights
opt.weight = grainsize(grains(ind));

% construct weighted ebsd object
ebsd = EBSD(o,'options',opt);
  
% compute kernel function
[psi,c] = calcKernel(ebsd,varargin{:});
