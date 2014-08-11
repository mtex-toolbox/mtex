function id = findByLocation( grains, pos )
% select a grain by spatial coordinates
%
% Input
%  grains - @GrainSet
%  xy     - list of [x(:) y(:)] coordinates, respectively [x(:) y(:) z(:)]
%
% Output
%  grains - @GrainSet
%
% Example
%  plotx2east
%  plot(grains)
%  p = ginput(1)
%  g = findByLocation(grains,p);
%  hold on, plotBoundary(g,'color','r','lineWidth',2)
%
% See also
% EBSD/findByLocation GrainSet/findByOrientation

% extract polygons with holes
isCell = cellfun('isclass',grains.poly,'cell');
poly = grains.poly;
poly(isCell) = cellfun(@(x) [x{:}] ,grains.poly(isCell),'UniformOutput',false);

% restrict vertices to available grains
iV = unique([poly{:}]);
% and search for the closest vertice
closestVertex = iV(bucketSearch(grains.V(iV,:),pos));

id = find(cellfun(@(x) any(x==closestVertex), poly));

% list of candidates - now without holes
poly = grains.poly(id);
isCell = cellfun('isclass',poly,'cell');  
poly(isCell) = cellfun(@(x) x{1} ,poly(isCell),'UniformOutput',false);

% check whether pos is inside the canditats
inside = false(size(id));
for k=1:numel(poly)
  V_k = grains.V(poly{k},:);
  inside(k) = inpolygon(pos(1),pos(2),V_k(:,1),V_k(:,2));
end
id = id(inside);

% maybe its inside of more then one grain - then take the smallest one
[~,ind] = min(area(grains.subSet(id)));
id = id(ind);
