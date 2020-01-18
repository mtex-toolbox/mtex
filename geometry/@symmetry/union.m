function s = union(s1,s2)
% returns the union of two symmetry groups
%
% 

if ~isa(s2,'symmetry') && isa(s2,'quaternion')
  s2 = [s2,rotation.id];
end

s = unique(s1 * s2);

% find a symmetry that exactly contains s
for i=1:45 % check all Laue groups
  
  ss = crystalSymmetry('pointId',i);
  
  if length(ss) == length(s) && all(any(isappr(abs(dot_outer(s,ss)),1)))
    s = ss;
    return
  end
  
end