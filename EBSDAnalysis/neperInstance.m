classdef neperInstance < handle
% class that provides an interface to the crystal simulation software
% neper (see https://neper.info)

properties

  iterMax = 1000;
  fileName2d = '2dslice'      %name for 2d outputs (fileendings .tess/.ori)
  fileName3d = 'allgrains'    %name for 3d outputs (fileendings .tess/.ori/.stpoly)
  cmdPrefix                         % contains char 'wsl' for windows systems
  
end

methods
  
  function neper = neperInstance()
    % constructor

    if computer=="PCWIN64"
      neper.cmdPrefix='wsl ';
    else
      neper.cmdPrefix='';
    end

  end

  function simulateGrains(this,varargin)
    % Input:  (optional)
    %   - ori (@ODF) & numGrains (numeric)
    %   - ori (@ODF)
    %   - ori (list @orientation)

    numGrains=100;    %default

    if nargin==3  %numGrains & ori
      if isnumeric(varargin{1}) && isa(varargin{2},'ODF')
        numGrains=varargin{1};
        ori = varargin{2}.discreteSample(numGrains);
      elseif isnumeric(varargin{2}) && isa(varargin{1},'ODF')
        numGrains=varargin{2};
        ori = varargin{1}.discreteSample(numGrains);
      else
        error 'argument error'
      end
    elseif nargin==2 %ori
      if isa(varargin{1},'orientation')
        ori=varargin{1};
        numGrains=length(varargin{1});
      elseif isa(varargin{1},'ODF')
        ori = varargin{1}.discreteSample(numGrains);
      else
        error 'argument error'
      end
    else %default
      ori=orientation.rand();
      ori.CS=crystalSymmetry('mmm');
      ori = unimodalODF(ori).discreteSample(numGrains);
    end

    %% parsing orientations
    CS=ori.CS.LaueName;
    switch CS
      case '2/m11'
        CS='2/m';
      case '12/m1'
        CS='2/m';
      case '112/m'
        CS='2/m';
      case '-3m1'
        CS='-3m';
      case '-31m'
        CS='-3m';
      otherwise
    end

    %% save ori to file
    oriFilename='ori_in.txt';
    fid=fopen(oriFilename,'w');
    fprintf(fid,'%f %f %f\n',[ori.Rodrigues.x'; ori.Rodrigues.y'; ori.Rodrigues.z']);
    fclose(fid);

    system([this.cmdPrefix 'neper -T -n ' num2str(numGrains) ...
    ' -morpho "diameq:lognormal(1,0.35),1-sphericity:lognormal(0.145,0.03),aspratio(3,1.5,1)" ' ...
      ' -morphooptistop "itermax=' num2str(this.iterMax) '" ' ... % decreasing the iterations makes things go a bit faster for testing
      ' -oricrysym "' CS '" '...
      ' -ori "file(' oriFilename ')" ' ... % read orientations from file, default rodrigues
      ' -statpoly faceeqs ' ... % some statistics on the faces
      ' -o ' this.fileName3d ' ' ... % output file name
      ' -oridescriptor rodrigues ' ... % orientation format in output file
      ' -oriformat plain ' ...
      ' -format tess,ori' ... % outputfiles
      ' && ' ...
      ...
      this.cmdPrefix 'neper -V ' this.fileName3d '.tess']);

  end

  function grains = getSlice(this,varargin)
    % 
    % Input (optional)
    %  n - slice normal @vector3d (default:[1,1,1])
    %  d - point in slice @vector3d
    %      0 > x,y,z < 1
    %      or scalar d of a plane(a,b,c,d) (default:1)

    %%
    %deleting old files, to make shure, to not load a wrong file, if slicing failed
    warning off MATLAB:DELETE:FileNotFound
    delete([this.fileName2d '.tess' ]);
    delete([this.fileName2d '.ori' ]);
    warning on MATLAB:DELETE:FileNotFound
    
    %% default values
    n=vector3d(1,1,1);
    d=1;

    if nargin>1
      if isa(varargin{1},'vector3d')
        n=varargin{1};
        n=normalize(n);
      else
        warning 'argument error, using default n'
      end
    end
    if nargin>2
      if isa(varargin{2},"vector3d")
        d=dot(n,varargin{2});
      elseif isnumeric(varargin{2}) && isscalar(varargin{2})
        d=varargin{2};
      else
        warning 'argument error, using default'
      end
    end

    %% get a slice
    system([this.cmdPrefix 'neper -T -loadtess ' this.fileName3d '.tess ' ...
      '-transform "slice(' num2str(d) ',' num2str(n.x) ',' num2str(n.y) ',' num2str(n.z) ')" ' ... % this is (d,a,b,c) of a plane
      '-ori "file(' this.fileName3d '.ori)" ' ...
      '-o ' this.fileName2d ' ' ...
      '-oriformat geof ' ...
      '-oridescriptor rodrigues ' ...
      '-format tess,ori ' ...
      '&& ' ...
      ...
      this.cmdPrefix 'neper -V ' this.fileName2d '.tess']);

    if ~isfile('2dslice.tess')
      error 'slicing failed, try other plane parameters.'
    end

    grains = grain2d.load([this.fileName2d '.tess']);

  end

end


methods (Static = true)

  function grains = test

    neper = neperInstance;

    neper.simulateGrains()
    grains=neper.getSlice();

    plot(grains)

  end

end
end



