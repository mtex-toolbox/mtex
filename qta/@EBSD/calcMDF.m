function mdf = calcMDF(varargin)
% calculate misorientation distribution function
%
% Input 
%  ebsd   - @EBSD
%  grains - @GrainSet
%
% Output
%  mdf - @ODF MDF
%
% See also
%

% compute misorientations
[mori,weights] = calcMisorientation(varargin{:});

% perform kernel density estimation
mdf = calcODF(mori,'weight',weights,varargin{:});
