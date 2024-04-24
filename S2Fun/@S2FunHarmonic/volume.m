function v = volume(sF,center,radius,varargin)
% Integrates an S2Fun on the region of all vector3d's that are close to a 
% specified vector3d (center) by a tolerance (radius), i.e.
%
% $$ \int_{\angle(g,c)<r} f(g) \, dg.$$
%
% Description
% The function 'volume' returns the ratio of the volume of an S2Fun on the 
% region (of all vector3d's that are close to a specified vector3d (center) 
% by a tolerance (radius)) to the volume of the entire spherical function.
%
% Note that if the S2Fun $f$ is 'antipodal' the volume in any center with
% radius 90° will return the mean value of the S2Fun, which is infact the 
% volume of the whole sphere.
%
% Syntax
%   v = volume(sF,center,radius)
%
% Input
%  sF    - @S2FunHarmonic
%  center - @vector3d
%  radius - double
%
% See also
% S2Fun/volume S2Fun/sum S2Fun/mean

% In case of symmetries the computation of the volume by the chebychev 
% series only works for a small radius
if isa(sF,'S2FunHarmonicSym')
  v = volume@S2Fun(sF,center,radius);
  return
end


% get an rotational function
[~,psi] = sF.symmetrise(center);

if sF.antipodal
  radius = min(radius,90*degree);
end

% integrate by trapezoidal rule
len = 1000;
x = (0:len)/(len)*radius;
y = psi.eval(cos(x));
w = sin(x)/2; %  weights
y = w.*y;
v = radius/len * (0.5*y(1)+sum(y(2:end-1))+0.5*y(end));

if sF.antipodal
  v = 2*v;
end

end
