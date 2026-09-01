function s = pxStr(v)
% a displacement as a length and the signed x and y behind it, in pixels
%
% Syntax
%   s = pxStr([len x y])
%
% Input
%  v - [mean length, mean x, mean y] in pixels
%
% Output
%  s - '3.25 (-2.69,-1.81)', or '·' where nothing was measured
%
% Description
% The length is the size of the correction and the number the 2 px retry
% threshold is stated in; the pair is the mean of the same measurements taken
% signed, so it says which way the hop went. x runs along image columns and y
% along image rows - the axes of the resized grid, not the specimen ones.
%
% The two are not redundant. Where the per-ROI displacements agree the pair
% matches the length, and where they cancel to nearly zero against a large
% length they point in no common direction, which is what a failed
% correlation looks like.
%
% See also
% trueEbsd/calcDistortion trueEbsd/display

if isempty(v) || isnan(v(1))
  s = '·';
else
  s = sprintf('%.2f (%+.2f,%+.2f)',v(1),v(2),v(3));
end

end
