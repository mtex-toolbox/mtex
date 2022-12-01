classdef neperInstance < handle
% class that provides an interface to the crystal simulation software
% neper (see https://neper.info)
%
% Example
% 
%


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



