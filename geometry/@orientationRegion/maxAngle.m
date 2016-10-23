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

  % ignore restrictions on the rotational axis
  %N = oR.N(oR.N.angle < pi<1e-3);
  N = oR.N;
  
  %TODO: we need to project v to the fundamental sector
  % 
  
  if isempty(N)
    omega = repmat(pi,size(varargin{1}));
  else
    d = dot_outer(-tan(N.angle/2) .* N.axis, normalize(varargin{1}));
    d = 2*acot(d);
    d(d<0) = pi;
    omega = min(d,[],1);
    omega = reshape(omega,size(varargin{1}));
    omega(omega<1e-4) = 0;
  end

elseif isempty(oR.V) || check_option(varargin,'complete')

  omega = pi;

else
  
  omega = max(angle(oR.V,'noSymmetry'));
  
end

