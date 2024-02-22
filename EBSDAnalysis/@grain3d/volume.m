function volume = volume(grains, varargin)

volume = zeros(size(grains.id));
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

  volume(i) = meshVolume(xyz, Polys);
end