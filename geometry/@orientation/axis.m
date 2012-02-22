function a = axis(o)
% rotational axis of the orientation
%% Syntax
%  v = axis(o)
%
%% Input
%  o - @orientation
%
%% Output
%  v - @vector3d

o = project2FundamentalRegion(o);
a = axis(o.rotation);

S = disjoint(o.CS,o.SS);
if numel(S) > 1
  a = Miller(a,S);
end
