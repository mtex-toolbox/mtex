function [rot1,d,rot2] = factor(s1,s2)
% factorizes s1 and s2 into rot1, d and rot2 such that 
% s1 = rot1 * d and s2 = d * rot2
%
% Syntax
%   [rot1,d,rot2] = factor(s1,s2)
%
% Input
%  s1, s2  - @symmetry
%
% Output
%  rot1, rot2, d - @rotation
%

% first trivial case - both symmetries are the same
if s1 == s2
  rot1 = rotation.id;
  rot2 = rotation.id;
  d = s1.rot;
  return
end

% step 1: compute disjoint d
d = s1.rot(any(isappr(dot_outer(s1.rot,s2.rot),1),2));

% second trivial case - disjoint is identity
if isscalar(d)
  rot1 = s1.rot;
  rot2 = s2.rot;
  return
end

% TODO: maybe this can be done faster!!!

% step 2: compute rot1 such that s1 = rot1 * d 
rot1 = rotation.id;
c = any(isappr(dot_outer(rot1*d,s1.rot),1),1);
while ~all(c)
  rot1 = [rot1;s1.rot(find(~c,1))]; %#ok<AGROW>
  c = any(isappr(dot_outer(rot1*d, s1.rot),1),1);
end

% step 3: compute rot2 such that s2 = d * rot2
rot2 = rotation.id;
c = any(isappr(dot_outer(d*rot2, s2.rot),1),1);
while ~all(c)
  rot2 = [rot2; s2.rot(find(~c,1))]; %#ok<AGROW>
  c = any(isappr(dot_outer(d*rot2, s2.rot),1),1);
end
