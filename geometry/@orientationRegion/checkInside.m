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
%  'tolerance' - tolerance at the region boundary (default: 1e-3)
%

% get tolerance
tol = 0.5*get_option(varargin,'tolerance',2e-3);

% avoid q beeing orientation
q = quaternion(q);

if isempty(oR.N), inside = true(size(q)); return; end
if isempty(q), inside = false(size(q)); return; end

% There used to be a branch here for a region without symmetry, taken when
% oR.CS1 == crystalSymmetry & oR.CS2 == crystalSymmetry & oR.antipodal. It
% cannot be taken: crystalSymmetry is a @phaseItem, which seals eq to plain
% handle identity, so a symmetry only ever equals itself and never the
% freshly built one this compared against. That has been so since
% crystalSymmetry became a phaseItem in b7e84a5ee, and the branch did not
% compute the same thing as the general case below - it dropped the
% condition on -q and reshape - so it is gone rather than repaired.

% verify all conditions are satisfies
d = dot_outer(oR.N,q);

% either q or -q needs to satisfy the condition
inside = reshape(all(d<=tol,1) | all(d>=-tol,1),size(q));
 
end
 