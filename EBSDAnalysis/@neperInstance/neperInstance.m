classdef neperInstance < handle
% class that provides an interface to the crystal simulation software
% neper (see https://neper.info)
%
% Syntax
% 
%   myNeper=neperInstance
%
%   %select working folder, default: @tempdir
%   myNeper.filePath='C:\\Users\user\Work\Mtex\NeperExamples'; 
%
%   %decide if new folder should be created in working directory, default: true
%   myNeper.newFolder=false;
%   %specifing filenames
%   myNeper.fileName3d='my100Grains';    %default: 'allgrains'
%   myNeper.fileName2d='mySlice';        %default: '2dslice'
%
%   %specifying size of tesselation domain
%   myNeper.cubeSize = [4 4 1];
%   %defining tesselation id
%   myNeper.id = 512;
%
%   ori=orientation.rand;
%   ori.CS=crystalSymmetry('mmm');
%   odf=unimodalODF(orientation.rand)
%   numGrains=100;
%   myNeper.simulateGrains(odf,100)
%
%   N=vector3d(1,1,1);    % normal vector (a,b,c) of a plane
%   d=1;                  % d of a plane equation(a,b,c,d)
%   grains=myNeper.getSlice(N,d)
%
%   N=vector3d(0,0,1);    % normal vector of a plane
%   A=vector3d(0,0,0.5);  % point from the plane
%   grains2=myNeper.getSlice(N,A)
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
%  filePath   - filepath working directory, default: tempdir
%  newfolder  - boolean, if true, new folder will be created, default: true;
%
% See also
% grain2d.load


properties

  id = 1;
  cubeSize = [1 1 1];
  morpho = 'graingrowth';
  iterMax = 1000;
  fileName2d = '2dslice'      %name for 2d outputs (fileendings .tess/.ori)
  fileName3d = 'allgrains'    %name for 3d outputs (fileendings .tess/.ori/.stpoly)
  filePath = tempdir
  newfolder = true;
  
end

properties (Access = private)
  folder = 'neper'
  cmdPrefix                    % contains char 'wsl' for windows systems
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

end


methods (Static = true)

  function grains = test

    neper = neperInstance;
    
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

end
end



