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
  isC = iscell(grains.F);

  for i = 1:length(grains.id)
    Grains_Faces = grains.I_GF(i,:);
    Faces = grains.F(grains.boundary.id2ind(find(Grains_Faces)),:);
    
    % flip Faces, so normal direction pointing outwards
    Grains_Faces = nonzeros(Grains_Faces);
    if isC
      Faces(Grains_Faces == -1) = cellfun(@(c) fliplr(c), ...
        Faces(Grains_Faces == -1), 'UniformOutput', false);
    else
      Faces(Grains_Faces == -1,:) = fliplr(Faces(Grains_Faces == -1,:));
    end

    vol(i) = meshVolume(xyz, Faces);
  end

else

  V = grains.boundary.allV;

  isF = any(grains.I_GF,1);
  sgnVol = zeros(width(grains.I_GF),1);

  sgnVol(isF) = det(V(grains.F(:,1)),V(grains.F(:,2)),V(grains.F(:,3)));

  vol = grains.I_GF * sgnVol / 6;

end
