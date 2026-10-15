function S1G = delete(S1G,ind)
% delte points from S1Grid
%
% Input
%  S1G - @S1Grid
%  ind - indece of points to be deleted
%
% Output
%  G   - @S1Grid

S1G.points(ind) = [];
