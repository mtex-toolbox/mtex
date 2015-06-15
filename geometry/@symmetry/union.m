function u = union(s1,s2)
% returns the union of two symmetry groups

u  = s1 * s2;

u = unique(u(:));

% take the equal ones
s = quaternion(u);
s = unique(s,'antipodal');

% find a symmetry that exactly contains s
for i=1:45 % check all Laue groups
  
  ss = crystalSymmetry('pointId',i);
  
  if length(ss) == length(s) && all(any(isappr(abs(dot_outer(rotation(s),ss)),1)))
    u = ss;
    return
  end
  
end