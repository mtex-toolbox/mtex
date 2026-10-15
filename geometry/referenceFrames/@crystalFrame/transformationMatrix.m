function M = transformationMatrix(rf1,rf2)
% the transition matrix taking coordinates from frame rf1 to frame rf2
%
% On top of the pure frame transition this establishes the correspondence
% of the crystal axes first: when the axis lengths a, b, c of the two
% frames do not agree within 1%, the axes of rf1 are re-paired with those
% of rf2 by nearest length - this is how e.g. the monoclinic settings
% '121' and '112' relate.
%
% Syntax
%   M = transformationMatrix(rf1,rf2)
%
% Input
%  rf1, rf2 - @crystalFrame
%
% Output
%  M - 3x3 transformation matrix from rf1 to rf2
%
% See also
% referenceFrame/transformationMatrix referenceFrame/isCompatible

axes1 = double(normalize(rf1.basis)).';
axes2 = double(normalize(rf2.basis)).';

% maybe we need even to change the correspondence of the crystal axes
abc1 = norm(rf1.basis);
abc2 = norm(rf2.basis);

if ~all(abs(abc1-abc2)./sum(abc1)<0.01)

  % find best fit
  [~,i] = min(abs(abc1.' - abc2));

  axes1 = axes1(i,:);

end

M = axes2^-1 * axes1;

end

% code for checking functionality
% cs1 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||a*')
% cs2 = crystalSymmetry('triclinic',[1 2 3],[70 80 120]*degree,'Z||b','X||a*')
% m1 = Miller(1,2,3,cs)
% M*squeeze(double(m1))
% m2 = Miller(1,2,3,cs2)
% squeeze(double(m2))
