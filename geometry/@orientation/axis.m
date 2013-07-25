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
  S = o1.CS;
else
  o = inverse(o1) .* (o2);
  S = disjoint(o1.CS,o2.CS);
end

% project to Fundamental region to get the axis with the smallest angle
o = project2FundamentalRegion(o);
a = axis(o);


if length(S) > 1
  a = Miller(a,S);
end
