function out = isAligned(gL1,gL2,tol)
% whether two layouts run their indices along the same directions
%
% Two layouts in different frames are not aligned: their directions are
% stated in different spaces, so the components cannot be compared. A layout
% with no frame is the canonical one and compares against either.
%
% Syntax
%   out = isAligned(gL1,gL2)
%   out = isAligned(gL1,gL2,tol)
%
% Input
%  gL1, gL2 - @gridLayout
%  tol      - relative tolerance on the basis vectors, default 5e-2
%
% Output
%  out - logical
%
% See also
% gridLayout/layoutIndex referenceFrame/isAligned

if nargin < 3, tol = referenceFrame.tolAligned; end

% a frame free layout is the canonical one and unifies with anything, while
% two layouts in different frames state their directions in different spaces
fr1 = gL1.frame; fr2 = gL2.frame;
if ~isempty(fr1) && ~isempty(fr2) && fr1 ~= fr2, out = false; return; end

out = all(norm(gL1.basis - gL2.basis) ./ norm(gL1.basis) < tol);

end
