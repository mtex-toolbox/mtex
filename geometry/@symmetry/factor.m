function [l,d,r] = factor(s1,s2)
% factorizes s1 and s2 into l, d, r such that s1 = l * d and s2 = d * r
%
% Syntax
%   [l,d,r] = factor(s1,s2)
%
% Input
%  s1, s2  - @symmetry
%  l, r, d - @quaternion
%

% first trivial case - both symmetries are the same
if s1 == s2
  l = rotation.id;
  r = rotation.id;
  d = s1.rot;
  return
end

% step 1: compute disjoint d
d = s1.rot(any(isappr(dot_outer(s1.rot,s2.rot),1),2));

% second trivial case - disjoint is identity
if isscalar(d)
  l = s1.rot;
  r = s2.rot;
  return
end

% TODO: maybe this can be done faster!!!

% step 2: compute l
l = rotation.id;
c = any(isappr(dot_outer(l*d, s2.rot),1),1);
while ~all(c)
  l = [l; s2.rot(find(~c,1))]; %#ok<AGROW>
  c = any(isappr(dot_outer(l*d, s2.rot),1),1);
end

% step 3: compute r
r = rotation.id;
c = any(isappr(dot_outer(d*r,s1.rot),1),1);
while ~all(c)
  r = [r;s1.rot(find(~c,1))]; %#ok<AGROW>
  c = any(isappr(dot_outer(d*r, s1.rot),1),1);
end
