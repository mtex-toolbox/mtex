function c = centroid(grains)
% barycenters of the grains
% 
% Syntax
%
%   c = grains.centroid
%
% Input
%  grains - @grain2d
%
% Output
%  c - @vector3d
%
% See also
% grain2d/fitEllipse
%

if isempty(grains)
  c = vector3d;
  return
end

cs = [0; cumsum(cellfun('prodofsize',grains.poly))];

if isscalar(grains) % compute in 3d

  % duplicate vertices according to their occurrence in the grain2s
  V = grains.allV([grains.poly{:}]);

  % compute the relative area of the triangles between the edges an a
  % potential center (here (0,0,0) - but the center does not matter here)
  a = dot(cross(V(1:end-1),V(2:end)), grains.N,'noAntipodal');

  % weight the vertices according to the area
  aV = a .* (V(1:end-1)+V(2:end));

  % average the weighted vertices for each polygon (grain)
  c = vector3d.nan(length(grains),1);
  for k=1:length(c)
    ndx = cs(k)+1:cs(k+1)-1;
    c(k)  = sum(aV(ndx)) / 3 / sum(a(ndx));
  end

else % the same algorithm in 2d

  % get the coordinates
  rot = grains.rot2Plane;
  V = rot .* grains.allV;
  
  faceOrder = [grains.poly{:}];

  Vx = V.x(faceOrder);
  Vy = V.y(faceOrder);

  dF = (Vx(1:end-1).*Vy(2:end)-Vx(2:end).*Vy(1:end-1));
  cx = (Vx(1:end-1) +Vx(2:end)).*dF;
  cy = (Vy(1:end-1) +Vy(2:end)).*dF;

  x = nan(size(grains)); y = x;
  for k=1:numel(x)
    ndx = cs(k)+1:cs(k+1)-1;
    
    a = sum(dF(ndx));
    x(k) = sum(cx(ndx)) / 3 / a;
    y(k) = sum(cy(ndx)) / 3 / a;
  end

  c = inv(rot) .* vector3d(x,y,0);

end

end

% some test code
% mtexdata fo
% plot(ebsd)
% grains = calcGrains(ebsd)
% plot(grains(1806))
% c = centroid(grains(1806));
% hold on, plot(c.x,c.y,c.z,'o','color','b'); hold off
