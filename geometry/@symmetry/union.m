function u = union(s1,s2)
% returns the union of two symmetry groups
%
% 

if ~isa(s2,'symmetry') && isa(s2,'quaternion')
  s2 = [s2,rotation.id];
end

u  = s1 * s2;

u = unique(u(:));

% take the equal ones
s1 = quaternion(u(~u.i));
s2 = quaternion(u(u.i));
s = [rotation(unique(s1,'antipodal'));-rotation(unique(s2,'antipodal'))];

% find a symmetry that exactly contains s
for i=1:45 % check all Laue groups
  
  ss = crystalSymmetry('pointId',i);
  
  if length(ss) == length(s) && all(any(isappr(abs(dot_outer(s,ss)),1)))
    u = ss;
    return
  end
  
end