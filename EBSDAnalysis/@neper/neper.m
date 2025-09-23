classdef (Sealed) neper < handle
% class that provides an interface to the crystal simulation software
% neper (see https://neper.info)
%
% Syntax
% 
%   neper.init
%
%   %select working folder, default: |tempdir|
%   neper.filePath='C:\\Users\user\Work\Mtex\NeperExamples'; 
%
%   % specifying filenames
%   neper.fileName3d='my100Grains';    %default: 'allgrains'
%
%   %specifying size of tessellation domain
%   neper.cubeSize = [4 4 1];
%   %defining tessellation id
%   neper.id = 512;
%
%   %eventually set a list of additional options to be found here
%   %to be found here: https://neper.info/doc/neper_t.html 
%   neper.varNeperopts = '-regularization 1'
%
%   cs = crystalSymmetry('mmm');
%   odf = unimodalODF(orientation.rand(cs))
%   numGrains = 100;
%   myNeper.simulateGrains(numGrains,odf)
%
%   N = vector3d(1,1,1);    % normal vector (a,b,c) of a plane
%   d = 1;                  % d of a plane equation(a,b,c,d)
%   grains = neper.getSlice(N,d)
%
%   N = vector3d(0,0,1);    % normal vector of a plane
%   A = vector3d(0,0,0.5);  % point from the plane
%   grains2 = neper.getSlice(N,A)
%
%   plot(grains,grains.meanOrientation)
%   hold
%   plot(grains2,grains2.meanOrientation)
%
% Class Properties
%  id         - integer, "used [...] to compute the (initial) seed positions"
%  cubeSize   - 1x3 rowvector, size of the tesselation domain box, default: [1 1 1]
%  morpho     - cell morphology, see neper.info/doc/neper_t.html#morphology-options -default: graingrowth
%  iterMax    - max Iterations for morpho optimization process
%  fileName2d - name for 2d outputs (fileendings .tess/.ori), default: '2dslice'
%  fileName3d - name for 3d outputs (fileendings .tess/.ori/.stpoly), default: 'allgrains'
%  filePath   - filepath working directory, default: tempdir/neper
%
% See also
% grain2d.load grain3d.load

properties
  id = 1;
  cubeSize = [1 1 1];
  morpho = 'graingrowth';
  iterMax = 1000;
  varNeperopts = [];          %set any option as specified in https://neper.info/doc/neper_t.html
  fileName2d = '2dslice'      %name for 2d outputs (fileendings .tess/.ori)
  fileName3d = 'allgrains'    %name for 3d outputs (fileendings .tess/.ori/.stpoly)
  filePath = [tempdir 'neper' filesep];
  cmdPrefix                   % contains char 'wsl' for windows systems
end

properties (Dependent = true, Access = private)
  filePathUnix                % differs from filePath for Windows systems
end

methods (Access = private)

  function this = neper()
    % constructor
    if computer=="PCWIN64"
      this.cmdPrefix='wsl ';
    else
      this.cmdPrefix='';
    end

    % ensure filePath exists
    if ~exist(this.filePath,'dir')
      try mkdir(this.filePath); end
    end

    % assert Neper is installed
    out = system([this.cmdPrefix 'neper']);
    if out~=0
      warning('Could not find Neper.')
    end
    
  end

end


methods (Static = true)

  function obj = instance()
    persistent UNIQUE
    if isempty(UNIQUE) || ~isvalid(UNIQUE)
      UNIQUE = neper();
    end
    obj = UNIQUE;
  end

  function init()
    assignin('caller','neper',neper.instance());
  end

  function grains = test

    neper = neper.instance;
    
    numGrains=100;
    ori=orientation.rand();
    ori.CS=crystalSymmetry('mmm');
    ori = unimodalODF(ori).discreteSample(numGrains);

    n=vector3d(1,1,1);
    d=1;

    neper.simulateGrains(ori)
    grains=neper.getSlice(n,d);

    plot(grains,grains.meanOrientation)

  end

  grains = simulateGrains(varargin)
  grains = simulateTwinGrains(varargin)
  grains = getSlice(varargin)

end

methods

  function set.filePath(this,filepath)
    if endsWith(filepath,filesep)
      this.filePath = filepath;
    else
      this.filePath = [filepath filesep];
    end 

    % ensure filePath exists
    if ~exist(this.filePath,'dir')
      mkdir(this.filePath);
    end
  end
  
  function path = get.filePathUnix(this)
    path = path2unix(this.filePath);
  end

end
end



