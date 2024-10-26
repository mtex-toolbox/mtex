function [grains, rot] = rotate2Plane(grains)
% rotate grains to xy plane

if angle(grains.N, zvector,'antipodal') == 0
  rot = rotation.id;
else
  rot = rotation.map(grains.N, zvector);
  grains = rot .* grains;
end

end