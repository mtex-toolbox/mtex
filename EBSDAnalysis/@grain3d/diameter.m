function d = diameter(grains, varargin)
% diameter in µm
%
% Input
%  grains - @grain3d
%
% Output
%  d  - diameter
%

I_VG = grains.boundary.I_VG;
d = zeros(size(grains));

% get the coordinates
scaling = 10000;
V = round(scaling * grains.allV.xyz);

for ig = 1:length(grains)

  Vg = V(I_VG(:,grains.id(ig)),:);
  
  % if it is a large Vertex-Set, reduce it to its convex hull
  if size(Vg,1) > 100, Vg = Vg(convhulln(Vg),:); end
  
  diffVg = reshape(Vg,[],1,3) - reshape(Vg,1,[],3);
  diffVg = sum(diffVg.^2,3);
  
  d(ig) = sqrt(max(diffVg(:)));
end

d = d./scaling;

end