function a = axis(o1,o2)
% rotational axis of the orientation or misorientation
%
%% Syntax
%  v = axis(o)
%  v = axis(o1,o2)
%
%% Input
%  o - @orientation
%
%% Output
%  v - @vector3d

if nargin == 1
  o = o1;
else
  o = inverse(o1) .* (o2);
end

o = project2FundamentalRegion(o);
a = axis(o.rotation);

S = disjoint(o.CS,o.SS);
if numel(S) > 1
  a = Miller(a,S);
end
