function s1 = disjoint(s1,s2)
% returns the disjoint of two symmetry groups

% both symmetries are equal -> nothing is to do
if s1 == s2, return; end

% check for equal rotations
[is1,is2] = find(isappr(dot_outer(s1.rot,s2.rot),1,1e-4));

% the trivial cases 
if numel(is1) == 1, s1 = crystalSymmetry; return; end
if numel(is1) == length(s1), return; end
if numel(is2) == length(s2), s1 = s2; return; end

% take the equal ones
rot = s1.rot(is1);

% find a symmetry that exactly contains s
for i=1:45 % check all Laue groups
  
  s1 = crystalSymmetry('pointId',i);
  
  if length(rot) == length(s1.rot) && all(any(isappr(abs(dot_outer(s1.rot,rot)),1)))
    return
  end
  
end

% otherwise define a custom symmetry
s1 = crystalSymmetry(rot);
