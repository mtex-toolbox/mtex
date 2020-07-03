function s1 = disjoint(s1,s2)
% returns the disjoint of two symmetry groups

% both symmetries are equal -> nothing is to do
if s1 == s2
  if isa(s2,'specimenSymmetry'), s1 = s2; end    
  return
end

% check for equal rotations
[is1,is2] = find(isappr(dot_outer(s1.rot,s2.rot),1,1e-4));

% the trivial cases 
if numel(is1) == 1
  if isa(s1,'specimenSymmetry') || isa(s2,'specimenSymmetry')
    s1 = specimenSymmetry;
  else
    s1 = crystalSymmetry;
  end
  return; 
end
if numel(is1) == length(s1), return; end
if numel(is2) == length(s2), s1 = s2; return; end

% take the equal ones
rot = s1.rot(is1);

if isa(s1,'specimenSymmetry') || isa(s2,'specimenSymmetry')
  s1 = specimenSymmetry(rot);
else
  s1 = crystalSymmetry(rot);
end
