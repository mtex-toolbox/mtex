function vol = volume(grains, varargin)
% volume of a list of grains
%
% Input
%  grains - @grain3d
%
% Output
%  vol  - list of volumes (in measurement units^3)
%


if iscell(grains.poly)

  vol = zeros(size(grains.id));
  xyz = grains.boundary.allV.xyz;
  isC = iscell(grains.poly);

  for i = 1:length(grains.id)
    Cells_Faces = grains.I_CF(i,:);
    Polys = grains.poly(grains.boundary.id2ind(find(Cells_Faces)),:);
    
    % flip Polys, so normal direction pointing outwards
    Cells_Faces = nonzeros(Cells_Faces);
    if isC
      Polys(Cells_Faces == -1) = cellfun(@(c) fliplr(c), ...
        Polys(Cells_Faces == -1), 'UniformOutput', false);
    else
      Polys(Cells_Faces == -1,:) = fliplr(Polys(Cells_Faces == -1,:));
    end

    vol(i) = meshVolume(xyz, Polys);
  end

else

  V = grains.boundary.allV;

  isF = any(grains.I_CF,1);
  sgnVol = zeros(width(grains.I_CF),1);

  sgnVol(isF) = det(V(grains.poly(:,1)),V(grains.poly(:,2)),V(grains.poly(:,3)));

  vol = grains.I_CF * sgnVol / 6;

end
