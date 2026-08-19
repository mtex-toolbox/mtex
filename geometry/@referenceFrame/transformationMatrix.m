function M = transformationMatrix(rf1,rf2)
% the transition matrix taking coordinates from frame rf1 to frame rf2
%
% This is the pure frame transition - normalized bases, no axis
% re-pairing. crystalFrame overloads it with the crystal specific
% nearest-length axis correspondence heuristic.
%
% Syntax
%   M = transformationMatrix(rf1,rf2)
%
% Input
%  rf1, rf2 - @referenceFrame
%
% Output
%  M - 3x3 transformation matrix from rf1 to rf2
%
% See also
% crystalFrame/transformationMatrix referenceFrame/isCompatible

axes1 = double(normalize(rf1.basis)).';
axes2 = double(normalize(rf2.basis)).';

M = axes2^-1 * axes1;

end
