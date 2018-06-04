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

qs1 = unique(quaternion(s1),'antipodal');
qs2 = unique(quaternion(s2),'antipodal');

% step 1: find common quaterions d
[is1,~] = find(isappr(abs(dot_outer(qs1,qs2)),1));

d = subSet(qs1,is1);

% step 2: compute l
l = quaternion.id;
c = any(isappr(abs(dot_outer(l*d,qs2)),1),1);
while ~all(c)
  l = [l;subSet(qs2,find(~c,1))]; %#ok<AGROW>
  c = any(isappr(abs(dot_outer(l*d,qs2)),1),1);
end

% step 3: compute r
r = quaternion.id;
c = any(isappr(abs(dot_outer(d*r,qs1)),1),1);
while ~all(c)
  r = [r;subSet(qs1,find(~c,1))]; %#ok<AGROW>
  c = any(isappr(abs(dot_outer(d*r,qs1)),1),1);
end
