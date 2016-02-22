function inside = checkInside(oR,q,varargin)
% check for points to be inside the orientation region
 
% avoid q beeing orientation
q = quaternion(q);

if isempty(oR.N), inside = true(size(q)); return; end
if isempty(q), inside = false(size(q)); return; end

% verify all conditions are satisfies
inside1 = dot_outer(oR.N,q)<1e-6;
inside2 = dot_outer(oR.N,q)>-1e-6;

% either q or -q needs to satisfy the condition
inside = reshape(all(inside1) | all(inside2),size(q));
 
end
 