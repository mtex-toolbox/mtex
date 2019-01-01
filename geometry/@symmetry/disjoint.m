function s = disjoint(s1,s2)
% returns the disjoint of two symmetry groups

% both symmetries are equal -> nothing is to do
if s1 == s2, s = s1; return; end

% check for equal rotations
[is1,is2] = find(isappr(dot_outer(s1,s2),1,1e-4));

% the trivial cases 
if numel(is1) == 1, s = crystalSymmetry; return; end 
if numel(is1) == length(s1), s = s1; return; end
if numel(is2) == length(s2), s = s2; return; end

% take the equal ones
s = unique(s1.subSet(is1));

% find a symmetry that exactly contains s
for i=1:45 % check all Laue groups
  
  ss = crystalSymmetry('pointId',i);
  
  if length(ss) == length(s) && all(any(isappr(abs(dot_outer(rotation(s),ss)),1)))
    s = ss;
    return
  end
  
end

% otherwise define a custom symmetry
s = crystalSymmetry(s);

