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

V = grains.allV.xyz;
if size(V,2) == 3
  if length(pos)==2
    pos = [pos,0];
  end
  mat = grains.rot2Plane.matrix;
  V = (mat * V.').'; V = V(:,1:2);
  pos = (mat * pos.').'; pos = pos(:,1:2);  
end

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
  end
  inside(k)=any(inside(k),1);
end
id = id(inside);
