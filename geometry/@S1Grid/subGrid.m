function [NG,ind] = subGrid(S1G,x,epsilon)
% epsilon - neighborhood of a point in the grid
%% Syntax
%  [NG,ind] = subGrid(S1G,midpoint,radius)
%
%% Input
%  S1G        - @S1Grid
%  midpoint   - double
%  radius     - double
%% Output
%  NG         - @S1Grid
%  ind        - int32

if nargin == 3
  ind = find(S1G,x,epsilon);
else
  ind = x;
end

for i = 1:length(S1G)
  S1G(i).points = reshape(S1G(i).points,1,[]);
end
NG = S1G;
id = cumsum([0,GridLength(NG)]);
points = [NG.points];
points = points(ind);

idx = cumsum(full([0;ind(:)]));
idx = idx(id+1);

for i = 1:length(NG)
  %NG(i).points = NG(i).points(ind(1+id(i):id(i+1)));
  NG(i).points = points(1+idx(i):idx(i+1));
end
