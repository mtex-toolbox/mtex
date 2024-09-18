function d = diameter(grains)
% diameter of a grain in measurement units
% longest distance between any two vertices of the grain boundary

poly = grains.poly;
d = zeros(size(grains));

if isscalar(grains) % compute in 3d

  % get the coordinates
  V = grains.allV.xyz;
  
  for ig = 1:length(grains)
  
    Vg = V(poly{ig},:);
    
    diffVg = reshape(Vg,[],1,3) - reshape(Vg,1,[],3);
    diffVg = sum(diffVg.^2,3);
  
    d(ig) = sqrt(max(diffVg(:)));
  end

else % 2d variant

  % get the coordinates
  scaling = 10000 ;
  V = grains.rot2Plane .* grains.allV;
  V = round(scaling * [V.x(:),V.y(:)]);

  for ig = 1:length(grains)
  
    Vg = V(poly{ig},:);
  
    % if it is a large Vertex-Set, reduce it to its convex hull
    if size(Vg,1) > 100, Vg = Vg(convhulln(Vg),:); end
  
    diffVg = reshape(Vg,[],1,2) - reshape(Vg,1,[],2);
    diffVg = sum(diffVg.^2,3);
  
    d(ig) = sqrt(max(diffVg(:)));
  end

  d = d./scaling;
end