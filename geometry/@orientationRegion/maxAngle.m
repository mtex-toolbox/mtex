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


if nargin>1 && isa(varargin{1},'vector3d')

  if isempty(oR.N)
  
    omega = repmat(pi,size(varargin{1}));
    
  else
    d = dot_outer(-tan(oR.N.angle/2) .* oR.N.axis,...
      normalize(varargin{1}));
    d = acot(d);
    d(d<0) = inf;
    omega = 2*min(d);
    omega = reshape(omega,size(varargin{1}));
    omega(omega<1e-4) = 0;
  end

elseif isempty(oR.V) || check_option(varargin,'complete')

  omega = pi;

else
  
  omega = max(oR.V.angle);
  
end

