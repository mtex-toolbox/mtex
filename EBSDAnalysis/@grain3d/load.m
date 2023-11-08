function [grains] = load(filepath)
  % grain3d.load is a method to load the 3d data from the tesselation files that
  % <neper.info/ neper> outputs
  %
  % Syntax
  %   grains = grain3d.load('filepath/filename.tess')
  %
  % Input
  %  fname     - filename
  %
  % Output
  %  grain2d - @grain2d
  %
  % See also
  % loadNeperTess grain2d.load
 
  [dim, V, poly, ori, crysym, I_CF] = loadNeperTess(filepath);

  if (dim ~= 3)
    error("Wrong dimension. Try grain2d.load instead.")
  end

  CSList = {'notIndexed',crystalSymmetry(crysym)};
  phaseList = 2*ones(size(poly));

  grains = grain3d(V, poly, I_CF, ori, CSList, phaseList);

end
