function inside = checkInside(oR,q,varargin)
% check for points to be inside the orientation region
 
% avoid q beeing orientation
q = quaternion(q);

if isempty(oR.N), inside = true(size(q)); return; end
if isempty(q), inside = false(size(q)); return; end

if oR.CS1 == crystalSymmetry & oR.CS2 == crystalSymmetry & oR.antipodal
  d = dot_outer(oR.N,q);
  inside = all(d>1e-3,1);
  return
end

% verify all conditions are satisfies
d = dot_outer(oR.N,q);

% either q or -q needs to satisfy the condition
inside = reshape(all(d<1e-3,1) | all(d>-1e-3,1),size(q));
 
end
 