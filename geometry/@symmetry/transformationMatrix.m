function M = transformationMatrix(cs1,cs2)
% compute the transformation matrix from cs1 to cs2
%
%% Input
% cs1, cs2 - @symmetry
%
%% Output
% M - transformation matrix cs1 to cs2
%
%% See also
%

axes1 = reshape(double(normalize(get(cs1,'axes'))),3,3);
axes2 = reshape(double(normalize(get(cs2,'axes'))),3,3);

M = axes2^-1 * axes1;


end

% code for checking functionality
% cs1 = symmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*')
% cs2 = symmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*')
% m1 = Miller(1,2,3,cs)
% M*squeeze(double(m1))
% m2 = Miller(1,2,3,cs2)
% squeeze(double(m2))
