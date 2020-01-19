function s = union(s1,s2)
% returns the union of two symmetry groups
%
% 

rot = unique(s1.rot * s2.rot);

% find a symmetry that exactly contains s
for i=1:45 % check all Laue groups
  
  s = crystalSymmetry('pointId',i);
  
  if length(s.rot) == length(rot) && all(any(isappr(abs(dot_outer(rot,s.rot)),1)))   
    return
  end
  
end

s = crystalSymmetry(rot);