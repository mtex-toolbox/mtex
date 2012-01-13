function psi = calcKernel(grains,varargin)
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
o = get(grains,'orientation');
  
% define weights
opt.weight = grainSize(grains);

% construct weighted ebsd object
ebsd = EBSD(o,'options',opt);
  
% compute kernel function
varargin = delete_option(varargin,'Phase');
psi = calcKernel(ebsd,varargin{:});
