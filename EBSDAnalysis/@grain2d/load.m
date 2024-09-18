function [grains] = load(filepath)
  % grain2d.load is a method to load the 2d data from the tesselation files that
  % <neper.info/ neper> outputs
  %
  % Syntax
  %   grains = grain2d.load('filepath/filename.tess')
  %
  % Input
  %  fname     - filename
  %
  % Output
  %  grain2d - @grain2d
  %
  % See also
  % loadNeperTess grain3d.load

  [dimension, V, poly, ori, crysym, cell_ids] = loadNeperTess(filepath);

  if (dimension~=2)
    error 'Wrong dimension. Try grain2d.load instead.'
  end

  CSList = {'notIndexed',crystalSymmetry(crysym)};
  phaseList = 2*ones(size(poly));

  grains = grain2d(V, poly, ori, CSList, phaseList, 'id', cell_ids);

  % check for clockwise poly's
  isNeg = (grains.area<0);
  grains.poly(isNeg) = cellfun(@fliplr, grains.poly(isNeg), 'UniformOutput', false);

end
