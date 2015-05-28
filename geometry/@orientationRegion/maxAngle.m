function  omega = maxAngle(oR,varargin)
% get the maximum angle of the fundamental region
%
% Syntax
%   omega = maxAngle(oR)   % maximum angle in the orientation region
%   omega = maxAngle(oR,v) % maximum angle about axis v 
%
% Input
%  oR - @orientationRegion
%  v  - @vector3d
%

if isempty(oR.V) || check_option(varargin,'complete')
  omega = pi;
elseif nargin>1 && isa(varargin{1},'vector3d')  
  omega = 2*min(abs(acot(dot_outer(tan(oR.N.angle/2) .* oR.N.axis,...
    normalize(varargin{1})))));
  omega = reshape(omega,size(varargin{1}));
else
  omega = max(oR.V.angle);
end

