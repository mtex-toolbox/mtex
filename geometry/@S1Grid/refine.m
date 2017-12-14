function NG = refine(G)
% refine S1Grid
%
% Input
%  G - @S1Grid
% Output
%  G - @S1Grid with double the points
%

NG = G;

for i=1:length(G)
  d = dist(G(i),G(i).points([2:end,1]));
  np = reshape([G(i).points;...
    G(i).points+d/2],1,[]);
  ind = find(d > 2*min(d));
  np(2*ind) = [];
  NG(i).points = np;  
end
