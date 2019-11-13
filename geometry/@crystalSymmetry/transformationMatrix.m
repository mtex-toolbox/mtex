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
%

axes1 = reshape(double(normalize(cs1.axes)),3,3);
axes2 = reshape(double(normalize(cs2.axes)),3,3);

% maybe we need even to change the correspondence of the crystal axes
abc1 = norm(cs1.axes);
abc2 = norm(cs2.axes);

if ~all(abs(abc1-abc2)./sum(abc1)<0.01)
  
  % find best fit 
  [~,i] = min(abs(bsxfun(@minus,abc1.',abc2)));

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
