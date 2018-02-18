function v = volume(sR,S2G)
% volume of a spherical region
%
%
% TODO: make this better!!
% formula: v = S - (n-2)*pi
% where S is the sum of the interior angles and n is the number of vertices

if nargin == 1, S2G = equispacedS2Grid(0.5*degree); end

v = nnz(sR.checkInside(S2G))/length(S2G);