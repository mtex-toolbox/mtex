function grains = load(filepath,varargin)
  % grain3d.load is a method to load 3d grain data
  %
  % Syntax
  %   grains = grain3d.load('filepath/filename.tess','CS',CSList)
  %   grains = grain3d.load('filepath/filename.dream3d')
  %
  % Input
  %  fname     - filename
  %  CSList    - list of crystal symmetries
  %
  % Output
  %  grain3d - @grain3d
  %
  % See also
  % loadNeperTess loadGrains_Dream3d grain2d.load


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
      CSList = ensurecell(CSList);
      if ~ischar(CSList{1}), CSList = ['notIndexed',CSList]; end
      
      grains = grain3d(V, F, I_GF, ori, CSList, phaseList);

    case 'dream3d'
      
      grains = loadGrains_Dream3d(filepath,varargin{:});


  end
end
