function out = isAligned(gL1,gL2,tol)
% whether two layouts run their indices along the same directions
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

out = all(norm(gL1.basis - gL2.basis) ./ norm(gL1.basis) < tol);

end
