function id = findByLocation( grains, pos )
% select a grain by spatial coordinates
%
% Input
%  grains - @grain2d
%  xy     - list of [x(:) y(:)] coordinates, respectively [x(:) y(:) z(:)]
%
% Output
%  grains - list of grainIds
%
% Example
%  plotx2east
%  plot(grains)
%  p = ginput(1)
%  id = findByLocation(grains,p);
%  hold on, plot(grains(id).boundary,'linecolor','r','lineWidth',2), hold off
%
% See also
% EBSD/findByLocation grain2d/findByOrientation

poly = grains.poly;

% restrict vertices to available grains
iV = unique([poly{:}]);

% and search for the closest vertice
closestVertex = iV(bucketSearch(grains.V(iV,:),pos));

% list of candidates
id = find(cellfun(@(x) any(ismember(closestVertex,x)), poly));
poly = poly(id);

% check whether pos is inside the candidates
inside = false(size(id));
for k=1:numel(poly)
  V_k = grains.V(poly{k},:);
  for j=1:size(pos,1)
    inside(k) = inside(k) + inpolygon(pos(j,1),pos(j,2),V_k(:,1),V_k(:,2));
  end
  inside(k)=any(inside(k),1);
end
id = id(inside);
