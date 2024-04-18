function v = volume(sF,center,radius,varargin)
% ratio of vector3d with a certain vector3d
%
% Description
% The function 'volume' returns the ratio of an vector3d that is close
% to an vector3d (center) by a tolerance (radius) to the volume of the 
% entire spherical function.
%
% Syntax
%   v = volume(sF,center,radius)
%
% Input
%  sF    - @S2Fun
%  center - @vector3d
%  radius - double
%
% Options
%  resolution - resolution of discretization
%
% See also
% S2Fun/sum S2Fun/mean

% TODO: direct computation for S2FunHarmonic

% get resolution
res = get_option(varargin,'resolution',min(0.1*degree,radius/200),'double');

% discretization
if nargin > 3 && isa(varargin{1},'vector3d')
  S2G = varargin{1};
else
  S2G = equispacedS2Grid('center',center,'maxTheta',radius,...
    'resolution',res,varargin{:});
end

% estimate volume portion of spherical function space
f = min(1,(1-cos(radius))/2);
  
% eval sF
if f == 0
  v = 0;
else
  v = mean(eval(sF,S2G)) * f;
end

end