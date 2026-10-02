function psi = calcKernel(v,varargin)
% compute an optimal kernel function for the density estimation of directions
%
% Syntax
%   psi = calcKernel(v)
%   psi = calcKernel(v,'method','conservative')
%   sF = calcDensity(v,'kernel',calcKernel(v))
%
% Input
%  v - @vector3d, @Miller
%
% Output
%  psi - @S2DeLaValleePoussinKernel
%
% Options
%  method  - |'UCV'| (default) or |'conservative'|, see <selectHalfwidth.html selectHalfwidth>
%  weights - weights of the directions
%
% See also
% selectHalfwidth vector3d/calcDensity orientation/calcKernel

hw = selectHalfwidth(v,get_option(varargin,'method','UCV'),varargin{:});
psi = S2DeLaValleePoussinKernel('halfwidth',hw);
