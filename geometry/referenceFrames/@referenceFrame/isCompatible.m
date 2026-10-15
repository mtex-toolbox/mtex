function [out,M] = isCompatible(rf1,rf2,tol)
% whether a transition between the two frames exists, and the transition
%
% Two frames are compatible when the transition between them is close to
% orthogonal, i.e. the same physical data can be re-expressed from one in
% the other. The lengths of the basis vectors do not enter - the transition
% is computed on normalized bases.
%
% Syntax
%   [out,M] = isCompatible(rf1,rf2)
%   [out,M] = isCompatible(rf1,rf2,tol)
%
% Input
%  rf1, rf2 - @referenceFrame
%  tol      - tolerance on the orthogonality defect of M, default 1e-1
%
% Output
%  out - logical
%  M   - 3x3 transformation matrix from rf1 to rf2
%
% See also
% referenceFrame/transformationMatrix referenceFrame/isAligned

if nargin < 3, tol = referenceFrame.tolCompatible; end

% dispatches to crystalFrame/transformationMatrix for crystal frames
M = transformationMatrix(rf1,rf2);

MM = M * M.';
out = norm(MM - eye(3)) / norm(MM) < tol;

end
