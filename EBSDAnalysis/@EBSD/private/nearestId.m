function id = nearestId(xyRef,xy)
% index of the nearest point in xyRef for every row of xy
%
% Syntax
%   id = nearestId(xyRef,xy)
%   near = nearestId(xyRef), id = near(xy)
%
% Input
%  xyRef - n × 2 reference points, at least 3 not on a line
%  xy    - m × 2 query points
%
% Output
%  id   - m × 1 indices into xyRef
%  near - function handle, for many queries against the same xyRef
%
% Description
% Uses knnsearch if the Statistics and Machine Learning Toolbox is
% available and a nearest neighbour scatteredInterpolant otherwise.

if license('test','Statistics_Toolbox') && exist('knnsearch','file')
  ns = createns(xyRef);
  id = @(xy) knnsearch(ns,xy);
else
  F = scatteredInterpolant(xyRef,(1:size(xyRef,1)).','nearest','nearest');
  id = @(xy) F(xy);
end
if nargin > 1, id = id(xy); end

end
