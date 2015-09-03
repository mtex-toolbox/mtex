function omega = angle(o1,o2,varargin)
% calculates rotational angle between orientations
%
% Syntax  
%   omega = angle(o)
%   omega = angle(o1,o2)
%
% Input
%  o1, o2 - @orientation
% 
% Output
%  o1 x o2 - angle (double)

if nargin == 1
  
  % do not care about inversion
  q = quaternion(o1);
  
  % for misorientations we do not have to consider all symmetries
  [l,d,r] = factor(o1.CS,o1.SS);
  dr = d * r;
  qs = l * dr;
  
  % may be we can skip something
  minAngle = reshape(abs(qs.angle),[],1);
  minAngle = min([inf;minAngle(minAngle > 1e-3)]);
  omega = 2 * real(acos(q.a));
  notInside = omega > minAngle/2;
  
  % compute all distances to the symmetric equivalent orientations
  % and take the minimum
  omega(notInside) = 2 * real(acos(max(abs(dot_outer(q.subSet(notInside),inv(qs))),[],2)));
  
else
  
  omega = real(2*acos(dot(o1,o2,varargin{:})));
  
end
