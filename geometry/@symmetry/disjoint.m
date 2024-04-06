function s1 = disjoint(s1,s2)
% returns the disjoint of two symmetry groups

% first argument should be symmetry
if ~isa(s1,'symmetry'), [s1,s2] = deal(s2,s1); end

if ~isa(s2,'symmetry')
  
  rot2 = s2;
  
elseif s1 == s2
  % both symmetries are equal -> nothing is to do
  if isa(s2,'specimenSymmetry'), s1 = s2; end    
  return
else
  
  rot2 = s2.rot;
  
end

% check for equal rotations
[is1,is2] = find(isappr(dot_outer(s1.rot,rot2,'noSymmetry'),1,1e-4));

% the trivial cases 
if isscalar(is1)
  if isa(s1,'specimenSymmetry') || isa(s2,'specimenSymmetry')
    s1 = specimenSymmetry;
  else
    s1 = crystalSymmetry;
  end
  return; 
end
if numel(is1) == length(s1), return; end
if numel(is2) == length(s2) && isa(s2,'symmetry'), s1 = s2; return; end

% take the equal ones
rot = s1.rot(sort(is1));

if isa(s1,'specimenSymmetry') || isa(s2,'specimenSymmetry')
  s1 = specimenSymmetry(rot);
else
  s1 = crystalSymmetry(rot);
end
