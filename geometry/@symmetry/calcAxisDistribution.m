function x = calcAxisDistribution(cs,varargin)
% compute the axis distribution of an uniform ODF or MDF
%
% Input
%  cs - @crystalSymmetry
%  h  - @vector3d (optional)
%  
% Output
%  x   - values of the axis distribution
%  or
%  x   - spherical function
% See also

varargin = delete_option(varargin,'complete');
[oR,dcs,nSym] = fundamentalRegion(cs,varargin{:});

if nargin > 1 && isa(varargin{1},'vector3d')
    h = varargin{1}; 
    h = project2FundamentalRegion(h,dcs);
    omega = oR.maxAngle(h);
    x = nSym * (omega - sin(omega)) ./ pi;
else
    f = @(h) (oR.maxAngle(h) - sin(oR.maxAngle(h))) ./ pi * nSym ;
    x = S2FunHarmonicSym.quadrature(f,cs,varargin{:});
end
