function G = delete(S1G,ind)
% delte points from S1Grid
%% Input
%  S1G - @S1Grid
%  ind - indece of points to be deleted
%
%% Output
%  G   - @S1Grid

G = S1G;
G.points(ind) = [];
