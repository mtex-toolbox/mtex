function x = calcAxisDistribution(cs,h,varargin)
% compute the axis distribution of an uniform ODF or MDF
%
% Input
%  oR - @orientationRegion
%  h  - @vector3d
%
% Output
%  x   - values of the axis distribution
%
% See also

varargin = delete_option(varargin,'complete');
[oR,dcs,nSym] = fundamentalRegion(cs,varargin{:});


h = project2FundamentalRegion(h,dcs);
omega = oR.maxAngle(h);


x = nSym * (omega - sin(omega)) ./ pi;
