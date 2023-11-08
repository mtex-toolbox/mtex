function volume = volume(grains, varargin)

volume = zeros(size(grains.id));

for i = 1:length(grains.id)
  Cells_Faces = grains.I_CF(i,:);
  Polys = grains.poly(grains.boundary.id2ind(find(Cells_Faces)));
  % flip Polys, so normal direction pointing outwards
  Cells_Faces = nonzeros(Cells_Faces);
  Polys(Cells_Faces == -1) = cellfun(@(c) fliplr(c), Polys(Cells_Faces == ...
    -1), 'UniformOutput', false);

  volume(i) = meshVolume(grains.V.xyz, Polys);
end