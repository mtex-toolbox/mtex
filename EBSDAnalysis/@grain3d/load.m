function grains = load(filepath,varargin)
  % grain3d.load is a method to load the 3d data from the tessellation files that
  % <neper.info/ neper> outputs
  %
  % Syntax
  %   grains = grain3d.load('filepath/filename.tess','CS',CSList)
  %
  % Input
  %  fname     - filename
  %  CSList    - list of crystal symmetries
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


  phaseList = 2*ones(size(I_CF,1),1);

  CSList = get_option(varargin,'CS',crystalSymmetry(crysym));
  CSList = ensurecell(CSList);
  if ~ischar(CSList{1}), CSList = ['notIndexed',CSList]; end

  grains = grain3d(V, poly, I_CF, ori, CSList, phaseList);

end
