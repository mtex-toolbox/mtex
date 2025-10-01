function id = findByLocation( grains, pos )
% select a grain by spatial coordinates
%
% Input
%  grains - @grain2d
%  pos    - @vector3d, [x(:) y(:)], or [x(:) y(:) z(:)]
%  
% Output
%  grains - list of grainIds
%
% Example
%  
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

% project to plane
V = xyz(grains.rot2Plane * grains.allV); V = V(:,1:2);

pos = xyz(grains.rot2Plane * vector3d(pos));
pos = pos(:,1:2);

% and search for the closest vertex
if size(pos,1) == 1
  dist = sum((V(iV,:) - pos(1:size(V,2))).^2,2);
  [~,ind] = min(dist);
  closestVertex = iV(ind);
else
  closestVertex = iV(bucketSearch(V(iV,:),pos));
end

% list of candidates
id = find(cellfun(@(x) any(ismember(closestVertex,x)), poly));
poly = poly(id);


% check whether pos is inside the candidates
inside = false(size(id));
for k=1:numel(poly)
  V_k = V(poly{k},:);
  for j=1:size(pos,1)
    inside(k) = inside(k) + inpolygon(pos(j,1),pos(j,2),V_k(:,1),V_k(:,2));
    %inside(k) = inside(k) | insidepoly(pos(j,1),pos(j,2),V_k(:,1),V_k(:,2));
  end
  inside(k)=any(inside(k),1);
end
id = id(inside);
