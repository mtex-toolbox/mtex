function inside = checkInside(oR,q,varargin)
% check for points to be inside the orientation region
% 
% Syntax
%   id = checkInside(oR,q)
%   id = checkInside(oR,q,'tolerance',3*degree)
%
% Input
%  oR - @orientationRegion
%  q - @quaternion
%
% Output
%  id - @logical
%
% Options
%  'tolerance' - tolerance on the Grain Boundary (1e-3)
%

% get tolerance
tol = get_option(varargin,'tolerance',1e-3);

% avoid q beeing orientation
q = quaternion(q);

if isempty(oR.N), inside = true(size(q)); return; end
if isempty(q), inside = false(size(q)); return; end

if oR.CS1 == crystalSymmetry & oR.CS2 == crystalSymmetry & oR.antipodal
  d = dot_outer(oR.N,q);
  inside = all(d>tol,1);
  return
end

% verify all conditions are satisfies
d = dot_outer(oR.N,q);

% either q or -q needs to satisfy the condition
inside = reshape(all(d<tol,1) | all(d>-tol,1),size(q));
 
end
 