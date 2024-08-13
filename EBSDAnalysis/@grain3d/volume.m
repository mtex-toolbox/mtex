function vol = volume(grains, varargin)
% volume of a list of grains
%
% Input
%  grains - @grain3d
%
% Output
%  vol  - list of volumes (in measurement units^3)
%


if iscell(grains.F)

  vol = zeros(size(grains.id));
  xyz = grains.boundary.allV.xyz;

  [grainId,faceID,inOut] = find(grains.I_GF);
  for i = 1:length(grains.id)
        
    ind = grainId==i;

    Faces = grains.F(faceID(ind));
    
    % flip Faces, so normal direction pointing outwards
    Faces(inOut(ind) == -1) = cellfun(@(c) fliplr(c), ...
      Faces(inOut(ind) == -1), 'UniformOutput', false);

    vol(i) = meshVolume(xyz, Faces);
  end

else

  V = grains.boundary.allV;

  isF = any(grains.I_GF,1);
  sgnVol = zeros(width(grains.I_GF),1);

  sgnVol(isF) = det(V(grains.F(:,1)),V(grains.F(:,2)),V(grains.F(:,3)));

  vol = grains.I_GF * sgnVol / 6;

end
