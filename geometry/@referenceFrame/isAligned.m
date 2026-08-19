function out = isAligned(rf1,rf2,tol)
% whether two frames have the same basis, i.e. no transition is needed
%
% This is the criterion phaseItem/eqTolPair and crystalSymmetry/eqLazy use
% today (not yet rerouted here - the default tolerance is theirs).
%
% Syntax
%   out = isAligned(rf1,rf2)
%   out = isAligned(rf1,rf2,tol)
%
% Input
%  rf1, rf2 - @referenceFrame
%  tol      - relative tolerance on the basis vectors, default 5e-2
%
% Output
%  out - logical
%
% See also
% referenceFrame/isCompatible referenceFrame/transformationMatrix

if nargin < 3, tol = referenceFrame.tolAligned; end

out = all(norm(rf1.basis - rf2.basis) ./ norm(rf1.basis) < tol);

end
