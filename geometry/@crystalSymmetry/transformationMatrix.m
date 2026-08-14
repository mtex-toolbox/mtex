function M = transformationMatrix(cs1,cs2)
% compute the transformation matrix from cs1 to cs2
%
% Input
% cs1, cs2 - @crystalSymmetry
%
% Output
% M - transformation matrix cs1 to cs2
%
% See also
% crystalFrame/transformationMatrix

M = transformationMatrix(cs1.frame,cs2.frame);

end
