function [ori,omega] = orientation(f,varargin)
% generate a list of orientation out of a fibre
%
% Syntax
%   ori = orientations(f,'points',1000)
%
% Input
%  f - @fibre
%
% Output
%  ori - @orientation
%
% Options
%  points - number of points that are generated
%

npoints = get_option(varargin,'points',1000);
omega = linspace(0,2*pi,npoints);

ori = rotation.id(npoints,length(f.h));

o1 = quaternion(f.o1);
o2 = quaternion(f.o2);
r = f.r;

for i = 1:length(f.h)
  
  maxOmega = angle(o1(i),o2(i));
  if maxOmega > 1e-3
    r(i) = axis(o2(i).*inv(o1(i)));
    omega = linspace(0,maxOmega,npoints);
  end
  
  % compute orientations
  ori(:,i) = rotation('axis',r(i),'angle',omega) .* o1(i);
  
end

if isa(f.CS,'crystalSymmetry') || isa(f.SS,'crystalSymmetry')
  ori = orientation(ori,f.CS,f.SS);
end

end