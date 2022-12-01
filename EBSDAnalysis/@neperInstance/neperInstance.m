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
%   %decide if new folder should be created in working directory, default: true
%   myNeper.newFolder=false;
%   %specifing filenames
%   myNeper.fileName3d='my100Grains';    %default: 'allgrains'
%   myNeper.fileName2d='mySlice';        %default: '2dslice'
%
%   ori=orientation.rand;
%   ori.CS=crystalSymmetry('mmm');
%   odf=unimodalODF(orientation.rand)
%   numGrains=100;
%   myNeper.simulateGrains(odf,100)
%
%   N=vector3d(1,1,1);    %normal vector (a,b,c) of a plane
%   d=1;                  %d of a plane equation(a,b,c,d)
%   grains=myNeper.getSlice(N,d)
%
%   N=vector3d(0,0,1);    %normal vector of a plane
%   A=vector3d(0,0,0.5);  %point from the plane
%   grains2=myNeper.getSlice(N,A)
%
%   plot(grains,grains.meanOrientation)
%   hold
%   plot(grains2,grains2.meanOrientation)

properties

  iterMax = 1000;
  morrho = 'morpho "diameq:lognormal(1,0.35),1-sphericity:lognormal(0.145,0.03),aspratio(3,1.5,1)" ';
  fileName2d = '2dslice'      %name for 2d outputs (fileendings .tess/.ori)
  fileName3d = 'allgrains'    %name for 3d outputs (fileendings .tess/.ori/.stpoly)
  filePath = tempdir
  newfolder = true;
  
end

properties (Access = private)
  folder = 'neper\'
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



