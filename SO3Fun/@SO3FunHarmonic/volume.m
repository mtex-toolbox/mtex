function v = volume(SO3F,center,radius,varargin)
% Integrates an SO3Fun on the region of all orientations that are close to  
% a specified orientation (center) by a tolerance (radius), i.e.
%
% $$ \int_{\angle(R,c)<r} f(R) \, dR.$$
%
% Description
% The function 'volume' returns the ratio of the volume of an SO3Fun on the 
% region (of all orientations that are close to a specified orientation 
% (center) by a tolerance (radius)) to the volume of the entire rotational 
% function.
%
% Syntax
%   v = volume(odf,center,radius)
%   v = volume(odf,fibre,radius) % gives the volume with a fibre
%
% Input
%  odf    - @SO3Fun
%  center - @orientation
%  fibre  - @fibre
%  radius - double
%
% Options
%  resolution - resolution of discretization
%
% See also
% SO3Fun/volume SO3Fun/fibreVolume SO3Fun/entropy SO3Fun/textureindex

% TODO: antipodal is not considered up to now
if SO3F.antipodal
  warning(['The antipodal property is not considered up to now by the volume' ...
     ' computation of an SO3Fun.'])
end

if isa(center,'fibre')
  
  v = fibreVolume(SO3F,center.h,center.r,radius,varargin{:});  
  return
end

% In case of symmetries the computation of the volume by the chebychev 
% series only works for a small radius
cs = SO3F.CS;
ss = SO3F.SS;
if cs ~= crystalSymmetry
  minAngle = uniquetol(cs.rot.angle/2);
elseif ss ~= specimenSymmetry
  minAngle = uniquetol(cs.rot.angle/2);
else
  minAngle = pi;
end
minAngle = min(minAngle(minAngle>0.01));
if cs ~= crystalSymmetry && ss ~= specimenSymmetry || radius>minAngle
  v = volume@SO3Fun(SO3F,center,radius);
  return
end

% get an rotational function by symmetrizing
SO3Fs = SO3F; SO3Fs.fhat = 0;
N = SO3F.bandwidth;
SO3Fs.bandwidth = N;

% rotate SO3F such that center -> rotation.id
if center ~= rotation.id
  SO3F = rotate(SO3F,inv(center));
end
  
% set all Fourier coefficients f_hat(n,k,l)=0 for k ~= l and compute the
% mean in each Fourier matrix
p = 0;
for n=0:N
  ind = deg2dim(n)+1:2*n+2:deg2dim(n+1);
  p(n+1) = mean(SO3F.fhat(ind));
end
psi = SO3Kernel(real(p).'.*sqrt(2*(0:N)'+1));

if SO3F.antipodal
  radius = min(radius,90*degree);
end

% integrate by trapezoidal rule
len = 1000;
x = (0:len)/(len)*radius;
y = psi.eval(cos(x/2));
w = sin(x/2).^2*2/pi; %  weights
y = w.*y;
v = radius/len * (0.5*y(1)+sum(y(2:end-1))+0.5*y(end));

% Symmetry
if SO3F.antipodal
  v = 2*v;
end
v = numProper(cs)*numProper(ss)*v;

end
