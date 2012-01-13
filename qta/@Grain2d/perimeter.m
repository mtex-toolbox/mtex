function  peri = perimeter(grains)
% calculates the perimeter of the grain-polygon, with Holes
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  peri    - perimeter
%
%% See also
% polygon/equivalentperimeter polygon/borderlength


V = full(get(grains,'V'));
F = full(get(grains,'F'));

I_FDext = get(grains,'I_FDext');
I_DG = get(grains,'I_DG');


[f,g] = find(I_FDext*double(I_DG(:,any(I_DG))));

l = F(f,:);
edgeLength = sqrt(sum((V(l(:,1),:) - V(l(:,2),:)).^2,2));

peri = full(sparse(g,1,edgeLength));




