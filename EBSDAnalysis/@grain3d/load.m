function grains = load(filepath,varargin)
  % grain3d.load is a method to load 3d grain data
  %
  % Syntax
  %   grains = grain3d.load('filepath/filename.tess','CS',CSList)
  %   grains = grain3d.load('filepath/filename.dream3d')
  %   grains = grain3d.load('filepath/filename.dream3d','noOrientFaces')
  %
  % Input
  %  fname     - filename
  %  CSList    - list of crystal symmetries
  %
  % Output
  %  grain3d - @grain3d
  %
  % Options
  %  noOrientFaces - dream3d only: keep the face winding as stored in the file
  %
  % Description
  %
  % Dream3d stores the boundary faces with an arbitrary winding, so the
  % faces are oriented on import with <grain3d.orientFaces.html
  % |orientFaces|>. See <loadGrains_Dream3d.html |loadGrains_Dream3d|>.
  %
  % See also
  % loadNeperTess loadGrains_Dream3d grain3d/orientFaces grain2d.load

  interface = get_option(varargin,'interface');
  
  if isempty(interface)
    [~,~,ext] = fileparts(filepath);
    switch ext
      case '.tess'
        interface = 'neper';
      case '.dream3d'
        interface = 'dream3d';
      otherwise
        error('Do not know which interface to use')
    end
  end
  
  switch lower(interface)
    case 'neper'
      
      [dim, V, F, ori, crysym, I_GF] = loadNeperTess(filepath);

      assert(dim == 3,"Wrong dimension. Try grain2d.load instead.")

      phaseList = 2*ones(size(I_GF,1),1);

      CSList = get_option(varargin,'CS',crystalSymmetry(crysym));
      
      if CSList(1).isIndexed, CSList = [notIndexed,CSList]; end
      
      grains = grain3d(V, F, I_GF, ori, CSList, phaseList);

    case 'dream3d'
      
      grains = loadGrains_Dream3d(filepath,varargin{:});


  end
end
