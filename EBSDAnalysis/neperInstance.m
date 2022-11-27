classdef neperInstance < handle
% class that provides an interface to the crystal simulation software
% neper (see https://neper.info)

properties

  morphology
  sphericity
  numGrains = 100;
  iterMax = 1000;
  fileName2d = '2dslice'      %name for 2d outputs (fileendings .tess/.ori)
  fileName3d = 'allgrains'    %name for 3d outputs (fileendings .tess/.ori/.stpoly)
  cmdPrefix                         % contains char 'wsl' for windows systems
  
end

methods
  
  function neper = neperInstance(varargin)
    % constructor
    % Input:
    %   numGrains (optional)

    neper.morphology = '';

    if nargin>0   %numGrains
      if isnumeric(varargin{1})
        neper.numGrains=varargin{1};
      else
        error 'argument must be numeric or empty'
      end
    end

    if computer=="PCWIN64"
      neper.cmdPrefix='wsl ';
    else
      neper.cmdPrefix='';
    end

  end

  function simulateGrains(this,ori)

    if isa(ori,'ODF')
      ori = ori.discreSample(this.numGrains);
    else
      this.numGrains=length(ori);
    end
    
    % save ori to file
    oriFilename='ori_in.txt';
    fid=fopen(oriFilename,'w');
    fprintf(fid,'%f %f %f\n',[ori.Rodrigues.x'; ori.Rodrigues.y'; ori.Rodrigues.z']);
    fclose(fid);

    system([this.cmdPrefix 'neper -T -n ' num2str(this.numGrains) ...
    ' -morpho "diameq:lognormal(1,0.35),1-sphericity:lognormal(0.145,0.03),aspratio(3,1.5,1)" ' ...
      ' -morphooptistop "itermax=' num2str(this.iterMax) '" ' ... % decreasing the iterations makes things go a bit faster for testing
      ' -oricrysym "-1" '...
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
    %  
    
    % default values
    n=vector3d(1,1,1);
    d=1;

    if nargin>1 && isa(varargin{1},'vector3d')
      n=varargin{1};
      n=normalize(n);
    end
    if nargin>2
      if isa(varargin{2},"vector3d")
        d=dot(n,varargin{2});
      elseif isnumeric(varargin{2})
        d=varargin{2};
      end
    end

    % get a slice
    system([this.cmdPrefix 'neper -T -loadtess ' this.fileName3d '.tess ' ...
      '-transform "slice(' num2str(d) ',' num2str(n.x) ',' num2str(n.y) ',' num2str(n.z) ')" ' ... % this is (d,a,b,c) of a plane
      '-oricrysym "mmm" -ori "file(' this.fileName3d '.ori)" ' ...
      '-o ' this.fileName2d ' ' ...
      '-oriformat geof ' ...
      '-oridescriptor rodrigues ' ...
      '-format tess,ori ' ...
      '&& ' ...
      ...
      this.cmdPrefix 'neper -V ' this.fileName2d '.tess']);

    grains = grain2d.load([this.fileName2d '.tess']);

  end

end


methods (Static = true)

  function test

    neper = neperInstance;
    neper.iterMax = 1000;

    cs = crystalSymmetry('432');
    oriC = orientation.rand(cs);
    odf = unimodalODF(oriC);
    ori = odf.discreteSample(neper.numGrains);

    neper.simulateGrains(ori)
    grains=neper.getSlice();

    max(angle(oriC,grains.meanOrientation)/degree)

    plot(grains)

  end

end
end



