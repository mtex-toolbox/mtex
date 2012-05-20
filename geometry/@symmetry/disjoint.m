function s = disjoint(s1,s2)
% returns the disjoint of two symmetry groups

% compare symmetry elements
is2 = any(isappr(dot_outer(s1,s2),1));

% take the equal ones
s2 = s2.rotation(is2);

% find a symmetry that exactly contains these

for i=1:11 % check all Laue groups
  
  s = symmetry(i);
  
  if numel(s2) == numel(s) && all(any(isappr(dot_outer(s,s2),1)))
    return
  end
  
end

s = symmetry;