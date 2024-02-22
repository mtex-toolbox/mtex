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
      
      [dim, V, poly, ori, crysym, I_CF] = loadNeperTess(filepath);

      assert(dim == 3,"Wrong dimension. Try grain2d.load instead.")

      phaseList = 2*ones(size(I_CF,1),1);

      CSList = get_option(varargin,'CS',crystalSymmetry(crysym));
      CSList = ensurecell(CSList);
      if ~ischar(CSList{1}), CSList = ['notIndexed',CSList]; end
      
      grains = grain3d(V, poly, I_CF, ori, CSList, phaseList);

    case 'dream3d'
      
      grains = loadGrains_Dream3d(filepath,varargin{:});


  end
end
